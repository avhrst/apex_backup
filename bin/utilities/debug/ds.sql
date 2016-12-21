set define '^' verify off
--------------------------------------------------------------------------------
--
--  Copyright (c) Oracle Corporation 1999 - 2012. All Rights Reserved.
--
--    NAME
--      ds.sql - print the debug page views for an apex session
--
--      SQL> @ds 1234567890
--
--    DESCRIPTION
--
--    RUNTIME DEPLOYMENT: NO
--    PUBLIC:             NO
--
--    MODIFIED   (MM/DD/YYYY)
--    cneumuel    12/17/2012 - Created
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

with page_views1 as (
    select page_view_id
      from wwv_flow_debug_messages
     where session_id=^1 ),
page_views2 as (
    select page_view_id
      from wwv_flow_debug_messages2
     where session_id=^1 )
select page_view_id,
       to_char(start_timestamp,'hh24:mi:ss') started,
       secs,
       cnt,
       nvl(path_info,show_accept) path_info,
       rtrim(flow_id||':'||page_id,':') flow_page,
       session_id,
       workspace,
       apex_user
from (
    select '@d2 '||page_view_id page_view_id,
           count(*) cnt,
           min(message_timestamp) start_timestamp,
           min(case when message like 'CGI: PATH_INFO =%' then substr(message,19) end) path_info,
           min(case when message like 'S H O W:%' then 'show'
                    when message like 'A C C E P T:%' then 'accept'
               end) show_accept,
           to_char(extract(second from max(message_timestamp)-min(message_timestamp)),'90D99') secs,
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
           row_number() over (order by d.page_view_id) r#
    from (select * from wwv_flow_debug_messages
           where page_view_id in (select page_view_id from page_views1)
          union all
          select * from wwv_flow_debug_messages2
           where page_view_id in (select page_view_id from page_views1)
         ) d,
         wwv_flow_companies ws
    where d.security_group_id = ws.provisioning_company_id
    group  by page_view_id )
order by r#
/
