$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\globals.ps1") 
    . ("$ScriptDirectory\AdjustExperience.ps1")
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage -ForegroundColor Red
}


Function AdjustExperienceMain {
    param([parameter(Mandatory = $true)]$migrationSites, 
        [parameter(Mandatory = $true)]$experience, 
        $tag = "") 

    $SCs = Get-SiteCollectionList -siteCollectionList $migrationSites  -filterGroup $SERVER_ID 

    $destCredentials = Get-Credential -UserName $DEST_USER_NAME -Message "Enter destination password"

    Set-ExperienceAll -credentials $destCredentials -rootUrl $DEST_ROOT_URL -SCs $SCs -experience $experience -tag $tag 
}