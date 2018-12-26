Set-Variable EXPERIENCE_MODERN   -value "NewExperience"
Set-Variable EXPERIENCE_CLASSIC  -value "ClassicExperience"

Function Set-WebListExperience {
    param (   [parameter(Mandatory = $true)]$web, 
        [parameter(Mandatory = $true)]$experience) 

    
    $lists = Get-PnPList -Web $web.id 
    
    foreach ($list in $lists) {
        try {
            Set-PnPList -ListExperience  $experience -Web $web -Identity $list.Id       
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }
}

Function Set-SiteListExperience {
    param ([parameter(Mandatory = $true)]$conn, 
        [parameter(Mandatory = $true)]$experience) 

    $siteFeatureId = "E3540C7D-6BEA-403C-A224-1A12EAFEE4C4" 
    $docFeatureId = "52E14B6F-B1BB-4969-B89B-C4FAA56745EF"

    ## Set Site Collection 
    if ($experience -eq $EXPERIENCE_MODERN ) {
        Disable-PnPFeature  -Identity $siteFeatureId # set to modern mode
        Disable-PnPFeature  -Identity $docFeatureId # set to modern mode
    } 

    if ($experience -eq $EXPERIENCE_CLASSIC ) {
        Enable-PnPFeature  $siteFeatureId # set to classic mode    
        Enable-PnPFeature  $docFeatureId # set to classic mode
    }


    #set all lists in Root Web 
    $rootWeb = Get-PnPWeb -Connection $conn
    Set-WebListExperience -web $rootWeb -experience $experience

    #set all lists in Subwebs 
    $subWebs = Get-PnPSubWebs -Recurse -Connection $conn
    foreach ($web in $subWebs) {
        Set-WebListExperience -web $web -experience $experience
    }

}

Function Set-ExperienceAll {
    param([parameter(Mandatory = $true)][Management.Automation.PSCredential] $credentials, 
        [parameter(Mandatory = $true)]$rootUrl, 
        [parameter(Mandatory = $true)]$SCs, 
        [parameter(Mandatory = $true)]$experience, 
        $tag = "") 
    
    foreach ($sc in $SCs) {

        $destName = $sc.destName + $tag

        $fullUrl = $rootUrl + $destName
 
        try {
            $conn = Connect-PnPOnline -ReturnConnection -Url $fullUrl -Credentials $credentials

            Write-Host  "Setting "$experience " For "$destName -foregroundcolor Green
          
            Set-SiteListExperience -conn $conn -experience $experience

            Write-Host " ...Done!" -foregroundcolor Green

            Disconnect-PnPOnline
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }
}
