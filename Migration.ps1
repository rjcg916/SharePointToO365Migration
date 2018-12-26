$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

try {
    . ("$ScriptDirectory\Alerts.ps1")
  
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage -ForegroundColor Red
}


Set-Variable MIGRATION_PHASE_INITIAL    -value "Initial"
Set-Variable MIGRATION_PHASE_REFRESH    -value "Refresh"

Set-Variable MIGRATION_TYPE_STRUCTURAL  -value "Structural"
Set-Variable MIGRATION_TYPE_CONTENT     -value "Content"

Function MigrateSiteCollection {
    param([parameter(Mandatory = $true)] $migrationType, 
        [parameter(Mandatory = $true)] $migrateArgs, 
        [parameter(Mandatory = $true)] $unresolvedUserName,
        [parameter(Mandatory = $true)] $destName, 
        [parameter(Mandatory = $true)] $srcSite, 
        [parameter(Mandatory = $true)] $destSite) 
   
    #get CopySettings
    $copySettings = New-CopySettings @migrateArgs
   
    #mapping settings
    $mappingSettings = New-MappingSettings
    $mappingSettings = Set-UserAndGroupMapping -MappingSettings $mappingSettings -UnresolvedUserOrGroup -Destination $unresolvedUserName

    # generate file paths
    $dateStamp = Get-Date -Format FileDate
    $pathRoot = $destName.Replace('/', '-') 
    $xlsxPath = $pathRoot + "-" + $dateStamp + ".xlsx"

    Write-Host  "Migrating site to " $destName -foregroundColor Green

    if ($migrationType -eq $MIGRATION_TYPE_STRUCTURAL) {
        $result = Copy-Site -NoContent  -UserAlerts -Site $srcSite -DestinationSite  $destSite -InsaneMode   -Merge -Subsites -VersionLimit 1  -WaitForImportCompletion -CopySettings $copySettings -MappingSettings $mappingSettings 
    }
    else {
        $result = Copy-Site -UserAlerts -Site $srcSite -DestinationSite  $destSite -InsaneMode   -Merge -Subsites -VersionLimit 1  -WaitForImportCompletion -CopySettings $copySettings -MappingSettings $mappingSettings     
    }

    #export migration report
    Export-Report  -Overwrite $result -Path $xlsxPath 

    Write-host "...Done!" -foregroundcolor Green
    
}



Function MigrateSites {
    param([parameter(Mandatory = $true)] $migrationType, 
        [parameter(Mandatory = $true)] $Connections, 
        [parameter(Mandatory = $true)] $migrateArgs, 
        [parameter(Mandatory = $true)] $unresolvedUserName) 
    # use connections to run migrations (no user input required)

    foreach ($connection in $Connections) {
        try {      

            # perform the  migration
            MigrateSiteCollection -migrationType $migrationType -migrateArgs $migrateArgs -unresolvedUserName $unresolvedUserName -destName $connection.destName -srcSite $connection.srcSite -destSite $connection.destSite

        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }

}
Function MigrateAll {
    param([parameter(Mandatory = $true)] $migratePhase, 
        [parameter(Mandatory = $true)] $migrateArgs, 
        [parameter(Mandatory = $true)] $unresolvedUserName, 
        [parameter(Mandatory = $true)] $srcRootUrl, 
        [parameter(Mandatory = $true)] [Management.Automation.PSCredential] $srcCredentials, 
        [parameter(Mandatory = $true)] [Management.Automation.PSCredential] $destCredentials, 
        [parameter(Mandatory = $true)] $destRootUrl, 
        [parameter(Mandatory = $true)] $SCs, 
        $tag = "") 	

    # First, build a list of connections to source/destination sites
    # Then, use these connections to run migration 

    # NOTE: this separation allows input to be provided up-front and unattend
    # script execution
     

    # transform list of site collections to list of source and destination connections (user input required here)

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
            }
            else {
                Write-Host "Reusing Credentials for Site " $urlDest -ForegroundColor Green    
                $destSite = Connect-Site -Url $urlDest -UseCredentialsFrom $credentialsSite
            }

            #connect to source
            $urlSrc = $srcRootUrl + $srcName
            $srcSite = Connect-Site -Url $urlSrc -Credential $srcCredentials		

            $ConnectionProperties = @{destName = $destName; srcSite = $srcSite; destSite = $destSite; urlDest = $urlDest}  
            $ConnectionObject = New-Object PSObject –Property $ConnectionProperties

            $Connections += $ConnectionObject
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }


    # if this is first migration, perform structural migration first
    if ($MIGRATION_PHASE_INITIAL -eq $migratePhase) {
        
        MigrateSites  -migrationType $MIGRATION_TYPE_STRUCTURAL  -Connections $Connections -migrateArgs $migrateArgs -unresolvedUserName $unresolvedUserName
    
    }

    #turn off alerts
    
    Set-SiteAlertsByConnections -Credentials $destCredentials -Connections $Connections -Status "Off"

    #always do content migration
    MigrateSites -migrationType $MIGRATION_TYPE_CONTENT  -Connections $Connections -migrateArgs $migrateArgs -unresolvedUserName $unresolvedUserName

    #turn on alerts
    Set-SiteAlertsByConnections -Credentials $destCredentials -Connections $Connections -Status "On"

    
}