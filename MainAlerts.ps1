$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\globals.ps1") 
    . ("$ScriptDirectory\Alerts.ps1")
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage -ForegroundColor Red
}


Function AlertsMain {
    param([parameter(Mandatory = $true)]$migrationSites, 
        $status = 'On', 
        $tag = "") 

    $SCs = Get-SiteCollectionList -siteCollectionList $migrationSites  -filterGroup $SERVER_ID 

    $credentials = Get-Credential -UserName $DEST_USER_NAME -Message "Enter destination password"

    Set-AlertsAll -credentials $credentials -rootUrl $DEST_ROOT_URL  -SCs $SCs -status $status -tag $tag 
}
