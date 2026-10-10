-- Run after sql/11 and sql/12.
-- Restrict authenticated access to the existing game functions by checking
-- user_access in a SECURITY DEFINER helper.
CREATE OR REPLACE FUNCTION public.csp_require_active_player()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
 IF auth.uid() IS NULL OR NOT EXISTS (
  SELECT 1 FROM public.user_access a
  WHERE a.user_id=auth.uid() AND a.status='active'
 ) THEN
  RAISE EXCEPTION 'Your CSP Challenge account is not approved'
   USING ERRCODE='42501';
 END IF;
END $$;
REVOKE ALL ON FUNCTION public.csp_require_active_player() FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.csp_require_active_player() TO authenticated;

-- IMPORTANT: This helper alone does not secure game RPCs or tables.
-- Add PERFORM public.csp_require_active_player(); at the beginning of each
-- SECURITY DEFINER game RPC (e.g. start_round, answer submission,
-- get_leaderboard, learning dashboard RPCs) and review table RLS policies.
-- Do not mark the backend secured until those checks have been deployed.
