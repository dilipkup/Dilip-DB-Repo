-- oracle_long_running_report.sql
-- Usage (interactive): sqlplus user/pass@db @oracle_long_running_report.sql output.csv 600
-- This script writes a CSV with long-running sessions older than the threshold (seconds).
ACCEPT report_file CHAR PROMPT 'Output CSV file: '
ACCEPT threshold_seconds NUMBER DEFAULT 600
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SET HEADING OFF
SET TERMOUT OFF
SET TRIMSPOOL ON
SET LINESIZE 32000
SET LONG 10000

SPOOL &report_file
-- CSV header
PROMPT SID,SERIAL#,USERNAME,OSUSER,MACHINE,PROGRAM,STATUS,SQL_ID,SQL_TEXT,LOGON_TIME,ELAPSED_SECONDS

SELECT s.sid || ',' || s.serial# || ',' || NVL(REPLACE(s.username,',',' '),'') || ','
       || NVL(REPLACE(s.osuser,',',' '),'') || ',' || NVL(REPLACE(s.machine,',',' '),'') || ','
       || NVL(REPLACE(s.program,',',' '),'') || ',' || s.status || ',' || NVL(s.sql_id,'') || ','
       || '"' || REPLACE(REPLACE(NVL(SUBSTR(sql.sql_text,1,2000),'-'),'"','""'),CHR(10),' ') || '"' || ','
       || TO_CHAR(s.logon_time,'YYYY-MM-DD HH24:MI:SS') || ','
       || ROUND((sysdate - s.logon_time)*24*3600,0)
FROM v$session s LEFT JOIN v$sql sql ON s.sql_id = sql.sql_id
WHERE s.username IS NOT NULL
  AND (sysdate - s.logon_time)*24*3600 >= &threshold_seconds
ORDER BY (sysdate - s.logon_time)*24*3600 DESC;

SPOOL OFF
EXIT
