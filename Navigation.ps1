Function Get-WebNavLinks ($path, $rootWeb, $web) {
   
    Function Get-Nodes($path, $location, $nodes, $webUrl, $rootWeb) {
        foreach ($node in $nodes) {
    
            $nodeUrl = $node.url.Trim()
            $title = $node.Title.Replace(',', ' ')
            if ($nodeUrl.length -gt 1) {  
         
                $output = $nodeUrl + ", " + $title + ", " + $location + ", " + $webUrl
                
                $flag = `
                            ($nodeUrl.IndexOf($rootWeb) -eq -1) `
                        -or ($nodeUrl -like '*List=*') `
                        -or ($nodeUrl.IndexOf('{') -ne -1) 
                
                if ($flag) {
                    Add-Content -Path $path -Value $output
                }

            }
        }
    }
    
    $location = "Quick Links"
    $nodes = Get-PnPNavigationNode -Location QuickLaunch -Web $web.Id
    Get-Nodes -path $path  -location $location -webUrl $web.ServerRelativeUrl -nodes $nodes -rootWeb $rootWeb.ServerRelativeUrl

    $location = "Top Nav"
    $nodes = Get-PnPNavigationNode -Location TopNavigationBar -Web $web.Id 
    Get-Nodes -path $path -location $location -webUrl $web.ServerRelativeUrl -nodes $nodes -rootWeb $rootWeb.ServerRelativeUrl

}

Function Get-SiteNavLinks ($path, $conn) {
 
    $rootWeb = Get-PnPWeb -Connection $conn
    Get-WebNavLinks -path $path -rootWeb $rootWeb -web $rootWeb
    
    $subWebs = Get-PnPSubWebs -Recurse -Connection $conn
    foreach ($web in $subWebs) {
        Get-WebNavLinks -path $path -rootWeb $rootWeb -web $web
    }
}

Function Get-NavAll($credentials, $rootUrl, $SCs, $outputPath, $tag = "") {

    Out-File -FilePath $outputPath  
    Add-Content  -Path $outputPath -Value '"Url","Title","Location"'
        
    foreach ($sc in $SCs) {

        $destName = $sc.destName + $tag
        $fullUrl = $rootUrl + $destName

        try {
            $conn = Connect-PnPOnline -ReturnConnection -Url $fullUrl -Credentials $credentials 

            Write-Host -NoNewline "Exporting Navigation Links From "$destName -foregroundcolor Green
          
            Get-SiteNavLinks -path $outputPath -conn $conn

            Write-Host " ...Done!" -foregroundcolor Green

            Disconnect-PnPOnline
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }

    Write-Host "Export Complete . . . see "$outputPath -foregroundcolor Green

}
