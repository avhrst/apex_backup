set define '^' verify off
--------------------------------------------------------------------------------
--
--  Copyright (c) Oracle Corporation 1999 - 2012. All Rights Reserved.
--
--    NAME
--      d2.sql - show debug messages for a debug page view id
--
--    DESCRIPTION
--      -- ... after running @d1 or @ds which show page view id 12345
--      SQL> @d2 12345
--
--    RUNTIME DEPLOYMENT: NO
--    PUBLIC:             NO
--
--    MODIFIED   (MM/DD/YYYY)
--    cneumuel    12/21/2011 - Created
--    cneumuel    02/29/2012 - optimizations, added APEX_040200
--    cneumuel    04/05/2012 - handle ZERO_DIVIDE if sum(secs) over () is 0
--    cneumuel    12/17/2012 - added header
--
--------------------------------------------------------------------------------
set lines 240 pages 9999 termout off recsep off feed off trimspool on
col secs for a6 justify right
col message_level for a3 head "LVL"
col message for a90 wrapped
col flow_page for a8 head "APP/PAGE"
col apex_user for a9
col sid_sgid for a8 head "SID/SGID"
col call_stack1 for a50
col call_stack2 for a50
spool .d2-^1..lst
with consts as (
    select chr(10) CR,
           '^([^'||chr(10)||']+'||chr(10)||'?){1,#COUNT#}' SPLIT_PATTERN
    from dual ),
msg_source as (
    select
        id,
        extract(minute from (message_timestamp-first_value(message_timestamp) over (order by id)))*60+
        extract(second from (message_timestamp-first_value(message_timestamp) over (order by id))) secs,
        message_level,
        message,
        flow_id,
        page_id,
        substr(session_id,1,7)||'~' sid,
        regexp_replace(apex_user,'([[:alnum:]_]{1,3})[^@]*(@.*)','\1\2') apex_user,
        substr(security_group_id,1,7)||'~' sgid,
        rtrim(call_stack,CR||':2') call_stack
    from (select * from wwv_flow_debug_messages
          union all
          select * from wwv_flow_debug_messages2),
         consts
    where page_view_id=^1
    order by id )
select
    lpad(to_char(secs,'FM90D000'),6)||
    lpad(to_char(round(100 * sum(secs) over (order by id) / nullif(sum(secs) over (),0)), '990')||'%',6)
    secs,
    '-'||message_level||'-' message_level,
    message,
    lpad(to_char(flow_id),8)|| lpad(to_char(page_id),8) flow_page,
    sid||sgid sid_sgid,
    apex_user,
    rtrim (
        regexp_substr (
            call_stack,
            replace (
                SPLIT_PATTERN,
                '#COUNT#',
                round(length(regexp_replace(call_stack,'[^'||CR||']',null))/2) )),
        CR ) call_stack1,
    rtrim (
        regexp_replace (
            call_stack,
            replace (
                SPLIT_PATTERN,
                '#COUNT#',
                round(length(regexp_replace(call_stack,'[^'||CR||']',null))/2) ),
            null ),
        CR ) call_stack2
from msg_source,
     consts
/
spool off
set feed on recsep wrapped termout on
prompt opening file .d2-^1..lst with "^_EDITOR"...
ed .d2-^1..lst
