Function Set-WebListClassicExperience($web) {

    $lists = Get-PnPList -Web $web.id 
    
    foreach ($list in $lists) {
        try {
            Set-PnPList -ListExperience ClassicExperience -Web $web -Identity $list.Id       
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }
}

Function Set-SiteListClassicExperience($conn) {

    ## Set Site Collection to Classic Mode

    $siteFeatureId = "E3540C7D-6BEA-403C-A224-1A12EAFEE4C4" 
    #Disable-PnPFeature  -Identity $siteFeatureId # set to modern mode
    Enable-PnPFeature  $siteFeatureId # set to classic mode

    $docFeatureId = "52E14B6F-B1BB-4969-B89B-C4FAA56745EF"
    #Disable-PnPFeature  -Identity $docFeatureId # set to modern mode
    Enable-PnPFeature  $docFeatureId # set to classic mode

    #set all lists in Root Web to use ClassicExperience

    $rootWeb = Get-PnPWeb -Connection $conn
    Set-WebListClassicExperience -web $rootWeb

    #set all lists in Subwebs to use ClassicExperience
    $subWebs = Get-PnPSubWebs -Recurse -Connection $conn
    foreach ($web in $subWebs) {
        Set-WebListClassicExperience -web $web
    }

}
Function Set-ClassicExperienceAll($credentials, $rootUrl, $SCs, $tag = "") {
    
    foreach ($sc in $SCs) {

        $srcName = $sc.srcName
        $destName = $sc.destName + $tag

        $fullUrl = $rootUrl + $destName
 
        try {
            $conn = Connect-PnPOnline -ReturnConnection -Url $fullUrl -Credentials $credentials

            Write-Host  -NoNewline "Seting Classic Experience For "$destName -foregroundcolor Green
          
            Set-SiteListClassicExperience -conn $conn

            Write-Host " ...Done!" -foregroundcolor Green

            Disconnect-PnPOnline
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }
}