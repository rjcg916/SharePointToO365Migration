
Function MigrateSiteCollection($migrateArgs, $unresolvedUserName, $destName, $srcSite, $destSite) {
   
    #get CopySettings
    $copySettings = New-CopySettings @migrateArgs
   
    #mapping settings
    $mappingSettings = New-MappingSettings
    $mappingSettings = Set-UserAndGroupMapping -MappingSettings $mappingSettings -UnresolvedUserOrGroup -Destination $unresolvedUserName

    # generate file paths
    $dateStamp = Get-Date -Format FileDate
    $pathRoot = $destName.Replace('/', '-') 
    $xlsxPath = $pathRoot + "-" + $dateStamp + ".xlsx"
    $csvPath  = $pathRoot + "-" + $dateStamp + ".csv"

    Write-Host  "Migrating site to " $destName -foregroundColor Green

    #copy
    $result = Copy-Site  -Site $srcSite -DestinationSite  $destSite -InsaneMode   -Merge -Subsites -VersionLimit 1  -WaitForImportCompletion -CopySettings $copySettings -MappingSettings $mappingSettings 

    #export migration report
    Export-Report  -Overwrite $result -Path $xlsxPath 

    Write-host "...Done!" -foregroundcolor Green
    
}

Function MigrateAll($migrateArgs, $unresolvedUserName, $srcRootUrl, $srcCredentials, $destRootUrl, $SCs, $tag = "") {	

    # First, build a list of connections to source/destination sites
    # Then, use these connections to run migration 

    # NOTE: this separation allows input to be provided up-front and unattend
    # script execution
     
    # Part 1 of 2: transform list of site collections to list of source and destination connections (user input required here)

    $Connections = @()
    $credentialsSite = $null

    foreach ($sc in $SCs) {

        $srcName = $sc.srcName
        $destName = $sc.destName + $tag

        try {

            #connect to destination
            $urlDest = $destRootUrl + $destName

            if ($null -eq $credentialsSite ) {
                Write-Host "Enter Credentials for Site " $urlDest -ForegroundColor Green
                $destSite = Connect-Site -Url $urlDest -Browser
                $credentialsSite = $destSite
            } else {
                Write-Host "Reusing Credentials for Site " $urlDest -ForegroundColor Green    
                $destSite = Connect-Site -Url $urlDest -UseCredentialsFrom $credentialsSite
            }

            #connect to source
            $urlSrc = $srcRootUrl + $srcName
            $srcSite = Connect-Site -Url $urlSrc -Credential $srcCredentials		

            $ConnectionProperties = @{destName = $destName; srcSite = $srcSite; destSite = $destSite}  
            $ConnectionObject = New-Object PSObject –Property $ConnectionProperties

            $Connections += $ConnectionObject
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }


    # Part 2 of 2: use connections to run migrations (no user input required)

    foreach ($connection in $Connections) {
        try {            
            MigrateSiteCollection -migrateArgs $migrateArgs -unresolvedUserName $unresolvedUserName -destName $connection.destName -srcSite $connection.srcSite -destSite $connection.destSite      
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }
}

Function Migrate($srcCredentials, $srcRootUrl, $destRootUrl, $unresolvedUserName, $SCs, $tag = "") {

    $migrateArgs = @{OnContentItemExists = "Overwrite";
                      OnSiteObjectExists = "Merge";
                      OnWarning = "Continue";
                      OnError = "Skip";
                      ErrorAction = "Continue";
                      WarningAction = "Continue" 
    }

    #Migrate all Site Collections
    MigrateAll -migrateArgs $migrateArgs -unresolvedUserName $unresolvedUserName -srcRootUrl $srcRootUrl -srcCredentials $srcCredentials -destRootUrl $destRootUrl -SCs $SCs -tag $tag
}

Function Refresh($srcCredentials, $srcRootUrl, $adminUrl, $userName, $destRootUrl, $unresolvedUserName, $SCs, $tag = "") {
     $migrateArgs = @{OnContentItemExists = "Incremental";
                      OnSiteObjectExists = "Merge";
                      OnWarning = "Continue";
                      OnError = "Skip";
                      ErrorAction = "Continue"; 
                      WarningAction = "Continue" 
    }  

    #Migrate all Site Collections
    MigrateAll -migrateArgs $migrateArgs -unresolvedUserName $unresolvedUserName -srcRootUrl $srcRootUrl -srcCredentials $srcCredentials -destRootUrl $destRootUrl -SCs $SCs -tag $tag
}