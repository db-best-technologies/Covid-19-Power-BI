Import-Module powershell-yaml

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
    'FIPS'           = "FIPS USA State County code"
    'Admin2'         = "USA State County"
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
$CountryReplacements = [PSCustomObject]@{
    'Mainland China' = "China"
    'Korea, South'   = "South Korea"
    'US'             = "USA"
}
$CountyReplacements = [PSCustomObject]@{
    'New York City' = "New York"
    'Brockton' = "Plymonth"
    'Dukes and Nantucket' = "Nantucket"
    'Unknown' = ""
    'Soldotna' = "Kenai Peninsula"
}
$StateReplacements = [PSCustomObject]@{
    'Chicago'                      = "Cook, IL"
    '(From Diamond Princess)'      = "Diamond Princess Japan, TX"
    'Grand Princess Cruise Ship'   = "Grand Princess Oakland, CA"
    'Grand Princess'               = "Grand Princess Oakland, CA"
    'Diamond Princess'             = "Diamond Princess Japan, TX"
    'United States Virgin Islands' = "St. Croix, PR"
    'Unassigned Location (From Diamond Princess)' = "Diamond Princess Japan, TX"
    'Chicago, IL' = "Cook, IL"
    'Lackland, TX' = "Bexar, TX"
}
#Debug values
# $f, $RowNumber = @(11, 52)
# $f, $RowNumber = @( 30,60 )
# $f, $RowNumber = @( 60, 296 )
# $f, $RowNumber = @( 60, 298 )
# $f, $RowNumber = @( 60, 486 )
# $f, $RowNumber = @( 60, 1148 )

$StatesCsv = Import-Csv -Path ($GitLocalRoot, $DataDir, "USPSTwoLetterStateAbbreviations.csv" -join "\")
$StateHash = @{ }
for ($s = 0; $s -lt $StatesCsv.Length; $s++ ) {
    $StateHash.Add( ($StatesCsv[$s]).'State or Possession', ($StatesCsv[$s]).'Abbreviation' )
}
$StateLook = [PSCustomObject]$StateHash


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


$ErrorLog = @()
$UnpivotedRows = @()
# Go through array of $SortedCSVs fix up and flatten the data for Confirmed,Deaths,Recovered,Active
for ( $f = 0; $f -lt $SortedCSVs.count; $f++) {
    $Csv = $SortedCSVs[$f]
    Write-Host ("File # = ", $f, " of ", $SortedCSVs.count, " CsvFileName=", $Csv.CsvFileName , " and ModifiedDate= ", (Get-Date -date $Csv.DateLastModifiedUTC).ToUniversalTime() -join "")
    $Columns = $null
    $PriorDayColumns = $null
    if ( [datetime]$Csv.PeriodEnding -le [datetime]'03-10-2020' ) {
        $Columns = $ColumnHeaders.'01-22-2020'
        if (  $Csv.PeriodEnding -ne '01-22-2020' ) {
            $PriorDayColumns = $Columns
        }
    }
    elseif ( [datetime]$Csv.PeriodEnding -gt [datetime]'03-10-2020' -and [datetime]$Csv.PeriodEnding -le [datetime]'03-21-2020' ) {
        $Columns = $ColumnHeaders.'03-11-2020'
        if ( $Csv.PeriodEnding -eq '03-11-2020' ) {
            $PriorDayColumns = $ColumnHeaders.'01-22-2020'
        }
        else {
            $PriorDayColumns = $Columns
        }
    }
    else {
        $Columns = $ColumnHeaders.'03-22-2020'
        if ($Csv.PeriodEnding -eq '03-22-2020') {
            $PriorDayColumns = $ColumnHeaders.'03-11-2020'
        }
        else {
            $PriorDayColumns = $ColumnHeaders.'03-22-2020'
        }
    }
    
    $ActualColumns = $Csv.CSVData[$f].psobject.properties.name

    for ( $RowNumber = 0; $RowNumber -lt $Csv.CSVData.Length; $RowNumber++ ) {
        $Row = $Csv.CSVData[$RowNumber]
        $Mapping = @{ }
        #Map the base columns to the new column names for the row
        for ($i = 0; $i -lt $ActualColumns.Count; $i++ ) {

            $Key = $NewColumnsMapping.($ActualColumns[$i])
            if ( "Confirmed,Deaths,Recovered,Active" -like "*$($Key)*" ) {
                #Skip these for now
                continue
            }
            if ( $Key -eq "Last Updated UTC") {
                $Value = Get-Date -Date $Row.($ActualColumns[$i]) -Format "yyyy-MM-ddTHH:mm:ss"
            }
            else {
                $Value = $Row.($ActualColumns[$i])
            }            
            $Mapping.Add( $Key, $Value )
        }
        Write-Host ("File # = ", $f, " Processing Row# ", $RowNumber, " out of ", $Csv.CSVData.Length, " Country = ", $Mapping.'Country or Region' -Join "")
        # Add Lat and long to mapping if missing
        if ( $null -eq $Mapping.Latitude ) { $Mapping.Add( 'Latitude', "") }
        if ( $null -eq $Mapping.Longitude ) { $Mapping.Add( 'Longitude', "") }
        
        # Create the Location Key Name
        $Values = @()
        if ( $null -ne $Mapping.'USA State County' -and ($Mapping.'USA State County').Length -gt 0 ) { 
            if ( $null -ne $CountyReplacements.($Mapping.'USA State County') ) {
                $Value = $CountyReplacements.($Mapping.'USA State County')
                $Mapping.'USA State County' = $Value   # Replace the old value with the new one
            }
            else { $Value = $Mapping.'USA State County' }
            if ( $Value.Length -gt 0){ $Values += $Value }
        }
            
        if ( $null -ne $Mapping.'Province or State' -and ($Mapping.'Province or State').Length -gt 0) {
            # First look for replacement in $StateReplacements
            if ( $null -ne $StateReplacements.($Mapping.'Province or State')) {
                $Value = $StateReplacements.($Mapping.'Province or State')
                $Mapping.'Province or State' = $Value
            }
            if ( $Mapping.'Province or State' -like "*, *" ) {
                # Looking at older file format. New format as the full state name
                $County, $StateCode = ($Mapping.'Province or State').Split(", ")
                if ($County -like "*County") { 
                    $CountyValue = $County.Split(" County")[0]
                }
                else { $CountyValue = $County }
                if ($null -eq $Mapping.'USA State County') {
                    $Mapping.Add( 'USA State County', $CountyValue )  # Test $RowNumber = 1120
                }
                else { $Mapping.'USA State County' = $CountyValue }
                $Values += $CountyValue
                $Mapping.'Province or State' = $StateCode
            }
            else {
                #Looks like an actual Province or State value, but for the US, need to use abbreviation
                if ( $Mapping.'Country or Region' -eq "US" ) {
                    $StateCode = $StateLook.($Mapping.'Province or State')
                    if ( $null -ne $StateCode) {
                        $Mapping.'Province or State' = $StateCode
                    }
                    else {
                        $RowError = @{
                            Severity    = "Lookup Failed"
                            Process     = "Looking up State name in StateLook table"
                            Message     = "Could not locate value: [$($Mapping.'Province or State')]"
                            Correction  = "Using original value"
                            CsvFileName = $Row.'CSV File Name'
                            FileNumber  = $f
                            RowNumber   = $RowNumber 
                            RowData     = $Row
                            Mapping     = [PSCustomObject]$Mapping
                        }
                        $ErrorLog += $RowError
                    }
                }
            }
            $Values += $Mapping.'Province or State'
        }
        if ( $null -eq $Mapping.'Country or Region') { $Mapping.Add( 'Country or Region', "") }
        if ( $null -ne $Mapping.'Country or Region' -and ($Mapping.'Country or Region').Length -gt 0 ) {
            if ( $null -ne $CountryReplacements.($Mapping.'Country or Region')) {
                $Value = $CountryReplacements.($Mapping.'Country or Region')
                $Mapping.'Country or Region' = $Value
            }
            else { $Value = $Mapping.'Country or Region' }
            $Values += $Value
        }

        if ( $null -ne $Values) {
            $Value = if ($Values.Count -gt 1 ) { $Values -join ", " }else { $Values[0] }
        } 
        else {
            $RowError = @{
                Severity    = "Empty Value"
                Process     = "Create Location Key Name"
                Message     = "No values for country, state, country"
                Correction  = "Assigning null value to the row's [Location Name Key] value"
                CsvFileName = $Row.'CSV File Name'
                RowData     = $Row
                Mapping     = [PSCustomObject]$Mapping
                FileNumber  = $f
                RowNumber   = $RowNumber 
            }
            $ErrorLog += $RowError
            $Value = "Unknown row in file # $f and row number $RowNumber"
        }

        if ( $null -eq $Mapping.'Location Name Key' ) {
            $Mapping.Add( 'Location Name Key', $Value )
        }
        else { $Mapping.'Location Name Key' = $Value }
        if ( $null -eq $Mapping.'FIPS USA State County code') { $Mapping.Add( 'FIPS USA State County code', "") }
        if ( $null -eq $Mapping.'USA State County') { $Mapping.Add( 'USA State County', "") }

        $Mapping.Add("File Number", $f)
        $Mapping.Add("Row Number", $RowNumber)

        # Now we have the base information for the location. We should really create a lookup file from this data as step 1
        $UnpivotedRows += [PSCustomObject]$Mapping

        $RowNumber++
    }
}
$UnpivotedRows | Export-Csv -path ($GitLocalRoot, "\", $DataDir, "\Location-Table.csv" -join "") -NoTypeInformation
$ErrorLog | ConvertTo-Json | Out-File -FilePath  ($TempDataLocation, "Error-Log.json" -join "")




$i = $SortedCSVs.Count - 1
$Today = $SortedCSVs[63].CSVData | Where-Object { $_.Combined_Key -eq "Korea, South" }
$Yesterday = $SortedCSVs[62].CSVData | Where-Object { $_.Combined_Key -eq "Korea, South" }
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




