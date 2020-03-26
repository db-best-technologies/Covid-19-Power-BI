<#
Title:       Get-Covid_CSSEGIS_Daily_Reports.ps1
Description: Create an CSV file based on daily reports from in the https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_daily_reports folder.
Author:      Bill Ramos, DB Best Technologies
MoreInfo:    https://github.com/db-best-technologies/Covid-19-Power-BI/blob/master/PowerShell/Get-Covid_CSSEGIS_Daily_Reports.yaml
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

$ColumnHeaders = @{
    "01-22-2020" = @('Province/State', 'Country/Region', 'Last Update', 'Confirmed,Deaths', 'Recovered')
    "03-11-2020" = @('Province/State', 'Country/Region', 'Last Update', 'Confirmed,Deaths', 'Recovered', 'Latitude', 'Longitude')
    "03-22-2020" = @('FIPS', 'Admin2', 'Province_State', 'Country_Region', 'Last_Update', 'Lat', 'Long_', 'Confirmed', 'Deaths', 'Recovered', 'Active', 'Combined_Key')
}
$NewColumnsMapping = [PSCustomObject]@{
    'FIPS'           = "FIPS county code"
    'Admin2'         = "County"
    'Province_State' = "Province or State"
    'Country_Region' = "Country or Region"
    'Last_Update'    = "Last Updated UTC"
    'Last Update'    = "Last Updated UTC"
    'Lat'            = "Latitude"
    'Long_'          = "Longitude"
    'Confirmed'      = "Confirmed"
    'Deaths'         = "Deaths"
    'Recovered'      = "Recovered"
    'Active'         = "Active"
    'Combined_Key'   = "Location Name Key"
    'Province/State' = "Province or State"
    'Country/Region' = "Country or Region"
    'Latitude'       = "Latitude"
    'Longitude'      = "Longitude"
    'CSV File Name'  = 'CSV File Name'
}
$CSVLinks = @()
$FilesInfo = @()
foreach ( $Link in $WR.Links) {
    if ( $Link.href -like "*2020.csv" ) {

        # Using the data in the $Link.href string, parse out the file name to use to grab the actual csv data from the GitHub
        $CSVFileName = Split-Path -Path $Link.href -Leaf
        $CSVRawURL = $GitRawRoot, $CSVFileName -join "/"
        $CSVPageURL = $URLs.URLReports, $CSVFileName -join "/"

        # Get the daily CSV file using the $CSVRawURL
        $WR_CSV = Invoke-WebRequest -Uri $CSVRawURL

        # To load the CSV correctly into memory, we need to write it out to a file and read it back in. 
        $WR_CSV.Content | Out-File -FilePath ($TempDataLocation, $CSVFileName -join "")

        # The end result is each record is added as a PSCustomObject to the $CSVData array.
        $CSVData = Import-Csv -Path ($TempDataLocation, $CSVFileName -join "")


        # Retrieve the GitHub page for the CSV file to pull out the date for the last check-in
        $WR_Page = Invoke-WebRequest -Uri $CSVPageURL
        $DateLastModifiedUTC = $WR_Page.Content.split("<relative-time datetime=")[1].Split(" class=")[0]
        if ($DateLastModifiedUTC -like '"*') { $DateLastModifiedUTC = $DateLastModifiedUTC.Split('"')[1] }

        # Add all the file name to the records so they can be related to new Daily-Files-Metadata.csv for data lineage
        $PeriodEnding = $CSVFileName.Split(".")[0]   # This takes 02-01-2020.CSV and removes the .CSV
        $CSVData | Add-Member -MemberType NoteProperty -Name 'CSV File Name' -Value $CSVFileName


        $FileMetadata = @{
            CsvFileName         = $CSVFileName
            PeriodEnding        = $PeriodEnding
            CSVRawURL           = $CSVRawURL
            CSVPageURL          = $CSVPageURL
            DateLastModifiedUTC = $DateLastModifiedUTC
        } 
        $FilesInfo += [PSCustomObject]$FileMetadata

        $FileMetadata.Add('CSVData', $CSVData)

        $CsvLinks += $FileMetadata

        # Write back out the CSV files to Temp location for debugging
        $CSVData | Export-Csv -path ($TempDataLocation, $CSVFileName -join "") -NoTypeInformation
    }
}

$FilesInfo | Export-Csv -Path ($GitLocalRoot, "\", $DataDir, "\", "Daily-Files-Metadata.csv" -join "") -NoTypeInformation

# Work the data in the $CSVLinks array by the CsvTodayKey (report date)
$SortedCSVs = $CSVLinks | Sort-Object -Property CsvFileName 

#Check to make sure the array is sorted
$SortedCSVs[0].CsvData[0].'Country/Region', $SortedCSVs[0].CsvData[0].'CSV File Name' -join " - "
$SortedCSVs[1].CsvData[0].'Country/Region', $SortedCSVs[1].CsvData[0].'CSV File Name' -join " - "


#Clear out the old array to release memory
Remove-Variable 'CSVLinks'

# Go through array of $SortedCSVs fix up and flatten the data for Confirmed,Deaths,Recovered,Active
for ( $f = 0; $f -lt $SortedCSVs.count ) {
    $Csv = $SortedCSVs[$f]
    Write-Host "CsvFileName=", $Csv.CsvFileName , " and ModifiedDate= ", (Get-Date -date $Csv.DateLastModifiedUTC).ToUniversalTime()
    $Columns = $null
    if ( $Csv.PeriodEnding -le [datetime]'03-10-2020' ) {
        $Columns = $ColumnHeaders.'01-22-2020'
    }
    elseif ( $Csv.PeriodEnding -gt [datetime]'03-10-2020' -and $Csv.PeriodEnding -le [datetime]'03-21-2020' ) {
        $Columns = $ColumnHeaders.'03-11-2020'
    }
    else {
        $Columns = $ColumnHeaders.'03-22-2020'
    }
    $ActualColumns = $Csv.CSVData[0].psobject.properties.name
    foreach ( $Row in $Csv.CSVData ) {
        $Mapping = @{ }
        for ($i = 0; $i -lt $ActualColumns.Count; $i++ ) {

            $Key =  $NewColumnsMapping.($ActualColumns[$i])
            if ( $Key -eq "Last Updated UTC"){
                $Value = Get-Date -Date $Row.($ActualColumns[$i]) -Format "yyyy-MM-ddTHH:mm:ss"
            }
            else{
                $Value =  $Row.($ActualColumns[$i])
            }
            
            $Mapping.Add( $Key, $Value )
        }
        

    }
    break
}

$i = $SortedCSVs.Count - 1
$Today = $SortedCSVs[$i].CSVData | Where-Object { $_.Combined_Key -eq "Clark, Nevada, US" }
$Yesterday = $SortedCSVs[$i - 1].CSVData | Where-Object { $_.Combined_Key -eq "Clark, Nevada, US" }
$Today.Active = $Today.Confirmed - $Today.Deaths - $Today.Recovered
$Today.Confirmed, $Today.Deaths, $Today.Recovered, $Today.Active
$Yesterday.Confirmed, $Yesterday.Deaths, $Yesterday.Recovered, $Yesterday.Active

$Today.Lat
$RenameColumn = = @{
    TypeName   = 'My.Object'
    MemberType = 'ScriptProperty'
    MemberName = 'UpperCaseName'
    Value      = { $this.Name.toUpper() }
}
Update-TypeData @TypeData

$HTMLStates.Content | Out-File -FilePath "C:\Temp\States.csv"
$StatesCsv = Import-Csv -Path "C:\Temp\States.csv"




