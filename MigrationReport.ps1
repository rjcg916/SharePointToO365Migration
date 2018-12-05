Function Convert-ExcelToCsv {
    <#
.DESCRIPTION
Will convert a XLSX to a CSV.
.PARAMETER Path
The path to the XLSX to convert
.PARAMETER OutputPath
The path to output the CSV to
#>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript( { Test-Path $_ -PathType Leaf })]
        [ValidateScript( { (Get-Item $_).Extension -match '.*\.xls[x]?$' })]
        [string] $Path,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript( { Test-Path (Split-Path $_) -PathType Container })]
        [ValidateScript( {  $_ -like '*.csv' })]
        [string] $OutputPath 
    )
	
    Process {
        if (!($PsBoundParameters.ContainsKey('Path'))) { $Path = $_ }
		
        if (Test-Path $OutputPath) { Remove-Item $OutputPath -Force }
		
        #Now create some Excel objects, and just save the file, specifying type 6, which is a CSV
        $Excel = New-Object -ComObject Excel.Application
        $Workbook = $Excel.Workbooks.Open($Path)
        $Workbook.SaveAs($OutputPath, 6)
        $Excel.Quit()
    }
	
    End {
        #Do our best to cleanup.  Unfortunately even this doesn't work most times
        [Void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($Workbook)
        [Void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($Excel)
		
        if (Get-Process excel -ErrorAction 'SilentlyContinue') { Get-Process excel | Stop-Process -Force }
		
        Remove-Variable Workbook
        Remove-Variable Excel
        Write-Output $OutputPath
    }
}

Function Get-MigrationReport($srcPath, $destPath)
{
    
    #generate filtered CSV output 

    Convert-ExcelToCsv   -Path $srcPath -OutputPath $destPath

    $Csv = Import-Csv $destPath
            
    $FilteredCsv = $Csv | Where-Object { 
                                  (($_.Status -eq 'Error')   -or  
                                   ($_.Status -eq 'Warning')     ) -and
                                  ($_.Title -ne 'MicroFeed')   -and
                                  ($_.Type -ne 'User')  -and ($_.Type -ne 'Group') -and
                                  ($_.Details -notlike '*Cannot make the form template browser enabled.*') -and 
                                  ($_.Details -notlike '*address exceeds the limit of 255 characters*') -and 
                                  ($_.Details -notlike '*not supported by the Insane Mode*')  -and 
                                  ($_.Details -notlike '*The following values are unavailable*')  -and 
                                  ($_.Details -notlike '*This content type contains an InfoPath form.*')  -and 
                                  ($_.Details -notlike '*access requests settings were not copied*')  -and
                                  ($_.Details -notlike '*The text was truncated*')  -and
                                  ($_.Details -notlike '*parent content type is missing, the closest parent content type*')  -and
                                  ($_.Details -notlike '*The default site template*') -and 
                                  ($_.Details -notlike '*This value is required.*') -and
                                  ($_.Details -notlike '*When migrating managed metadata*') -and
                                  ($_.Details -notlike '*Document ID Service feature cannot be automatically activated.*') -and
                                  ($_.Details -notlike '*are not currently supported by the Insane Mode*') -and
                                  ($_.Details -notlike '*there are multiple matching items at the destination*') -and
                                  ($_.Details -notlike '*Show item-level*') -and
                                  ($_.Details -notlike '*was created with the default list template*') -and
                                  ($_.Details -notlike '*correct zone could not be found*') -and 
                                  ($_.Details -notlike '*user does not exist or is not unique*') -and
                                  ($_.Details -notlike '*Item does not exist.*')
                                 }
    
    $FilteredCsv | Export-Csv  -Path $destPath -Force
}

Function MigrationReportAll($scanDirectory)
{
    Write-Host  "Creating Migration Reports . . . " -foregroundColor Green    
  
    Get-ChildItem -Path $scanDirectory -Filter *.xlsx   -File -Name| ForEach-Object {
        $fullName =  $scanDirectory + [System.IO.Path]::GetFileNameWithoutExtension($_)

        Get-MigrationReport -srcPath "$fullName.xlsx" -destPath "$fullName.csv"
    }

    Get-Content "$scanDirectory/*.csv" -Exclude "$scanDirectory/migration_summary.csv"  -Delimiter "*---*" -Force -Encoding UTF8 | Set-Content "$scanDirectory/migration_summary.csv"

    Write-Host  "Summary Report created in $scanDirectory/migration_summary.csv" -foregroundColor Green 
}
