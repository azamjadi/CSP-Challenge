CREATE OR REPLACE FUNCTION public.csp_admin_users()
RETURNS TABLE(user_id uuid,email text,full_name text,country text,employment_type text,distributor_name text,role text,status text,created_at timestamptz)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $$
 SELECT a.user_id,u.email::text,
 coalesce(u.raw_user_meta_data->>'full_name',u.raw_user_meta_data->>'name',u.email)::text,
 coalesce(a.country,p.country)::text,
 coalesce(pi.employment_type,'')::text,
 coalesce(pi.distributor_name,'')::text,
 a.role,a.status,a.created_at
 FROM public.user_access a
 JOIN auth.users u ON u.id=a.user_id
 LEFT JOIN public.profiles p ON p.id=a.user_id
 LEFT JOIN public.player_professional_info pi ON pi.user_id=a.user_id
 WHERE public.is_csp_super_admin()
 ORDER BY a.created_at DESC
$$;
REVOKE ALL ON FUNCTION public.csp_admin_users() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.csp_admin_users() TO authenticated;

CREATE OR REPLACE FUNCTION public.csp_admin_set_status(target_user_id uuid,new_status text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
 IF NOT public.is_csp_super_admin() THEN
  RAISE EXCEPTION 'Administrator access required';
 END IF;
 IF new_status NOT IN ('pending','active','rejected','suspended') THEN
  RAISE EXCEPTION 'Invalid status';
 END IF;
 IF target_user_id=auth.uid() THEN
  RAISE EXCEPTION 'Cannot change own status';
 END IF;
 UPDATE public.user_access
 SET status=new_status,reviewed_by=auth.uid(),reviewed_at=now()
 WHERE user_id=target_user_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'User not found'; END IF;
END
$$;
REVOKE ALL ON FUNCTION public.csp_admin_set_status(uuid,text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.csp_admin_set_status(uuid,text) TO authenticated;
