select to_regclass('public.profiles') is not null as profiles_table_exists;
select to_regclass('public.public_profiles') is not null as public_profiles_view_exists;
select public.check_nickname_available('test_name') as nickname_available;
select count(*)>0 as trigger_exists from pg_trigger where tgname='create_profile_on_signup_trigger';
select relrowsecurity as rls_enabled from pg_class where oid='public.profiles'::regclass;
