$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\MigrationReport.ps1")  
   
}
catch {
    Write-Host "Error while loading supporting PowerShell Scripts" 
}

MigrationReportAll -scanDirectory "C:\Advantage\MigrationData\ITDept\"