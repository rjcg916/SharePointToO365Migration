Function PurgeSiteCollection {
    param([parameter(Mandatory = $true)]$url)

    # delete site collection if it exists
    try {
        Remove-SPOSite -Identity $url
    } 
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host $ErrorMessage -ForegroundColor Red      
    }

    # remove site collection from recycle bin
    try {
        Remove-SPODeletedSite -Identity $url
    } 
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host $ErrorMessage -ForegroundColor Red     
    }

}

Function PurgeAll {
    param([parameter(Mandatory = $true)] $adminUrl, 
        [parameter(Mandatory = $true)] $rootUrl, 
        [parameter(Mandatory = $true)][Management.Automation.PSCredential] $credentials, 
        [parameter(Mandatory = $true)] $SCs, 
        $tag = "") 

    Connect-SPOService -Url $adminUrl -Credential $credentials
	
    foreach ($sc in $SCs) {

        $destName = $sc.destName + $tag
        $url = $rootUrl + $destName

        try {

            PurgeSiteCollection -url $url 
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }

    Disconnect-SPOService

}
Function CreateSiteCollection {
    param([parameter(Mandatory = $true)]$userName, 
        [parameter(Mandatory = $true)]$url, 
        [parameter(Mandatory = $true)]$siteName) 

    New-SPOSite  -Title $siteName -Owner $userName  -Url $url -StorageQuota 26214400  -TimeZoneId 13 -LocaleId 1033  -Template STS#0
    Set-SPOUser -Site $url  -LoginName $userName -IsSiteCollectionAdmin $True

}

Function CreateAll {
    param([parameter(Mandatory = $true)] [Management.Automation.PSCredential] $credentials, 
        [parameter(Mandatory = $true)]$adminUrl, 
        [parameter(Mandatory = $true)]$userName, 
        [parameter(Mandatory = $true)]$rootUrl, 
        [parameter(Mandatory = $true)]$SCs, 
        $tag = "") 
	
    Connect-SPOService -Url $adminUrl -Credential $credentials
	
    foreach ($sc in $SCs) {
        
        $siteName = $sc.destName.Substring($sc.destName.LastIndexOf('/') + 1)  #remove path from siteName

        $destName = $sc.destName + $tag
        $url = $rootUrl + $destName

        try {
            Write-host "Creating "$destName -foregroundcolor Green
             
            CreateSiteCollection -userName $userName -url $url -siteName $siteName
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }

    Disconnect-SPOService
}
