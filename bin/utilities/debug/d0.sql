set define '^' verify off
--------------------------------------------------------------------------------
--
--  Copyright (c) Oracle Corporation 1999 - 2012. All Rights Reserved.
--
--    NAME
--      d0.sql - toggle instance wide debug mode
--
--    DESCRIPTION
--      --
--      -- 1. enable instance wide debug mode
--      --
--      SQL> @d0
--      Changed debug level from "" to "9"
--      --
--      -- 2. use either @d1 or @ds to list debug page views
--      --
--      SQL> @d1
--      SQL> @ds 1234567890
--      --
--      -- 3. use @d2 to print details for one page view (opens editor)
--      --
--      @d2 12345
--      -- 
--      -- 4. disable instance wide debug mode
--      --
--      SQL> @d0
--      Changed debug level from "9" to ""
--
--    RUNTIME DEPLOYMENT: NO
--    PUBLIC:             NO
--
--    MODIFIED   (MM/DD/YYYY)
--    cneumuel    12/21/2011 - Created
--    cneumuel    12/17/2012 - added header
--    cneumuel    07/15/2014 - Warn if _editor is null or "ed"
--
--------------------------------------------------------------------------------

set serveroutput on size unlimited feed off
declare
    l_prev_debug_level varchar2(4000);
    l_new_debug_level  varchar2(4000);
    l_editor           varchar2(4000) := '^_EDITOR';
    procedure warn_editor (
        p_message in varchar2 )
    is
    begin
        sys.dbms_output.put_line('-------------------------------------------------------------------------------');
        sys.dbms_output.put_line('WARNING: '||p_message||'.');
        sys.dbms_output.put_line('The @d2 script uses _EDITOR to display debug output.');
        sys.dbms_output.put_line('You can e.g. call "DEFINE _EDITOR=vim" to define a different editor.');
        sys.dbms_output.put_line('-------------------------------------------------------------------------------');
    end warn_editor;
begin
    l_prev_debug_level := apex_instance_admin.get_parameter (
                              p_parameter => 'SYSTEM_DEBUG_LEVEL' );
    --
    l_new_debug_level := case
                           when l_prev_debug_level is null
                                or l_prev_debug_level < '9' then '9'
                           else null
                         end;
    --
    apex_instance_admin.set_parameter (
        p_parameter => 'SYSTEM_DEBUG_LEVEL',
        p_value     => l_new_debug_level );
    --
    commit;
    --
    sys.dbms_output.put_line (
        'Changed debug level from "'||l_prev_debug_level||'" to "'||
        l_new_debug_level||'"' );
    if nvl(length(l_editor), 0) = 0 then
        warn_editor('_EDITOR is not defined');
    elsif l_editor = 'ed' then
        warn_editor('_EDITOR is set to "ed"');
    end if;
end;
/
set feed on
