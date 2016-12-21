set define '^' verify off
--------------------------------------------------------------------------------
--
--  Copyright (c) Oracle Corporation 1999 - 2012. All Rights Reserved.
--
--    NAME
--      d1.sql
--
--    DESCRIPTION
--      show last 30 debugged sessions
--      the leftmost column (@d2 11234566) is a call to script d2, to drill
--      into the debug messages.
--
--    RUNTIME DEPLOYMENT: NO
--    PUBLIC:             NO
--
--    MODIFIED   (MM/DD/YYYY)
--    cneumuel    12/21/2011 - Created
--    cneumuel    05/08/2012 - show number of debug rows per request
--    cneumuel    12/17/2012 - added header
--    cneumuel    03/03/2015 - invalid started and secs column, converted timestamp to utc and then to local
--
--------------------------------------------------------------------------------
set lines 240
col page_view_id for a13
col started for a8
col secs for a6
col cnt for 99990 head "COUNT"
col flow_page for a10 head "APP:PAGE"
col path_info for a28
col session_id for a33
col workspace for a20
col apex_user for a32 head "USER"

select page_view_id,
       to_char(start_timestamp at local,'hh24:mi:ss') started,
       to_char(extract(second from end_timestamp-start_timestamp), '90D99') secs,
       cnt,
       coalesce(request,path_info)||error_code path_info,
       rtrim(flow_id||':'||page_id,':') flow_page,
       session_id,
       workspace,
       apex_user
from (
    select '@d2 '||page_view_id page_view_id,
           count(*) cnt,
           min(sys_extract_utc(message_timestamp)) start_timestamp,
           max(sys_extract_utc(message_timestamp)) end_timestamp,
           min(case when message like 'CGI: PATH_INFO =%' then substr(message,19) end) path_info,
           min(case when message like 'R E Q U E S T %' then substr(message, 15)
               end) request,
           min(case when message like '%apex_error_code: %' then regexp_substr(message, 'apex_error_code:(.*)',1,1,null,1)
               end) error_code,
           min(flow_id)||
           case when min(flow_id) <> max(flow_id) then '-'||max(flow_id) end flow_id,
           min(page_id)||
           case when min(page_id)<>max(page_id) then '-'||max(page_id) end page_id,
           min(session_id)||
           case when min(session_id)<>max(session_id) then '-'||max(session_id) end session_id,
           min(ws.short_name)||
           case when min(ws.short_name)<>max(ws.short_name) then '-'||max(ws.short_name) end workspace,
           min(apex_user)||
           case when min(apex_user)<>max(apex_user) then '-'||max(apex_user) end apex_user,
           row_number() over (order by d.page_view_id desc) r#
    from (select * from wwv_flow_debug_messages
          union all
          select * from wwv_flow_debug_messages2
         ) d,
         wwv_flow_companies ws
    where d.security_group_id = ws.provisioning_company_id
    group  by page_view_id )
where r# < 31
order by r# desc
/
