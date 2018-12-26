$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\MainAlerts.ps1")
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage -ForegroundColor Red
}


AlertsMain -migrationSites "$ScriptDirectory\MigrationGroups\MigrationITDept.csv" -status "On" -tag "-dev"
