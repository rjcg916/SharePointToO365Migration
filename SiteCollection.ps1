Function PurgeSiteCollection($url)
{

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

Function PurgeAll($adminUrl, $rootUrl, $credentials, $SCs, $tag = "") {

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
Function CreateSiteCollection($userName, $url, $siteName) {



    New-SPOSite  -Title $siteName -Owner $userName  -Url $url -StorageQuota 26214400  -TimeZoneId 13 -LocaleId 1033  -Template STS#0
    Set-SPOUser -Site $url  -LoginName $userName -IsSiteCollectionAdmin $True

}

Function CreateAll($credentials, $adminUrl, $userName, $rootUrl, $SCs, $tag = "") {
	
    Connect-SPOService -Url $adminUrl -Credential $credentials
	
    foreach ($sc in $SCs) {

        $destName = $sc.destName + $tag
        $url = $rootUrl + $destName

        try {
            Write-host "Creating "$destName -foregroundcolor Green
             
            CreateSiteCollection -userName $userName -url $url -siteName $destName
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }

    Disconnect-SPOService
}
