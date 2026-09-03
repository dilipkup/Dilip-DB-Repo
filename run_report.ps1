<#
PowerShell wrapper to run the SQL*Plus report against multiple Oracle connect strings.
connections.txt should contain one connect string per line in the form: username/password@tnsalias
Requires sqlplus to be on PATH.
Usage: .\run_report.ps1 -ConnectionsFile .\connections.txt -Threshold 600 -OutputDir .\reports
#>
param(
    [string]$ConnectionsFile = "connections.txt",
    [int]$Threshold = 600,
    [string]$OutputDir = ".\reports"
)

if (-not (Test-Path $ConnectionsFile)) {
    Write-Error "Connections file '$ConnectionsFile' not found. Create a file with one connection string per line: user/pass@tns"
    exit 1
}
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }

$timestamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
$scriptPath = Join-Path $PSScriptRoot 'oracle_long_running_report.sql'
if (-not (Test-Path $scriptPath)) {
    Write-Error "Cannot find oracle_long_running_report.sql in script directory ($PSScriptRoot)."
    exit 2
}

Get-Content $ConnectionsFile | ForEach-Object {
    $conn = $_.Trim()
    if ([string]::IsNullOrWhiteSpace($conn)) { return }
    # create a safe filename fragment
    $safe = ($conn -replace '[\\/:*?"<>| ]','_')
    $outfile = Join-Path $OutputDir ("report_${safe}_${timestamp}.csv")
    Write-Host "Running report for: $conn -> $outfile"
    # Run SQL*Plus silently; pass parameters: output file and threshold
    $cmd = "sqlplus -S $conn @\"$scriptPath\" $outfile $Threshold"
    Write-Host "Executing: $cmd"
    Invoke-Expression $cmd
    if ($LASTEXITCODE -ne 0) { Write-Warning "sqlplus returned exit code $LASTEXITCODE for $conn" }
}

Write-Host "Reports saved to: $OutputDir"