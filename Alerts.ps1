Function Set-WebAlerts {
    param([parameter(Mandatory = $true)]$web, 
        [parameter(Mandatory = $true)]$status) 
   
    if ($web.Alerts) {
        foreach ($alert in $web.Alerts) {   
            $alert.Status = $status
            $alert.UpdateAlert();
            Write-Host "Alert $($alert.Title) Updated to $($status)"
        }
    }
}

Function Set-SiteAlerts {
    param([parameter(Mandatory = $true)]$conn, 
        [parameter(Mandatory = $true)]$status) 
    $rootWeb = Get-PnPWeb -Connection $conn -Includes Alerts

    Set-WebAlerts -web $rootWeb -status $status

    $subWebs = Get-PnPSubWebs -Recurse -Connection $conn -Includes Alerts
    foreach ($web in $subWebs) {
        Set-WebAlerts -web $web -status $status
    }
}

Function Set-SiteAlertsByUrl {
    param([parameter(Mandatory = $true)][Management.Automation.PSCredential] $credentials, 
        [parameter(Mandatory = $true)]$url, 
        [parameter(Mandatory = $true)] $status) 
    try {
        $conn = Connect-PnPOnline -ReturnConnection -Url $url -Credentials $credentials

        Write-Host   "Setting Alerts For "$url -foregroundcolor Green
      
        Set-SiteAlerts -conn $conn -status $status

        Write-Host " ...Done!" -foregroundcolor Green

        Disconnect-PnPOnline
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host $ErrorMessage -ForegroundColor Red
    }

}

Function Set-SiteAlertsByConnections {
    param([parameter(Mandatory = $true)] [Management.Automation.PSCredential] $credentials, 
        [parameter(Mandatory = $true)]$Connections, 
        [parameter(Mandatory = $true)]$status) 

    foreach ($conn in $Connections) {
        try {      
            Set-SiteAlertsByUrl -credentials $credentials -url $conn.urlDest -status $status
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }

}


Function Set-AlertsAll {
    param([parameter(Mandatory = $true)][Management.Automation.PSCredential] $credentials, 
        [parameter(Mandatory = $true)] $rootUrl, 
        [parameter(Mandatory = $true)] $SCs, 
        [parameter(Mandatory = $true)] $status, 
        $tag = "") 
    
    foreach ($sc in $SCs) {

        $destName = $sc.destName + $tag

        $fullUrl = $rootUrl + $destName
 
        try {
            $conn = Connect-PnPOnline -ReturnConnection -Url $fullUrl -Credentials $credentials

            Write-Host   "Seting Alerts For "$destName -foregroundcolor Green
          
            Set-SiteAlerts -conn $conn -status $status

            Write-Host " ...Done!" -foregroundcolor Green

            Disconnect-PnPOnline
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }

}
