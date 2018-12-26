$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\MainMigrate.ps1")  
   
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage -ForegroundColor Red
}

#5
#MigrateMain -migrationSites "$ScriptDirectory\MigrationGroups\MigrationG11.csv"
#7
#MigrateMain -migrationSites "$ScriptDirectory\MigrationGroups\MigrationG12.csv"
#8
#MigrateMain -migrationSites "$ScriptDirectory\MigrationGroups\MigrationEEDSupport.csv"
#10
#MigrateMain -migrationSites "$ScriptDirectory\MigrationGroups\Migrationretailops.csv"
#RefreshMain -migrationSites "$ScriptDirectory\MigrationGroups\MigrationG10.csv"

#RefreshMain -migrationSites "$ScriptDirectory\MigrationGroups\MigrationITDept.csv" -tag "-dev"

#5
RefreshMain -migrationSites "$ScriptDirectory\MigrationGroups\MigrationFinanceAndAccounting.csv" 
#7
RefreshMain -migrationSites "$ScriptDirectory\MigrationGroups\MigrationG12.csv" 
