$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\MainAudit.ps1")  
   
}
catch {
    Write-Host "Error while loading supporting PowerShell Scripts" 
}


#AuditMain -tag "-dev" -migrationSites "$ScriptDirectory\MigrationITDept.csv" -outputPath "C:\Advantage\MigrationData\ITDept\links"
#AuditMain -migrationSites "$ScriptDirectory\MigrationGroups\MigrationG11.csv" -outputPath "C:\Advantage\MigrationData\Group11\links"
#AuditMain -migrationSites "$ScriptDirectory\MigrationGroups\MigrationG10.csv" -outputPath "C:\Advantage\MigrationData\Group10\links"
AuditMain  -migrationSites "$ScriptDirectory\MigrationGroups\MigrationEventExecution.csv" -outputPath "C:\Advantage\MigrationData\EventExecution\links"


