
Function Set-WebLogo($siteLogoUrl, $web) {
    try {
        Set-PnPWeb -SiteLogoUrl $siteLogoUrl -Web $web     
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host $ErrorMessage -ForegroundColor Red
    }
}

Function Set-SiteLogo($conn, $siteLogoUrl) {

    #set all lists in Root Web to use ClassicExperience
    $rootWeb = Get-PnPWeb -Connection $conn
    Set-WebLogo -web $rootWeb -siteLogoUrl $siteLogoUrl

    #set logo in all subwebs
    $subWebs = Get-PnPSubWebs -Recurse -Connection $conn
    foreach ($web in $subWebs) {
        Set-WebLogo -web $web -siteLogoUrl $siteLogoUrl
    }

}

Function Set-LogoAll($credentials, $rootUrl, $siteLogoUrl, $SCs, $tag = "") {
    
    foreach ($sc in $SCs) {

        $srcName = $sc.srcName
        $destName = $sc.destName + $tag

        $fullUrl = $rootUrl + $destName

   
        try {
            $conn = Connect-PnPOnline -ReturnConnection -Url $fullUrl -Credentials $credentials

            Write-Host -NoNewline "Setting Logo For "$destName -foregroundcolor Green

            Set-SiteLogo -conn $conn -siteLogoUrl $siteLogoUrl

            Write-Host " ...Done!" -foregroundcolor Green

            Disconnect-PnPOnline
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }

}