$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\globals.ps1") 
    . ("$ScriptDirectory\Navigation.ps1")
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage -ForegroundColor Red
}


Function AuditMain {
    param([parameter(Mandatory = $true)]$migrationSites, 
        [parameter(Mandatory = $true)]$outputPath, 
        $tag = "") 

    $SCs = Get-SiteCollectionList -siteCollectionList $migrationSites  -filterGroup $SERVER_ID 

    $destCredentials = Get-Credential -UserName $DEST_USER_NAME -Message "Enter destination password"


    #export all Quick Links and Top Navs
    Get-NavAll  -credentials $destCredentials -rootUrl $DEST_ROOT_URL -SCs $SCs -outputPath $outputPath -tag $tag

}
