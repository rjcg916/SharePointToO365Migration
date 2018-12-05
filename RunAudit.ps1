$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\AuditMain.ps1")  
   
}
catch {
    Write-Host "Error while loading supporting PowerShell Scripts" 
}


AuditMain -migrationSites "$ScriptDirectory\ITDept.csv" -outputPath "C:\Advantage\MigrationData\ITDept\links"
