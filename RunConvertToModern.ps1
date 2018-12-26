$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\MainConvertToModern.ps1")  
   
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage -ForegroundColor Red
}

ConvertToModernMain -migrationSites "$ScriptDirectory\MigrationGroups\MigrationITDept.csv" -tag "-dev"
