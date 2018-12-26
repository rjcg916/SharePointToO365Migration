$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\globals.ps1")  
    . ("$ScriptDirectory\ConvertToModern.ps1")
  
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage -ForegroundColor Red
}


Function ConvertToModernMain {
    param([parameter(Mandatory = $true)]$migrationSites, 
        $tag = "") 

    $SCs = Get-SiteCollectionList -siteCollectionList $migrationSites  -filterGroup $SERVER_ID 

    $destCredentials = Get-Credential -UserName $DEST_USER_NAME -Message "Enter destination password"

    New-ModernPagesAll -credentials $destCredentials -rootUrl $DEST_ROOT_URL -SCs $SCs -tag $tag 
}