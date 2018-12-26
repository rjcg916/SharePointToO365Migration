Function New-WebModernPages {
    param()

    #IMPORTANT: this function requires the PnP PowerShell version 3.4.1812 (December 2018) or higher to work!
                  
    # Get all the pages in the site pages library
    $pages = Get-PnPListItem  -List sitepages
    
    # Iterate over the pages
    foreach ($page in $pages) { 

        # No need to convert modern pages again
        if ($page.FieldValues["ClientSideApplicationId"] -eq "b6917cb1-93a0-4b97-a84d-7cf49975d4ec" ) { 
            Write-Host `Page $page.FieldValues["FileLeafRef"] is modern, no need to modernize it again`
        } 
        else { 
            # Create a modern version of this page
            Write-Host  `Modernizing $page.FieldValues["FileLeafRef"]...`
            ConvertTo-PnPClientSidePage  -Identity $page.FieldValues["FileLeafRef"] -TakeSourcePageName -Overwrite 
                  
        }     
    }   
}

Function New-SiteModernPages {
    param([parameter(Mandatory = $true)]$conn) 

    #set all lists in Root Web 
    $rootWeb = Get-PnPWeb -Connection $conn
   
    # Need to reset connection to each web
    Connect-PnPOnline -Url $rootWeb.url -Credentials $credentials
    Write-Host  `Modernizing $rootWeb.url...`
    New-WebModernPages
 
    #set all lists in Subwebs 
    $subWebs = Get-PnPSubWebs -Recurse -Connection $conn
    foreach ($web in $subWebs) {
        # Need to reset connection to each web     
        Connect-PnPOnline -Url $web.Url -Credentials $credentials
        Write-Host  `Modernizing $web.url...`
        New-WebModernPages 
    }
    
}


Function New-ModernPagesAll {
    param([parameter(Mandatory = $true)][Management.Automation.PSCredential] $credentials, 
        [parameter(Mandatory = $true)]$rootUrl, 
        [parameter(Mandatory = $true)]$SCs, 
        [parameter(Mandatory = $true)]$tag) 
 
    foreach ($sc in $SCs) {

        $destName = $sc.destName + $tag

        $fullUrl = $rootUrl + $destName

        try {
            $conn = Connect-PnPOnline -ReturnConnection -Url $fullUrl -Credentials $credentials

            Write-Host  "Creating Modern Pages For "$destName -foregroundcolor Green
      
            New-SiteModernPages -conn $conn 

            Write-Host " ...Done!" -foregroundcolor Green

            Disconnect-PnPOnline
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }

}

