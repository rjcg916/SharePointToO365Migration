$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\globals.ps1") 
    . ("$ScriptDirectory\SiteCollection.ps1")   
    . ("$ScriptDirectory\Migration.ps1")   
    . ("$ScriptDirectory\AdjustExperience.ps1")
    . ("$ScriptDirectory\Logo.ps1")        
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage -ForegroundColor Red
}



Function MigrateMain {
    param([parameter(Mandatory = $true)]$migrationSites, 
        $tag = "") 


    $SCs = Get-SiteCollectionList -siteCollectionList $migrationSites  -filterGroup $SERVER_ID 


    $srcCredentials = Get-Credential -UserName $SRC_USER_NAME -Message "Enter source password"
    $destCredentials = Get-Credential -UserName $DEST_USER_NAME -Message "Enter destination password"


    #Delete any existing site collections
    PurgeAll -adminUrl $DEST_ADMIN_URL -rootUrl $DEST_ROOT_URL -credentials $destCredentials -SCs $SCs -tag $tag


    #Create Empty Site Collections 
    CreateAll -credentials $destCredentials -adminUrl $DEST_ADMIN_URL -userName $DEST_USER_NAME -rootUrl $DEST_ROOT_URL -SCs $SCs -tag $tag


    #Migrate all Site Collections    
    $migrateArgs = @{OnContentItemExists = "Overwrite";
        OnSiteObjectExists               = "Merge";
        OnWarning                        = "Continue";
        OnError                          = "Skip";
        ErrorAction                      = "Continue";
        WarningAction                    = "Continue" 
    }
    $migratePhase = $MIGRATION_PHASE_INITIAL    
    MigrateAll -migratePhase $migratePhase  -migrateArgs $migrateArgs -unresolvedUserName $UNRESOLVED_USER_NAME -srcRootUrl $SRC_ROOT_URL -srcCredentials $srcCredentials -destCredentials $destCredentials  -destRootUrl $DEST_ROOT_URL -SCs $SCs -tag $tag

    #set all site/sub-site list/libraries to classic experience
    Set-ExperienceAll -experience $EXPERIENCE_CLASSIC -credentials $destCredentials -rootUrl $DEST_ROOT_URL -SCs $SCs -tag $tag

    #set all site/sub-site logos
    Set-LogoAll  -credentials $destCredentials -rootUrl $DEST_ROOT_URL -siteLogoUrl $SITE_LOGO_URL -SCs $SCs -tag $tag

}

Function RefreshMain {
    param([parameter(Mandatory = $true)]$migrationSites, 
        $tag = "") 

    $SCs = Get-SiteCollectionList -siteCollectionList $migrationSites  -filterGroup $SERVER_ID 

    $srcCredentials = Get-Credential -UserName $SRC_USER_NAME -Message "Enter source password"
    $destCredentials = Get-Credential -UserName $DEST_USER_NAME -Message "Enter destination password"


    #Migrate all Site Collections
    $migrateArgs = @{OnContentItemExists = "Incremental";
        OnSiteObjectExists               = "Merge";
        OnWarning                        = "Continue";
        OnError                          = "Skip";
        ErrorAction                      = "Continue"; 
        WarningAction                    = "Continue" 
    }  
    $migratePhase = $MIGRATION_PHASE_REFRESH
    MigrateAll -migratePhase $migratePhase -migrateArgs $migrateArgs -unresolvedUserName $UNRESOLVED_USER_NAME -srcRootUrl $SRC_ROOT_URL -srcCredentials $srcCredentials -destCredentials $destCredentials -destRootUrl $DEST_ROOT_URL -SCs $SCs -tag $tag


    #set all site/sub-site list/libraries to classic experience
    Set-ExperienceAll -experience $EXPERIENCE_CLASSIC -credentials $destCredentials -rootUrl $DEST_ROOT_URL -SCs $SCs -tag $tag

    #set all site/sub-site logos
    Set-LogoAll  -credentials $destCredentials -rootUrl $DEST_ROOT_URL -siteLogoUrl $SITE_LOGO_URL -SCs $SCs -tag $tag

}