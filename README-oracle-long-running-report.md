Oracle long-running sessions report

What this provides
- oracle_long_running_report.sql: SQL*Plus script that outputs a CSV of sessions whose elapsed time since LOGON exceeds a threshold.
- run_report.ps1: PowerShell wrapper to run the SQL script against multiple Oracle connect strings from connections.txt and save CSV reports.
- connections.txt: sample file where each line is username/password@tnsalias

Requirements
- Oracle client with sqlplus on PATH
- Permissions to query V$SESSION and V$SQL (typically CONNECT with SELECT_CATALOG_ROLE or appropriate grants)

Example
1. Edit connections.txt with one connect string per line (do NOT commit credentials to git)
2. Run: powershell -ExecutionPolicy Bypass -File .\run_report.ps1 -ConnectionsFile .\connections.txt -Threshold 600 -OutputDir .\reports
3. Check .\reports for CSV files

Notes
- Threshold is in seconds (default 600 = 10 minutes)
- The SQL text is truncated and sanitized to reduce CSV breakage. Adjust SUBSTR length in the SQL if needed.
- For production scheduling, run the PowerShell script from a scheduled task or CI job; keep credentials secure (use OS secrets or a secure wallet instead of plain file).