-- Oracle APEX Diagnostic Agent for APEX Installs
-- =====================================================

-- USAGE:
-- ======
-- Login to SQL*PLUS as the SYSTEM user and then execute this SQL script
-- as follows:
--  @<path>/apex_verify.sql
-- By default output is written to apex_verify_out.html in the current directory 

REM The formatting method used in this note is based on the formatting methods used in the following notes:
REM Oracle9iAS Portal Diagnostics Agent (PDA) (Doc ID 169490.1)
REM Capture Single Sign-On Configuration Tables to HTML Formatted File (Doc ID 244112.1)


clear buffer;

set serveroutput on
set arraysize 1
set trims on
set linesize 240
set pagesize 0
set sqlprefix off
set verify off
set feedback off
set heading off
set timing off
set define on
set escape off

--prompt V 1.02
--prompt
--prompt Enter output fileneme.  If file exists will be overwritten.
--accept 9 char prompt '(default d:\sso.html):  ' DEFAULT d:\sso.html

spool apex_verify_out.html
select '<head><title>APEX Verification Script</title></head><body bgcolor="#fffccc">' from dual;
select '<body><div align=left><b><font face="Arial,Helvetica"><font color="#990000">' ||
       '<font size=-2>' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') || ' Ver 2.00 ' ||
       '</font></font></font></b></div></body>' from dual;

--START Active version of APEX in the DB


define APEX = 'APEX IS NOT INSTALLED'
column APEX_VER new_val APEX NOPRINT

--use the following to get the apex schema for the version of apex registered in the dba_registry.
SELECT SCHEMA APEX_VER
FROM dba_registry
WHERE comp_id = 'APEX'; 
--WHERE (comp_id = 'APEX' or comp_id like 'HTML%');


define GET_VER ='APEX_RELEASE';
define VERSION = '&APEX..&GET_VER';

--END determine Active version of APEX in the DB


--START Determine tablespace used by APEX schema

define APEX_TABLESPACE = 'NO TABLESPACE'
column APEX_TAB new_val APEX_TABLESPACE NOPRINT

select default_tablespace APEX_TAB from dba_users where username='&APEX';

--END Determine tablespace used by APEX schema



--START  DATABASE VERSION
-- select banner from v$version;
select '<h5><font face="VERDANA"><font color="#006600">APEX Database ' ||
       'Version <font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' || 'DB Information </B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || banner ||
       '</FONT></TD></TR>' from v$version;
select '</TABLE>' FROM dual;
--COMMENTS
select '<body><i><font face="Arial,Helvetica"><font color="#FF0000"><font size=3> For APEX 3.2 and below, DB must be 9.2.0.3 or above.<BR>
For APEX 4.0, DB must be 10.2.0.3 or above or 10g Express</font></font></font></i></body>'
 from dual;

--END DATABASE VERSION

--start Get exact version of APEX
select '<h5><font face="VERDANA"><font color="#006600">APEX ' ||
       'Version Registered in DBA Registry <font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Version </B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'API Compatibility</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2>' || version_no ||
       '</FONT></TD>', '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2>' ||
       api_compatibility || '</FONT></TD></TR>' from &VERSION; 
select '</TABLE>' FROM dual;
--end --Get exact version of APEX

--Begin Get Number of Valids in the APEX Schema
select '<h5><font face="VERDANA"><font color="#006600"> List of APEX Valids/Invalids in the &APEX schema <font size=-2></font></font></font></h5>'
   FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Total APEX Valids </B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || count(1) || '</FONT></TD></TR>'
from dba_objects
where owner = upper('&APEX') and status='VALID';
select '</TABLE>' FROM dual;

--End Get Number of Valids in the APEX Schema

--Begin Get number of Invalids in the APEX Schema
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Total APEX Invalids </B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || count(1) || '</FONT></TD></TR>'
from dba_objects
where owner  = upper('&APEX') and status='INVALID';
select '</TABLE>' FROM dual;
--End Get Number of invalids in the APEX Schema

--Begin Get Number of Invalids in the flows_files schema

select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Total FLOWS_FILES Invalids </B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || count(1) || '</FONT></TD></TR>'  from dba_objects
where owner  = 'FLOWS_FILES' and status='INVALID';
select '</TABLE>' FROM dual;

--End Get Number of Invalids in the flows_files schema


--BEGIN Get information about Valids/Invalids in the APEX Schema
select '<h5><font face="VERDANA"><font color="#006600"> List of &APEX and FLOWS_FILES Invalid Objects <font size=-2></font></font></font></h5>'
   FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;

select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Object Name</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Object Type</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || Object_name || '</FONT></TD>',
           '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || object_type || '</FONT></TD></TR>'
from dba_objects where owner in (UPPER('&APEX'),'FLOWS_FILES')  and status = 'INVALID' order by object_type;
select '</TABLE>' FROM dual;
--End Get information about Valids/Invalids in the APEX Schema

--Start Get images directory

select '<h5><font face="VERDANA"><font color="#006600"> Images Directory (normally all should be -> /i/*. An asterisk(*) indicates that the image prefix is being derived from the instance.)<font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2> Virtual Directory </B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || coalesce(flow_image_prefix, v('IMAGE_PREFIX') || '*') ||  '</FONT></TD></TR>' from &APEX..wwv_flows where security_group_id = 10;
--select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || flow_image_prefix ||  '</FONT></TD></TR>' from &APEX..wwv_flows where security_group_id = 10 and rownum=1;
select '</TABLE>' FROM dual;
--End Get images directory

--START APEX Related Schemas
select '<h5><font face="VERDANA"><font color="#006600">APEX Related Schemas ' ||
       ' <font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' || 'APEX Related Schemas </B></FONT></TH>' FROM dual;

select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || username ||'</FONT></TD></TR>' 
       from dba_users where (username like 'APEX%' or username like 'FLOWS%') order by username asc;
select '</TABLE>' FROM dual;
-- END APEX Related Schemas


--START PL/SQL TOOLKIT VERSION
-- select owa_util.get_version from dual;
select '<h5><font face="VERDANA"><font color="#006600">PL/SQL Toolkit Version <font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' || 'Version </B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || owa_util.get_version  ||  '</FONT></TD></TR>' from dual;
select '</TABLE>' FROM dual;
-- COMMENTS
select '<body><i><font face="Arial,Helvetica"><font color="#FF0000">' ||
       '<font size=-2>Check the PL/SQL Web Toolkit version. If less than 10.1.2.0.6 then ' ||
       'upgrade (discuss with Oracle Support before upgrading)</font></font>' ||
       '</font></i></body>' from dual;
--END PL/SQL TOOLKIT VERSION

--start DUPLICATE OWA PACKAGES 
-- SELECT OWNER, OBJECT_TYPE FROM DBA_OBJECTS WHERE OBJECT_NAME = 'OWA';
select '<h5><font face="VERDANA"><font color="#006600">Duplicate OWA ' ||
       'packages <font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' || 'Owner</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' || 'Object Type</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || owner ||'</FONT></TD>',
           '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || object_type || '</FONT></TD></TR>'
          FROM DBA_OBJECTS WHERE OBJECT_NAME = 'OWA';
select '</TABLE>' FROM dual;
-- COMMENTS

select '<body><i><font face="Arial,Helvetica"><font color="#FF0000">' ||
       '<font size=1>Make sure you do not have duplicate copies of OWA packages. You should see the output as below:<BR><BR>
        SYS...........PACKAGE<BR>
        SYS...........PACKAGE BODY<BR>
        PUBLIC........SYNONYM</font></font></font></i></body>'
   from dual;
--end DUPLICATE OWA PACKAGES 

--START Shared Pool Size
select '<h5><font face="VERDANA"><font color="#006600">Shared Pool Size - Should be at least 100MB ' ||
       ' <font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;

select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Shared Pool Size (MB)</B></FONT></TH>'
 FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||value/1024/1024|| '</FONT></TD></TR>'
from v$parameter where name = 'shared_pool_size';
select '</TABLE>' FROM dual;

--END Shared Pool Size

--START NLS Characterset Values

select '<h5><font face="VERDANA"><font color="#006600">NLS CHARACTER SET Information<font size=-2></font></font></font></h5>'
 FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;

select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Parameter</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Parameter Value</B></FONT></TH>' FROM dual;


select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || parameter ||'</FONT></TD>',
           '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || value     ||'</FONT></TD></TR>'
   from NLS_DATABASE_PARAMETERS where parameter in ('NLS_CHARACTERSET','NLS_NCHAR_CHARACTERSET');

select '</TABLE>' FROM dual;

--END - NLS Characterset Values

--START Free Space in System Tablespace

select '<h5><font face="VERDANA"><font color="#006600">Free Space in System Tablespace ' ||
       ' <font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;

select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>MB Free in System </B></FONT></TH>'
 FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||sum(bytes)/1024/1024|| '</FONT></TD></TR>'
from dba_free_space
where tablespace_name ='SYSTEM';
select '</TABLE>' FROM dual;

--END  Free Space in System Tablespace


--START Free Space in APEX Tablespace

select '<h5><font face="VERDANA"><font color="#006600">Free Space in &APEX_TABLESPACE Tablespace used by &APEX<font size=-2></font></font></font></h5>'
FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;

select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Free Space in MB</B></FONT></TH>'
 FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||sum(bytes)/1024/1024|| '</FONT></TD></TR>'
from dba_free_space
where tablespace_name ='&APEX_TABLESPACE';
select '</TABLE>' FROM dual;

--END   Free Space in APEX Tablespace

-- Begin Get Job Queue Processes

select '<h5><font face="VERDANA"><font color="#006600"> Number of Job Queue Processes<font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2> Number of Job Queue Processes</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || value  ||  '</FONT></TD></TR>' from v$parameter where name='job_queue_processes';
select '</TABLE>' FROM dual;



-- End Get Job Queue Processes 


--Start Get information about XML DB

select '<h5><font face="VERDANA"><font color="#006600">' ||
       'XDB STATUS <font size=-2></font></font></font></h5>'
   FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'owner</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'object_name</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'object_type</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Status</B></FONT></TH>' FROM dual;

col owner format a10
col object_name format a20
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || owner       ||'</FONT></TD>',
           '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || object_name || '</FONT></TD>',
           '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || object_type || '</FONT></TD>',
           '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||      status || '</FONT></TD></TR>'
       from dba_objects where object_name = 'DBMS_XMLPARSER';
select '</TABLE>' FROM dual;
select '<body><i><font face="Arial,Helvetica"><font color="#FF0000">' ||
       '<font size=2>Make sure XML DB packages are installed and valid.  You should see the output as below:<BR><BR>
         PUBLIC....DBMS_XMLPARSER....SYNONYM....VALID<BR>
         XDB.......DBMS_XMLPARSER....PACKAGE....VALID<BR>
         XDB.......DBMS_XMLPARSER....PACKAGE BODY....VALID</font></font></font></i></body>'
from dual;

--END Get information about XML DB

--Start Determine if APEX is a Development or Runtime Installation
define WWV_FLOWS = 'WWV_FLOWS'
define INSTALL_TYPE = '&APEX..&WWV_FLOWS'

select '<h5><font face="VERDANA"><font color="#006600">' ||
       'APEX Install Type (1=Dev 0=Runtime) <font size=-2></font></font></font></h5>'
   FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Install Type</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || count(1)  ||
       '</FONT></TD></TR>' from &INSTALL_TYPE where id = 4000;
select '</TABLE>' FROM dual;
--End Determine if APEX is a Development or Runtime Installation

--Start Determine DB Service Name

select '<h5><font face="VERDANA"><font color="#006600">' ||
       'Database Service Name <font size=-2></font></font></font></h5>'
   FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'DB Service Name</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || value  ||
       '</FONT></TD></TR>' from v$parameter where name='service_names';
select '</TABLE>' FROM dual;
--End  Determine DB Service Name


--START check for enabling of Network Services
select '<h5><font face="VERDANA"><font color="#006600">' ||
       'Enabling of Network Services (Applies only to 11g DBs) <font size=-2></font></font></font></h5>'
   FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'ACL</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Principal</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Privilege</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || acl ||
       '</FONT></TD>', '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       principal || '</FONT></TD>','<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       privilege || '</FONT></TD></TR>'
       from dba_network_acl_privileges;
select '</TABLE>' FROM dual;
--END check for enabling of network services

--START Get DBA Registry Info

select '<h5><font face="VERDANA"><font color="#006600">' ||
       'DBA Registry Info <font size=-2></font></font></font></h5>'
   FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Component ID</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Component Name</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Version</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Schema</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Status</B></FONT></TH>' FROM dual;

col comp_name format a30
col version format a10
col status format a10
col comp_id format a15

select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || comp_id ||'</FONT></TD>',
           '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || comp_name || '</FONT></TD>',
           '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || version || '</FONT></TD>',
           '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || schema || '</FONT></TD>',
           '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || status || '</FONT></TD></TR>'
       from dba_registry; 
select '</TABLE>' FROM dual;

--END Get DBA Registry Info


--start TOTAL INVALID OBJECTS

select '<h5><font face="VERDANA"><font color="#006600">' ||
       'Number of Invalid Objects in the DB <font size=-2></font></font></font></h5>'
   FROM dual;

select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Total Invalid Objects in DB</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || count(1) ||
       '</FONT></TD></TR>' from dba_objects where status = 'INVALID';
select '</TABLE>' FROM dual;
-- COMMENTS
select '<body><i><font face="Arial,Helvetica"><font color="#FF0000">' ||
       '<font size=-2>There should be no INVALID objects in the database ' ||
       'pertaining to the owners within APEX/FLOWS. If there ' ||
       'are any, recompile. Use the <b>utlrp.sql</b>script under the ' ||
       'database home to recompile.</font></font></font></i></body>' from dual;
--end TOTAL INVALID OBJECTS



--START LIST OF ALL INVALID OBJECTS IN THE DATABASE
select '<h5><font face="VERDANA"><font color="#006600">' ||
       'List of ALL Invalid Objects in the DB <font size=-2></font></font></font></h5>'
   FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Owner</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Object Name</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Object type</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Status</B></FONT></TH>' FROM dual;

select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || OWNER       ||'</FONT></TD>',
           '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || object_name ||'</FONT></TD>',
           '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || object_type ||'</FONT></TD>',
           '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || status      ||'</FONT></TD></TR>'
   from DBA_OBJECTS where status = 'INVALID' order by owner;
select '</TABLE>' FROM dual;
--END LIST OF INVALID OBJECTS IN THE DATABASE

--START LIST OF INVALID SYNONYMS AND THEIR OWNERS IN THE DATABASE

select '<h5><font face="VERDANA"><font color="#006600">' ||
       'List of Invalid SYNONYMS in the DB <font size=-2></font></font></font></h5>'
   FROM dual;

select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Synonym Owner</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Synonym Name</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Object Owner</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Object Name </B></FONT></TH>' FROM dual;

select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || a.owner        ||'</FONT></TD>',
           '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || a.synonym_name ||'</FONT></TD>',
           '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || a.table_owner  ||'</FONT></TD>',
           '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || a.table_name   ||'</FONT></TD></TR>'
   from DBA_SYNONYMS A, DBA_OBJECTS B
   --where A.SYNONYM_NAME=B.OBJECT_NAME AND B.object_name like 'APEX%'
   where A.SYNONYM_NAME=B.OBJECT_NAME AND B.status='INVALID'
   --where A.SYNONYM_NAME=B.OBJECT_NAME AND B.status='INVALID' and  b.object_type='SYNONYM'
   --where A.SYNONYM_NAME=B.OBJECT_NAME AND B.object_name like 'APEX%' and  b.object_type='SYNONYM'
   order by a.owner;
select '</TABLE>' FROM dual;


--select A.owner, A.synonym_name, A.table_owner, A.table_name, B.STATUS, B.OBJECT_TYPE
--from DBA_SYNONYMS A, DBA_OBJECTS B
--WHERE A.SYNONYM_NAME=B.OBJECT_NAME AND B.object_name like 'APEX%' and  b.object_type='SYNONYM';




--END LIST OF INVALID SYNONYMS AND THEIR OWNERS IN THE DATABASE



spool off
