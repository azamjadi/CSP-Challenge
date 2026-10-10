-- Run in Supabase SQL Editor.
-- Allows a logged-in user to check ONLY their own access status.
CREATE OR REPLACE FUNCTION public.csp_my_access()
RETURNS TABLE(role text,status text,country text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $$
 SELECT a.role,a.status,a.country
 FROM public.user_access a
 WHERE a.user_id=auth.uid()
$$;
REVOKE ALL ON FUNCTION public.csp_my_access() FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.csp_my_access() TO authenticated;

-- Access changes must go through the authorized admin RPC.
REVOKE INSERT,UPDATE,DELETE ON public.user_access FROM anon,authenticated;
DROP POLICY IF EXISTS "Super admin updates access" ON public.user_access;
