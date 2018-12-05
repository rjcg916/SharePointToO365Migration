$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\MigrateMain.ps1")  
   
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage -ForegroundColor Red
}

# Group 2,5,6, 8, 9, Client 1 - Initial Migration Run
# MigrateMain -migrationSites "$ScriptDirectory\MigrationG8.csv"
# MigrateMain -migrationSites "$ScriptDirectory\MigrationC1.csv"
# RefreshMain -migrationSites "$ScriptDirectory\MigrationCatman.csv"
# MigrateMain -migrationSites "$ScriptDirectory\MigrationC2.csv"
# MigrateMain -migrationSites "$ScriptDirectory\MigrationC3.csv"
#  MigrateMain -migrationSites "$ScriptDirectory\MigrationC4.csv"
# Group 8,9; Client Group 1 in queue for Refresh
# RefreshMain -migrationSites "$ScriptDirectory\MigrationG8.csv"
# RefreshMain -migrationSites "$ScriptDirectory\MigrationG9.csv"
#RefreshMain -migrationSites "$ScriptDirectory\MigrationG8.csv"
MigrateMain -migrationSites "$ScriptDirectory\MigrationITDept.csv" -tag "-dev"