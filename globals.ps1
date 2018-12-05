#Set Environment/User Values

Set-Variable  SRC_USER_NAME         -value  ""
Set-Variable  UNRESOLVED_USER_NAME  -value  ""

Set-Variable  SRC_ROOT_URL          -value  "https://www.acme.com/" 
Set-Variable  DEST_ADMIN_URL        -value  "https://acme-admin.sharepoint.com/"
Set-Variable  DEST_ROOT_URL         -value  "https://acme.sharepoint.com/"
Set-Variable  SITE_LOGO_URL         -value  "https://acme.sharepoint.com/SiteAssets/acmelogo.png"

Set-Variable  SERVER_PREFIX         -value  "SERVER"
  
try {
    Set-Variable  SERVER_ID             -value $env:computername.Substring($SERVER_PREFIX.Length + 1)
    Set-Variable  DEST_USER_NAME        -value "SG$SERVER_ID.service@advantagesolutions.net"
} catch {
    $SERVER_ID       = Read-Host 'Server Id (e.g. 1)?'
    $SERVER_ID
    $DEST_USER_NAME  = Read-Host 'Destination User Name (e.g. fredg@acme.net)?'
    $DEST_USER_NAME
}

# Utility Function

Function Get-SiteCollectionList($siteCollectionList, $filterGroup) {
    $SCs = @()
    Import-Csv $siteCollectionList |
        ForEach-Object { `
            if (($filterGroup -eq $_.Group) -or $filterGroup -eq "") {
            	$DestinationSite = $_.Site -replace "clients/", "sites/client-"
            	$props = @{srcName = $_.Site; destName = $DestinationSite; Group = $_.Group; UpdateLogo = $_.UpdateLogo}  
            	$site = New-Object PSObject -Property $props       
            	$SCs += $site
        }
    } 
    return $SCs
}
