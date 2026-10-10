-- Permanent country synchronization for CSP Challenge.
-- Keeps profiles.country in sync with registration and profile edits.
-- Run once in Supabase SQL Editor.

CREATE OR REPLACE FUNCTION public.csp_sync_country_from_auth()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
 v_country text;
BEGIN
 v_country := nullif(btrim(NEW.raw_user_meta_data->>'country'), '');
 IF v_country IS NOT NULL THEN
  INSERT INTO public.profiles(id,country)
  VALUES (NEW.id,v_country)
  ON CONFLICT(id) DO UPDATE SET country=EXCLUDED.country;
  UPDATE public.user_access
  SET country=v_country
  WHERE user_id=NEW.id AND country IS DISTINCT FROM v_country;
 END IF;
 RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS csp_sync_country_auth_user ON auth.users;
CREATE TRIGGER csp_sync_country_auth_user
AFTER INSERT OR UPDATE OF raw_user_meta_data ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.csp_sync_country_from_auth();

-- Repair existing missing countries without overwriting populated values.
UPDATE public.profiles p
SET country=btrim(u.raw_user_meta_data->>'country')
FROM auth.users u
WHERE u.id=p.id
  AND nullif(btrim(p.country),'') IS NULL
  AND nullif(btrim(u.raw_user_meta_data->>'country'),'') IS NOT NULL;

-- Check for users who still have no profile row.
SELECT u.email,
       u.raw_user_meta_data->>'country' AS registration_country,
       p.country AS profile_country
FROM auth.users u
LEFT JOIN public.profiles p ON p.id=u.id
WHERE nullif(btrim(u.raw_user_meta_data->>'country'),'') IS NOT NULL
  AND (p.id IS NULL OR nullif(btrim(p.country),'') IS NULL);
