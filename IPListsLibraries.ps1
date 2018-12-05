[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint") > $null
#Get the web application
Write-Host "Enter the Web Application URL:"
$WebAppURL = Read-Host
$SiteColletion = Get-SPSite($WebAppURL)
$WebApp = $SiteColletion.WebApplication
#Write the CSV header
"Site Collection `t Site `t List Name `t List Url `t Docs Count `t Last Modified `t Form Template" > InfoPathLibs.csv
#Loop through all site collections of the web app
foreach ($site in $WebApp.Sites) {
    # get the collection of webs
    foreach ($web in $site.AllWebs) {
        write-host "Scaning Site" $web.title "@" $web.URL
        foreach ($list in $web.lists) {
            if ( $list.BaseType -eq "DocumentLibrary" -and $list.BaseTemplate -eq "XMLForm") {
                $listModDate = $list.LastItemModifiedDate.ToShortDateString()
                $listTemplate = $list.ServerRelativeDocumentTemplateUrl
                #Write data to CSV File
                $site.RootWeb.Title + "`t" + $web.Title + "`t" + $list.title + "`t" + $Web.Url + "/" + $List.RootFolder.Url + "`t" + $list.ItemCount + "`t" + $listModDate + "`t" + $listTemplate >> InfoPathLibs.csv
            }
            elseif ($list.ContentTypes[0].ResourceFolder.Properties["_ipfs_infopathenabled"]) {
                $listModDate = $list.LastItemModifiedDate.ToShortDateString()
                $listTemplate = $list.ServerRelativeDocumentTemplateUrl
                #Write data to CSV File
                $site.RootWeb.Title + "`t" + $web.Title + "`t" + $list.title + "`t" + $Web.Url + "/" + $List.RootFolder.Url + "`t" + $list.ItemCount + "`t" + $listModDate + "`t" + $listTemplate >> InfoPathLibs.csv
            }
        }
    }
}
#Dispose of the site object
$siteColletion.Dispose()
Write-host  "Report Generated at same path of the powershell script InfoPathLibs.csv" -foregroundcolor green