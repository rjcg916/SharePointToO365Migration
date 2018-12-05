$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\globals.ps1") 
    . ("$ScriptDirectory\SiteCollection.ps1")   
    . ("$ScriptDirectory\Migration.ps1")   
    . ("$ScriptDirectory\ClassicExperience.ps1")
    . ("$ScriptDirectory\Logo.ps1")        
}
catch {
   $ErrorMessage = $_.Exception.Message
   Write-Host $ErrorMessage -ForegroundColor Red
}

Function MigrateMain($migrationSites, $tag = "")
{


$SCs = Get-SiteCollectionList -siteCollectionList $migrationSites  -filterGroup $SERVER_ID 


$srcCredentials  = Get-Credential -UserName $SRC_USER_NAME -Message "Enter source password"
$destCredentials = Get-Credential -UserName $DEST_USER_NAME -Message "Enter destination password"


#Delete any existing site collections
PurgeAll -adminUrl $DEST_ADMIN_URL -rootUrl $DEST_ROOT_URL -credentials $destCredentials -SCs $SCs -tag $tag


#Create Empty Site Collections 
CreateAll -credentials $destCredentials -adminUrl $DEST_ADMIN_URL -userName $DEST_USER_NAME -rootUrl $DEST_ROOT_URL -SCs $SCs -tag $tag

Migrate  `
   -srcCredentials $srcCredentials -srcRootUrl $SRC_ROOT_URL `
   -destRootUrl $DEST_ROOT_URL `
   -unresolvedUserName $UNRESOLVED_USER_NAME `
   -SCs $SCs `
   -tag $tag


#set all site/sub-site list/libraries to classic experience
Set-ClassicExperienceAll  -credentials $destCredentials -rootUrl $DEST_ROOT_URL -SCs $SCs -tag $tag

#set all site/sub-site logos
Set-LogoAll  -credentials $destCredentials -rootUrl $DEST_ROOT_URL -siteLogoUrl $SITE_LOGO_URL -SCs $SCs -tag $tag

}

Function RefreshMain($migrationSites, $tag = "")
{

$SCs = Get-SiteCollectionList -siteCollectionList $migrationSites  -filterGroup $SERVER_ID 

$srcCredentials  = Get-Credential -UserName $SRC_USER_NAME -Message "Enter source password"
$destCredentials = Get-Credential -UserName $DEST_USER_NAME -Message "Enter destination password"

Refresh  `
-srcCredentials $srcCredentials -srcRootUrl $SRC_ROOT_URL `
-destCredential $destCredentials -adminUrl $DEST_ADMIN_URL -userName $DEST_USER_NAME -destRootUrl $DEST_ROOT_URL `
-unresolvedUserName $UNRESOLVED_USER_NAME `
-SCs $SCs `
-tag $tag

#set all site/sub-site list/libraries to classic experience
Set-ClassicExperienceAll  -credentials $destCredentials -rootUrl $DEST_ROOT_URL -SCs $SCs -tag $tag

#set all site/sub-site logos
Set-LogoAll  -credentials $destCredentials -rootUrl $DEST_ROOT_URL -siteLogoUrl $SITE_LOGO_URL -SCs $SCs -tag $tag

}