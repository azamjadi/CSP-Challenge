-- CSP Challenge: administrator approval foundation
-- Run once in Supabase SQL Editor before enabling approval checks in the game.
CREATE TABLE IF NOT EXISTS public.user_access (
 user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
 role text NOT NULL DEFAULT 'player' CHECK (role IN ('super_admin','country_admin','player')),
 status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','active','rejected','suspended')),
 country text,
 reviewed_by uuid REFERENCES auth.users(id),
 reviewed_at timestamptz,
 created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.user_access ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Read own access" ON public.user_access;
CREATE POLICY "Read own access" ON public.user_access FOR SELECT TO authenticated USING (user_id=auth.uid());
CREATE OR REPLACE FUNCTION public.is_csp_super_admin() RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $$ SELECT EXISTS (SELECT 1 FROM public.user_access a WHERE a.user_id=auth.uid() AND a.role='super_admin' AND a.status='active') $$;
REVOKE ALL ON FUNCTION public.is_csp_super_admin() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_csp_super_admin() TO authenticated;
DROP POLICY IF EXISTS "Super admin reads access" ON public.user_access;
CREATE POLICY "Super admin reads access" ON public.user_access FOR SELECT TO authenticated USING (public.is_csp_super_admin());
DROP POLICY IF EXISTS "Super admin updates access" ON public.user_access;
CREATE POLICY "Super admin updates access" ON public.user_access FOR UPDATE TO authenticated USING (public.is_csp_super_admin()) WITH CHECK (public.is_csp_super_admin());
-- Existing users retain access; new signups require approval.
INSERT INTO public.user_access(user_id,role,status,country)
SELECT u.id,
 CASE WHEN lower(u.email)='az.amjadi@gmail.com' THEN 'super_admin' ELSE 'player' END,
 'active',
 COALESCE(p.country,u.raw_user_meta_data->>'country')
FROM auth.users u LEFT JOIN public.profiles p ON p.id=u.id
ON CONFLICT(user_id) DO UPDATE
 SET role=CASE WHEN lower((SELECT email FROM auth.users WHERE id=excluded.user_id))='az.amjadi@gmail.com' THEN 'super_admin' ELSE public.user_access.role END,
 status=CASE WHEN lower((SELECT email FROM auth.users WHERE id=excluded.user_id))='az.amjadi@gmail.com' THEN 'active' ELSE public.user_access.status END;
CREATE OR REPLACE FUNCTION public.csp_access_on_signup()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
AS $$ BEGIN
 INSERT INTO public.user_access(user_id,role,status,country)
 VALUES (NEW.id,'player','pending',NEW.raw_user_meta_data->>'country')
 ON CONFLICT(user_id) DO NOTHING;
 RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS csp_access_new_user ON auth.users;
CREATE TRIGGER csp_access_new_user AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.csp_access_on_signup();
