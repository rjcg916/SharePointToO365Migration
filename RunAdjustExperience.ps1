$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\MainAdjustExperience.ps1")
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage -ForegroundColor Red
}


AdjustExperienceMain -migrationSites "$ScriptDirectory\MigrationGroups\MigrationITDept.csv" -experience $EXPERIENCE_MODERN -tag "-dev"
