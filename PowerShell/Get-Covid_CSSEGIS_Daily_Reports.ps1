<#
Title:          Get-Covid_CSSEGIS_Daily_Reports.ps1
Description:    Create an CSV file based on all of the daily reports from https://github.com/CSSEGISandData/COVID-19 in the https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_daily_reports folder.
Author:         Bill Ramos, DB Best Technologies

#>

$GitLocalRoot = Get-Location
$LeafDataFile = "CSSEGISandData-COVID-19-Derived"
$DataDir = "Data-Files"
$GitSourceAccount = "CSSEGISandData"
$GitSourceProject = "COVID-19"
$GitBranch = "master"
$GitRawRoot = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/"
$TempDataLocation = $GitLocalRoot, "\", 'Working Files\' -join ""



$LocalDataFile = $GitLocalRoot, "\", $DataDir, "\", $LeafDataFile, ".csv" -join ""
$LocalMetadataFile = $GitLocalRoot, "\", $DataDir, "\", $LeafDataFile, ".csv" -join ""

$URLs = @{
    URLReports            = "https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_daily_reports"
    SourceWebSite         = "https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data"
    SourceMetadataInfo    = "https://github.com/CSSEGISandData/COVID-19"
    DBBestDerivedData     = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/", $DataDir, "/", $LeafDataFile, ".csv" -join ""
    DBBestDerivedMetadata = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/", $DataDir, "/", $LeafDataFile, ".json" -join ""
    GitHubRoot            = "https://github"
}

$WR = Invoke-WebRequest -Uri $URLs.URLReports
$URLs.Add( "SourceDataURI", $WR.BaseResponse.RequestMessage.RequestUri.AbsoluteUri )
$URLs.Add( "SourceAuthority", $WR.BaseResponse.RequestMessage.RequestUri.Authority )
$URLs.Add( "RetrievedOnUTC", $WR.BaseResponse.Headers.Date.UtcDateTime )
$URLs.Add( "RetrievedOnPST", $WR.BaseResponse.Headers.Date.LocalDateTime )

$CSVLinks = @()
foreach ( $Link in $WR.Links) {
    if ( $Link.href -like "*2020.csv" ) {
        $CSVFileName = Split-Path -Path $Link.href -Leaf
        $PeriodEnding = $CSVFileName.Split(".")[0]
        $CSVRawURL = $GitRawRoot, $CSVFileName -join "/"
        $CSVPageURL = $URLs.URLReports, $CSVFileName -join "/"
        $WR_CSV = Invoke-WebRequest -Uri $CSVRawURL
        $WR_CSV.Content | Out-File -FilePath ($TempDataLocation, $CSVFileName -join "")
        $CSVData = Import-Csv -Path ($TempDataLocation, $CSVFileName -join "")
        $CSVData | Add-Member -MemberType NoteProperty -Name "Period Ending Date UTC" -Value $PeriodEnding

        $WR_Page = Invoke-WebRequest -Uri $CSVPageURL
        $DateLastModifiedUTC = $WR_Page.Content.split("<relative-time datetime=")[1].Split(" class=")[0]
        $CSVData | Add-Member -MemberType NoteProperty -Name "Source File Last Updated UTC" -Value $DateLastModifiedUTC

        $FileInfo = @{
            CsvFileName = $CSVFileName
            CsvTodayKey = Get-Date -Date $CsvFileName.Split(".")[0] -Format "MM/dd/yyyy"
            CsvYesterdayKey = Get-Date -Date (Get-Date -Date $CsvFileName.Split(".")[0] ).AddDays(-1) -Format "MM/dd/yyyy"
            CSVRawURL   = $CSVRawURL
            CSVPageURL  = $CSVPageURL
            CSVData     = $CSVData
            DateLastModifiedUTC = $DateLastModifiedUTC.Split("`"")[1]
        } 
        $CsvLinks += $FileInfo
    }
}

# Work the data in the $CSVLinks array by the CsvTodayKey (report date)
$SortedCSVs = $CSVLinks | Sort-Object -Property CsvTodayKey 
#Clear out the old array to release memory
Remove-Variable 'CSVLinks'


foreach ($Csv in $SortedCSVs){
   Write-Host "CsvFileName=", $Csv.CsvFileName , " and ModifiedDate= ", (Get-Date -date $Csv.DateLastModifiedUTC).ToUniversalTime()
}
$SortedCSVs[0].CsvData[0].'Country/Region'
$SortedCSVs[1].CsvData[0].'Country/Region'

$i = $SortedCSVs.Count - 1
$Today = $SortedCSVs[$i].CSVData | Where-Object {$_.Combined_Key-eq "Clark, Nevada, US"}
$Yesterday = $SortedCSVs[$i-1].CSVData | Where-Object {$_.Combined_Key -eq "Clark, Nevada, US"}
$Today.Active = $Today.Confirmed - $Today.Deaths - $Today.Recovered
$Today.Confirmed, $Today.Deaths, $Today.Recovered, $Today.Active
$Yesterday.Confirmed, $Yesterday.Deaths, $Yesterday.Recovered, $Yesterday.Active



$HTMLStates.Content | Out-File -FilePath "C:\Temp\States.csv"
$StatesCsv = Import-Csv -Path "C:\Temp\States.csv"




