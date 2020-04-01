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

$URLs = @{
    URLReports              = "https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_daily_reports"
    SourceWebSite           = "https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data"
    SourceMetadataInfo      = "https://github.com/CSSEGISandData/COVID-19"
    DBBestDerivedData       = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/", $DataDir, "/", $LeafDataFile, ".csv" -join ""
    DBBestDerivedMetadata   = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/", $DataDir, "/", $LeafDataFile, ".json" -join ""
    GitHubRoot              = "https://github"
    GitRawDataFilesMetadata = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/", $DataDir, "/", "Daily-Files-Metadata.csv" -join ""
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
    'New York City'       = "New York"
    'Brockton'            = "Plymonth"
    'Dukes and Nantucket' = "Nantucket"
    #    'Unknown'             = ""
    'Soldotna'            = "Kenai Peninsula"
    'LeSeur'              = "Le Sueur"
    #    'Unassigned'          = ""
}
$StateReplacements = [PSCustomObject]@{
    'Chicago'                                     = "Cook, IL"
    '(From Diamond Princess)'                     = "Diamond Princess Japan, TX"
    'Grand Princess Cruise Ship'                  = "Grand Princess Oakland, CA"
    'Grand Princess'                              = "Grand Princess Oakland, CA"
    'Diamond Princess'                            = "Diamond Princess Japan, TX"
    'United States Virgin Islands'                = "St. Croix, PR"
    'Unassigned Location (From Diamond Princess)' = "Diamond Princess Japan, TX"
    'Chicago, IL'                                 = "Cook, IL"
    'Lackland, TX'                                = "Bexar, TX"
    #    'None'                                        = ""
    #    'US'                                          = ""
    #    'Recovered'                                   = ""
    'Wuhan Evacuee'                               = 'California'
}
#Debug values
# $file, $RowNumber = @(11, 52)
# $file, $RowNumber = @( 30,60 )
# $file, $RowNumber = @( 60, 296 )
# $file, $RowNumber = @( 60, 298 )
# $file, $RowNumber = @( 60, 486 )
# $file, $RowNumber = @( 60, 1148 )
# $file, $RowNumber = @( 60, 872 )
# $file, $RowNumber = @( 63, 3230 )   # Recovered USA
# $file, $RowNumber = @( 63, 3230 ) 

$ErrorLog = @()

$StatesCsv = Import-Csv -Path ($GitLocalRoot, $DataDir, "USPSTwoLetterStateAbbreviations.csv" -join "\")
$StateHash = @{ }
for ($s = 0; $s -lt $StatesCsv.Length; $s++ ) {
    $StateHash.Add( ($StatesCsv[$s]).'State or Possession', ($StatesCsv[$s]).'Abbreviation' )
}
$StateLook = [PSCustomObject]$StateHash

$FilesLookupHash = @{}
#Check to see files have changes since the last download
$LocalDataFilesMetadata = $GitLocalRoot, "\", $DataDir, "\", "Daily-Files-Metadata.csv" -join ""
#$TempDataFilesMetadata = $GitLocalRoot, "\", $TempDataLocation, "Daily-Files-Metadata.csv" -join ""
$WebRequest = $null
$WebRequest = Invoke-WebRequest -Uri $URLs.GitRawDataFilesMetadata
if ( $null -ne $WebRequest -and $null -ne $WebRequest.Content) {
    #Download the Metadata file from our GitHub project
    $WebRequest.Content | Out-File -FilePath $LocalDataFilesMetadata
    $FilesInfo = Import-Csv -Path $LocalDataFilesMetadata | Sort-Object  PeriodEnding

    if ( $null -ne $FilesInfo ) {
        $CSVFileCount = $FilesInfo.count

        if ( $null -eq $FilesInfo[0].NeedsUpdating) {
            $FilesInfo | Add-Member -MemberType NoteProperty -Name 'NeedsUpdating' -Value $False
            $FilesInfo | Add-Member -MemberType NoteProperty -Name 'FileNumber' -Value -1
        
        }
        $FileNumber = 0
        foreach ($FileRef in $FilesInfo) {
            if ( $FileRef.FileNumber -eq -1) {
                $FileRef.FileNumber = $FileNumber
            }
            $FilesLookupHash.Add($FileRef.CsvFileName, $FileRef)
            $FileNumber ++
        }

        $NewestFile = $FilesInfo | Sort-Object FileNumber -Bottom 1
        $NextFileNumber = $NewestFile.FileNumber + 1
        # $FilesLookupHash.'03-27-2020.csv'.DateLastModifiedUTC
    }
    else {
        $RowError = @{
            Severity   = "Import of File Metadata Failed"
            Process    = "Retrieving CSV web page URL [$($URLs.GitRawDataFilesMetadata)]"
            Message    = "File not found"
            Correction = "Download all files"
        }
        $ErrorLog += $RowError
        $RowError
        
        $FilesInfo = @()
        $NextFileNumber = 0
    }   
}
else {
    $RowError = @{
        Severity   = "Import of File Metadata missing"
        Process    = "Retrieving web page URL [$($URLs.GitRawDataFilesMetadata)]"
        Message    = "File not found"
        Correction = "Download all files"
    }
    $ErrorLog += $RowError
    $RowError

    $FilesInfo = @()
    $NextFileNumber = 0
  
}
$GroupedFileRows = @{ }

# Load in the local or web version of the last data file if it exists
$PriorDataRows = @()
$WebRequest = $null
$WebRequest = Invoke-WebRequest -Uri $URLs.DBBestDerivedData
if ( $null -ne $WebRequest.Content ) {
    $WebRequest.Content | Out-File -FilePath "$($GitLocalRoot)\Working Files\CheckedInDerivedFiles.csv"
    $PriorDataRows = Import-Csv -Path $LocalDataFile 
    if ($null -eq $PriorDataRows[0].psobject.properties.Match( 'Date Reported') ) {
        $PriorDataRows | Add-Member -MemberType NoteProperty -Name 'Date Reported' -Value ""
    }


    $MissingLatLong = @()
    $ZeroForLatLong = @()
    # Recreate the hash table of file and their data
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $GroupedFileRows = @{ }
    if ( $null -ne $PriorDataRows) {
        $FileRows = $null
        $FileNumber = 0
        $FileRows = @()
        $CurrentFile = $PriorDataRows[0].'CSV File Name'
        for ( $Element = 0; $Element -lt $PriorDataRows.Count; $Element ++ ) {
            
            if ( $PriorDataRows[$Element].'Csv File Name' -eq $CurrentFile) {
                $DateReported = $CurrentFile.Split('.csv')[0]
                $PriorDataRows[$Element].'Date Reported' = $DateReported
                $FileRows += $PriorDataRows[$Element]
            }
            else {
                Write-Host ("Capturing FileNumber = ", $FileNumber, "Current file name = ", $CurrentFile, " Elapsed time so for = ", $timer.Elapsed.TotalSeconds -join "") 
                $GroupedFileRows.Add( $CurrentFile, $FileRows)
                $FileRows = @()
                $CurrentFile = $PriorDataRows[$Element].'CSV File Name'
                $DateReported = $CurrentFile.Split('.csv')[0]
                $PriorDataRows[$Element].'Date Reported' = $DateReported
                $FileRows += $PriorDataRows[$Element]
            }
        }


        Write-Host $timer.Elapsed.TotalSeconds
        $timer = $null
       
        
    }
    else {
        $RowError = @{
            Severity   = "Derived data file not found"
            Process    = "Retrieving CSV web page URL [$($URLs.GitRawDataFilesMetadata)]"
            Message    = "File not found"
            Correction = "Download all files"
        }
        $ErrorLog += $RowError
        $RowError
    }
}
$ChangeInGitHubFiles = $False
$arrayNewCSVData = @()


foreach ( $Link in $WR.Links) {
    if ( $Link.href -like "*2020.csv" ) {
        # Using the data in the $Link.href string, parse out the file name to use to grab the actual csv data from the GitHub
        $CSVFileName = Split-Path -Path $Link.href -Leaf
        $CSVRawURL = $GitRawRoot, $CSVFileName -join ""
        $CSVPageURL = $URLs.URLReports, $CSVFileName -join "/"

        # Retrieve the GitHub page for the CSV file to pull out the date for the last check-in
        $WR_Page = Invoke-WebRequest -Uri $CSVPageURL
        Write-Host "Processing file $CSVFileName"
        if ( $null -eq ($WR_Page.Content.split("<relative-time datetime=")[1]) ) {
            $RowError = @{
                Severity    = "Table not found"
                Process     = "Retrieving CSV web page URL [$($CSVPageURL)]"
                Message     = "Could not find table for [$($CSVFileName)]"
                Correction  = "Using the CSV File as the date"
                CsvFileName = $CSVFileName
                CSVPageURL  = $CSVPageURL
            }
            $DateLastModifiedUTC = Get-Date -Date $CSVFileName.Split(".")[0] -Format "yyyy-MM-ddTHH:mm:ssZ"
            $ErrorLog += $RowError
        }
        elseif ( $null -eq ($WR_Page.Content.split("<relative-time datetime=")[1].Split(" class=") ) ) {
            $RowError = @{
                Severity    = "Table not found"
                Process     = "Retrieving CSV web page URL [$($CSVPageURL)]"
                Message     = "Could not find table for [$($CSVFileName)]"
                Correction  = "Using the CSV File as the date"
                CsvFileName = $CSVFileName
                CSVPageURL  = $CSVPageURL
            }
            $ErrorLog += $RowError
            $DateLastModifiedUTC = Get-Date -Date $CSVFileName.Split(".")[0] -Format "yyyy-MM-ddTHH:mm:ssZ"            
        }
        else {
            $DateLastModifiedUTC = $WR_Page.Content.split("<relative-time datetime=")[1].Split(" class=")[0]
            if ($DateLastModifiedUTC -like '"*') { $DateLastModifiedUTC = $DateLastModifiedUTC.Split('"')[1] }
        }
        

        # If the file was loaded before, check to see if the current modified date is > than the one processed
        if ($null -ne $FilesLookupHash.$CsvFileName ) {
            #File was previously loaded
            if ( $DateLastModifiedUTC -gt $FilesLookupHash.$CsvFileName.DateLastModifiedUTC ) {
                # Data was changed since the last download
                $RowError = @{
                    Severity    = "File changes"
                    Process     = "Retrieving CSV web page URL [$($CSVPageURL)]"
                    Message     = "Previous date: $($FilesLookupHash.$CsvFileName.DateLastModifiedUTC) and the revised date:$DateLastModifiedUTC"
                    Correction  = "Setting needs updating flag to true and updating changed date to the new date"
                    CsvFileName = $CSVFileName
                    CSVPageURL  = $CSVPageURL
                }
                $ErrorLog += $RowError
                $ChangeInGitHubFiles = $true
                $FilesLookupHash.$CSVFileName.NeedsUpdating = $true
                $FilesLookupHash.$CSVFileName.DateLastModifiedUTC = $DateLastModifiedUTC
                $FilesLookupHash.$CSVFileName.CSVRawURL = $CSVRawURL
                $RowError

                # Get the updated daily CSV file using the $CSVRawURL
                $WR_CSV = Invoke-WebRequest -Uri $CSVRawURL
                $WR_CSV.Content | Out-File -FilePath ($TempDataLocation, $CSVFileName -join "")
                # Write back out the CSV files to Temp location for debugging
                $CSVData = Import-Csv -Path ($TempDataLocation, $CSVFileName -join "")
                $PeriodEnding = $CSVFileName.Split('.csv')[0]
                $CSVData | Add-Member -MemberType NoteProperty -Name 'Date Reported' -Value $PeriodEnding
                $CSVData | Add-Member -MemberType NoteProperty -Name 'CSV File Name' -Value $CSVFileName
                $CSVData | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "$CSVFileName" -join "") -NoTypeInformation -UseQuotes AsNeeded
                $FileMetadata = $FilesLookupHash.$CSVFileName
                
                $FileMetadata | Add-Member -MemberType NoteProperty -Name 'CSVData' -Value $CSVData
                $arrayNewCSVData += $FileMetadata
            }
        }
        else {
            $RowError = @{
                Severity    = "New file"
                Process     = "Retrieving new CSV web page URL [$($CSVPageURL)]"
                Message     = "Revised date:$DateLastModifiedUTC"
                Correction  = "Setting needs updating flag to true and updating changed date to the new date"
                CsvFileName = $CSVFileName
                CSVPageURL  = $CSVPageURL
            }
            $ErrorLog += $RowError
            $RowError 

            $ChangeInGitHubFiles = $true
            # New file  - The end result is each record is added as a PSCustomObject to the $CSVData array.
            # To load the CSV correctly into memory, we need to write it out to a file and read it back in. 
            # Get the daily CSV file using the $CSVRawURL
            $WR_CSV = Invoke-WebRequest -Uri $CSVRawURL
            $WR_CSV.Content | Out-File -FilePath ($TempDataLocation, $CSVFileName -join "")
            # Write back out the CSV files to Temp location for debugging
            $CSVData = Import-Csv -Path ($TempDataLocation, $CSVFileName -join "")
            # Remove-Item -LiteralPath ($TempDataLocation, $CSVFileName -join "")

            # Add all the file name to the records so they can be related to new Daily-Files-Metadata.csv for data lineage
            $PeriodEnding = $CSVFileName.Split(".")[0]   # This takes 02-01-2020.CSV and removes the .CSV
            $CSVData | Add-Member -MemberType NoteProperty -Name 'CSV File Name' -Value $CSVFileName
            $CSVData | Add-Member -MemberType NoteProperty -Name 'Date Reported' -Value $PeriodEnding
            $CSVData | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "$CSVFileName" -join "") -NoTypeInformation -UseQuotes AsNeeded
            $FileMetadata = [PSCustomObject]@{
                CsvFileName         = $CSVFileName
                PeriodEnding        = $PeriodEnding
                CSVRawURL           = $CSVRawURL
                CSVPageURL          = $CSVPageURL
                DateLastModifiedUTC = $DateLastModifiedUTC
                FileNumber          = $NextFileNumber
                NeedsUpdating       = $true
            } 
            $FilesInfo += $FileMetadata
            $FileMetadata | Add-Member -MemberType NoteProperty -Name 'CSVData' -Value $CSVData
            $arrayNewCSVData += $FileMetadata
            $NextFileNumber ++
        }        
    }
}
$ErrorLog
$arrayNewCSVData
if ($null -eq $arrayNewCSVData ) {
    #Nothing more to process
    $RowError = @{
        Severity   = "No new files"
        Process    = "Checking for changed data"
        Message    = "Revised date:$DateLastModifiedUTC"
        Correction = "Noting to process"
    }
    $ErrorLog += $RowError
    $RowError 
    $ErrorLog | ConvertTo-Json | Out-File -FilePath  ($TempDataLocation, "Error-Log.json" -join "")
}
else {

    # Work the data in the $CSVLinks array by the CsvTodayKey (report date)
    $SortedCSVs = $arrayNewCSVData | Sort-Object -Property CsvFileName 

    #Check to make sure the array is sorted
    $SortedCSVs[0].CsvData[0]
    $SortedCSVs[1].CsvData[0]


    #Clear out the old array to release memory
    Remove-Variable 'arrayNewCSVData'

    # Start the process of reading each of the file records and the rows within them
    $UnpivotedRows = @()

    # Debeg: $File, $RowNumber = 65, 527
    # Go through array of $SortedCSVs fix up and flatten the data for Confirmed,Deaths,Recovered,Active
    for ( $file = 0; $file -lt $SortedCSVs.count; $file++) {
        $UnpivotedRows = @()
        $Csv = $SortedCSVs[$file]
        $FileNumber = $Csv.FileNumber
        $CurrentFile = $Csv.CsvFileName
        $DateReported = $CurrentFile.Split('.csv')[0]
        Write-Host ("File # = ", $file, " mapped to ", $FileNumber, " of ", $SortedCSVs.count, " CsvFileName= ", $Csv.CsvFileName , " and ModifiedDate= ", (Get-Date -date $Csv.DateLastModifiedUTC).ToUniversalTime() -join "")
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
    
        $ActualColumns = $Csv.CSVData[$file].psobject.properties.name

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
                    $Value = Get-Date -Date $Row.($ActualColumns[$i]) -Format "yyyy-MM-ddTHH:mm:ssZ"
                }
                else {
                    $Value = $Row.($ActualColumns[$i])
                }            
                $Mapping.Add( $Key, $Value )
            }
            Write-Host ("File # = ", $FileNumber, " Processing Row# ", $RowNumber, " out of ", $Csv.CSVData.Length, " Country = ", $Mapping.'Country or Region' -Join "")
            # Add Lat and long to mapping if missing
            if ( $null -eq $Mapping.Latitude ) { $Mapping.Add( 'Latitude', "") }
            if ( $null -eq $Mapping.Longitude ) { $Mapping.Add( 'Longitude', "") }
            $Mapping.Add( 'Date Reported', $DateReported )

            if ($Debug -eq $true) { $Mapping }
            # Create the Location Key Name
            $Values = @()
            if ( $null -ne $Mapping.'USA State County' -and ($Mapping.'USA State County').Length -gt 0 ) { 
                if ( $null -ne $CountyReplacements.($Mapping.'USA State County') ) {
                    $Value = $CountyReplacements.($Mapping.'USA State County').Trim()
                    $Mapping.'USA State County' = $Value   # Replace the old value with the new one
                }
                else { $Value = $Mapping.'USA State County' }
                if ( $Value.Length -gt 0) { $Values += $Value.Trim() }
            }
            
            if ( $null -ne $Mapping.'Province or State' -and ($Mapping.'Province or State').Length -gt 0) {
                # First look for replacement in $StateReplacements
                if ( $null -ne $StateReplacements.($Mapping.'Province or State')) {
                    $Value = $StateReplacements.($Mapping.'Province or State')
                    $Mapping.'Province or State' = $Value.Ttim()
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
                    $Values += $CountyValue.Trim()
                    $Mapping.'Province or State' = $StateCode.Trim()
                }
                else {
                    #Looks like an actual Province or State value, but for the US, need to use abbreviation
                    if ( $Mapping.'Country or Region' -eq "US" -and $Mapping.'Province or State' -ne "") {
                        $StateCode = $StateLook.($Mapping.'Province or State')
                        if ( $null -ne $StateCode) {
                            $Mapping.'Province or State' = $StateCode.Trim()
                        }
                        else {
                            $RowError = @{
                                Severity    = "Lookup Failed"
                                Process     = "Looking up State name in StateLook table"
                                Message     = "Could not locate value: [$($Mapping.'Province or State')]"
                                Correction  = "Using original value"
                                CsvFileName = $Row.'CSV File Name'
                                FileNumber  = $FileNumber
                                RowNumber   = $RowNumber 
                                RowData     = $Row
                                Mapping     = [PSCustomObject]$Mapping
                            }
                            $ErrorLog += $RowError
                        }
                    }
                }
                if ($Mapping.'Province or State' -ne "" -and $null -ne $Mapping.'Province or State') {
                    $Values += $Mapping.'Province or State'.Trim()
                }
            
            }
            if ( $null -eq $Mapping.'Country or Region') { $Mapping.Add( 'Country or Region', "") }
            if ( $null -ne $Mapping.'Country or Region' -and ($Mapping.'Country or Region').Length -gt 0 ) {
                if ( $null -ne $CountryReplacements.($Mapping.'Country or Region')) {
                    $Value = $CountryReplacements.($Mapping.'Country or Region')
                    $Mapping.'Country or Region' = $Value.Trim()
                }
                else { $Value = $Mapping.'Country or Region' }
                $Values += $Value.Trim()
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
                    FileNumber  = $FileNumber
                    RowNumber   = $RowNumber 
                }
                $ErrorLog += $RowError
                $Value = "Unknown row in file # $FileNumber and row number $RowNumber"
            }

            if ( $null -eq $Mapping.'Location Name Key' ) {
                $Mapping.Add( 'Location Name Key', $Value.Trim() )
            }
            else { $Mapping.'Location Name Key' = $Value.Trim() }
            if ( $null -eq $Mapping.'FIPS USA State County code') { $Mapping.Add( 'FIPS USA State County code', "") }
            if ( $null -eq $Mapping.'USA State County') { $Mapping.Add( 'USA State County', "") }

            $Mapping.Add("File Number", $FileNumber)
            $Mapping.Add("Row Number", $RowNumber)

            # Now unpivot attributes
            $Mapping.Add("Attribute", "")
            $Mapping.Add("Cumulative Value", "")
            $Mapping.Add("Change Since Prior Day", "")

            $Active = 0
            $Mapping.Attribute = "Confirmed"
            if ($Row.Confirmed -eq "" -and $null -ne $Row.Confirmed) {
                $Mapping.'Cumulative Value' = 0    
            }
            else { $Mapping.'Cumulative Value' = $Row.Confirmed }
        
            $UnpivotedRows += [PSCustomObject]$Mapping
            if ($Debug -eq $true) { "Mapping: "; $Mapping }
            $Active = $Mapping.'Cumulative Value'
        
            $Mapping.Attribute = "Deaths"
            if ($Row.Deaths -eq "" -and $null -ne $Row.Deaths) {
                $Mapping.'Cumulative Value' = 0    
            }
            else { $Mapping.'Cumulative Value' = $Row.Deaths }
            $UnpivotedRows += [PSCustomObject]$Mapping
            if ($Debug -eq $true) { "Mapping: "; $Mapping }

            $Active -= $Mapping.'Cumulative Value'

            $Mapping.Attribute = "Recovered"
            if ($Row.Recovered -eq "" -and $null -ne $Row.Recovered) {
                $Mapping.'Cumulative Value' = 0    
            }
            else { $Mapping.'Cumulative Value' = $Row.Recovered }

            $UnpivotedRows += [PSCustomObject]$Mapping
            if ($Debug -eq $true) { "Mapping: "; $Mapping }
            $Active -= $Mapping.'Cumulative Value'

            $Mapping.Attribute = "Active"
            $Mapping.'Cumulative Value' = $Active
            $UnpivotedRows += [PSCustomObject]$Mapping
            if ($Debug -eq $true) { "Mapping: "; $Mapping }
       
    
        }
        #Add files unpivoted items to $GroupedFileRows
        if ( $null -ne $GroupedFileRows.$CurrentFile ) {
            # This is a file that was modified
            $GroupedFileRows.$CurrentFile = $UnpivotedRows
            Write-Host ("Updated Current file: ", $CurrentFile, " a total of ", $GroupedFileRows.$CurrentFile.Count, " Rows" -join "")
            if ( $null -ne $FilesLookupHash.$CurrentFile.CSVData) { 
                $FilesLookupHash.$CurrentFile.psobject.Properties.remove('CSVData')
                $FilesLookupHash.$CurrentFile.NeedsUpdating = $False
            }
        }
        else {
            Write-Host ("Add to Current file: ", $CurrentFile, " a total of ", $UnpivotedRows.Count, " Rows" -join "")
            $GroupedFileRows.Add( $CurrentFile, $UnpivotedRows)
            $SortedCSVs[$file].NeedsUpdating = $false
       
            $FilesLookupHash.Add( $CurrentFile, $SortedCSVs[$file]  )
            $FilesLookupHash.$CurrentFile.psobject.Properties.remove('CSVData')

        }
    
    }
    # Write out the updated CSSEGISandData-COVID-19-Derived.csv
    $FirstTime = $True
    $OrderedKeys = $GroupedFileRows.Keys | Sort-Object
    $SelectColumnList = @(
        'Location Name Key'
        , 'Date Reported'
        , 'Attribute'
        , 'Cumulative Value'
        , 'Change Since Prior Day'
#        , 'Latitude'
#        , 'Longitude'
#        , 'Country or Region'
#        , 'Province or State'
        , 'CSV File Name'
#        , 'USA State County'
#        , 'FIPS USA State County code'
        , 'Last Updated UTC'
        , 'File Number'
        , 'Row Number'
    )
    $SortList = @(
        @{Expression = "CSV File Name"; Descending = $False }
        , @{Expression = "Row Number"; Descending = $False }
        , @{Expression = "Attribute"; Descending = $False }
    )

    foreach ( $KeyValue in $OrderedKeys) {
        
        Write-Host $KeyValue
  
        if ( $FirstTime -eq $true) {
            $GroupedFileRows.$KeyValue | Select-Object -Property $SelectColumnList | Sort-Object -Property $SortList | Export-Csv -Path ($GitLocalRoot, "\", $DataDir, "\", "CSSEGISandData-COVID-19-Derived.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded
            $FirstTime = $false
        }
        else {
            $GroupedFileRows.$KeyValue | Select-Object -Property $SelectColumnList | Sort-Object -Property $SortList | Export-Csv -Path ($GitLocalRoot, "\", $DataDir, "\", "CSSEGISandData-COVID-19-Derived.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded -Append
        }
    }

    # Write out the new or updated Daily-Files-Metadata.csv
    $FilesLookupHash.Values | Sort-Object -Property CsvFileName | Export-Csv -Path ($GitLocalRoot, "\", $DataDir, "\", "Daily-Files-Metadata.csv" -join "") -NoTypeInformation
}

$MissingLatLong = $PriorDataRows | Where-Object {( $_.Latitude -eq "" -or $_.Longitude -eq "" )} | Sort-Object -Property 'Location Name Key' -Unique  | Select-Object 'Location Name Key',Latitude,Longitude, 'CSV File Name', 'Row Number'
Write-Host "Number of records with Missing Lat/Long: ", $MissingLatLong.Count
$MissingLatLong | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Missing-Lat-Long-Records.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded

$ZeroForLatLong = $PriorDataRows | Where-Object {( $_.Latitude -eq "0" -and $_.Longitude -eq "0" )} |  Sort-Object -Property 'Location Name Key' -Unique  | Select-Object 'Location Name Key',Latitude,Longitude, 'CSV File Name', 'Row Number'
Write-Host "Number of records with 0 values for Lat and Long: ", $MissingLatLong.Count
$ZeroForLatLong | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Zeros-For-Lat-Long-Records.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded


$UnknownOrUnassignedCounties = $PriorDataRows | Where-Object {( $_.'USA State County' -eq "Unknown" -or $_.'USA State County' -eq "Unassigned" )} | Sort-Object -Property @{Expression = 'Location Name Key'} -Unique 
Write-Host "County values where values are Unknown or Unassigned: ", $UnknownOrUnassignedCounties.Count
$UnknownOrUnassignedCounties | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Unassigned-or-Unknown-Counties.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded

$UniqueLocationKeys = $PriorDataRows | Sort-Object -Property 'Location Name Key' -Unique  | Select-Object 'Location Name Key',Latitude,Longitude, 'CSV File Name', 'Row Number'
Write-Host "Count of unique values for 'Location Name Key': ", $UniqueLocationKeys.Count
$UniqueLocationKeys | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Unique-Location-Name-Key-values.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded

$SpacesInCountyValue = $PriorDataRows | Where-Object {( $_.'Location Name Key' -eq " Norfolk, MA, USA" -or $_.'Location Name Key' -eq " Montreal, QC, Canada" )}
Write-Host "Count of SpacesInCountyValue: ", $SpacesInCountyValue.Count
$SpacesInCountyValue | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Spaces-In-County-Value.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded

$UniqueLocationKeysWithLatLong = $PriorDataRows | Where-Object {( $_.Latitude -ne "0" -and $_.Latitude -ne "" -and $_.Longitude -ne "0" -and $_.Longitude -ne "" )} | Sort-Object -Property 'Location Name Key' -Unique | Select-Object 'Location Name Key',Latitude,Longitude, 'CSV File Name', 'Row Number'
Write-Host "Count of unique values for 'Location Name Key' with Lat and Long: ", $UniqueLocationKeysWithLatLong.Count
$UniqueLocationKeysWithLatLong | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Unique-Location-Name-Key-With-Lat-and-Long.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded

$OddStateValues = $PriorDataRows | Where-Object {( $_.'Province or State' -eq "None" -or $_.'Province or State' -eq "US" -or $_.'Province or State' -eq "Recovered" )} |  Sort-Object -Property 'Location Name Key'# -Unique
Write-Host "Count of unique values for OddStateValues: ", $OddStateValues.Count
$OddStateValues | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Odd-State-Values.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded


$FirstConfirmedReports =  $PriorDataRows | Where-Object {( $_.'Attribute' -eq "Confirmed" -and $_.'Cumulative Value' -ne "0" -and $_.'Cumulative Value' -ne ""  )} | Sort-Object -Property @{Expression = 'Location Name Key'}, @{Expression = 'CSV File Name'} -Unique
Write-Host "Count of unique values for FirstConfirmedReports: ", $FirstConfirmedReports.Count
$FirstConfirmedReports | Export-Csv -Path ($GitLocalRoot, "\Data-Files\", "First-Confirmed-Reports.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded


$FirstDeathReports =  $PriorDataRows | Where-Object {( $_.'Attribute' -eq "Deaths" -and $_.'Cumulative Value' -ne "0" -and $_.'Cumulative Value' -ne ""  )} | Sort-Object -Property @{Expression = 'Location Name Key'}, @{Expression = 'CSV File Name'} -Unique
Write-Host "Count of unique values for FirstDeathReports: ", $FirstDeathReports.Count
$FirstDeathReports | Export-Csv -Path ($GitLocalRoot, "\Data-Files\", "First-Deaths-Reports.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded


$FirstRecoveredReports =  $PriorDataRows | Where-Object {( $_.'Attribute' -eq "Recovered" -and $_.'Cumulative Value' -ne "0" -and $_.'Cumulative Value' -ne ""  )} | Sort-Object -Property @{Expression = 'Location Name Key'}, @{Expression = 'CSV File Name'} -Unique
Write-Host "Count of unique values for FirstRecoveredReports: ", $FirstRecoveredReports.Count
$FirstRecoveredReports | Export-Csv -Path ($GitLocalRoot, "\Data-Files\", "First-Recovered-Reports.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded


$USStateLatLongData = $PriorDataRows | Where-Object {( $_.'Country or Region' -eq "USA" -and  $_.'Province or State' -ne "" -and $_.'USA State County' -eq "" -and $_.Latitude -ne "0" -and $_.Latitude -ne "" -and $_.Longitude -ne "0" -and $_.Longitude -ne "" )} | Sort-Object -Property 'Location Name Key' -Unique | Select-Object 'Location Name Key',Latitude,Longitude,'Country or Region','Province or State'
Write-Host "Count of unique values for USStateLatLongData: ", $USStateLatLongData.Count
$USStateLatLongData | Export-Csv -Path ($GitLocalRoot, "\Data-Files\", "US-State-Lat-Long-Data.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded

#Create one file for all of the reported locations to use as a look up file for the 'Location Name Key' value
$UniqueLocationKeys.Count
$UniqueLocationKeysWithLatLong.Count
$MissingLatLong.Count 
$ZeroForLatLong.Count

$ArrayMissing = @()
$ArrayFound = @()
foreach ( $Location in $UniqueLocationKeys ) {
    if ( ( $Location.Latitude -eq "0" -and $Location.Longitude - "0" ) -or ($Location.Latitude -eq ""  -or $Location.Longitude -eq "") ) {
        $LatLong = $UniqueLocationKeysWithLatLong | Where-Object { ( $_.'Location Name Key' -eq $Location.'Location Name Key' )}
        if ( $null -eq $LatLong ) {

            $ArrayMissing += $Location
        } else {
            $Location.Latitude = $LatLong[0].Latitude
            $Location.Longitude = $LatLong[0].Longitude
            $ArrayFound += $Location
        }
    }
    else {
        $ArrayFound += $Location
    }
}
$ArrayMissing | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Unresolved-Locations-Lat-Long.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded
$ArrayFound.Count
$UniqueLocationKeys.Count
$ArrayFound | Select-Object 'Location Name Key',Latitude,Longitude | Export-Csv -Path ($GitLocalRoot, "\Data-Files\", "Unique-Location-Name-Key-values.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded 
#Used https://www.latlong.net/
$ManualResolution = @(
      [PSCustomObject]@{'Location Name Key'="Ashland, NE, USA"; Latitude = "41.036140"; Longitude = "-96.360940" }
    , [PSCustomObject]@{'Location Name Key'="Australia"; Latitude = "-25.274399"; Longitude = "133.775131" }
    , [PSCustomObject]@{'Location Name Key'="Bavaria, Germany"; Latitude = "48.917431"; Longitude = "11.407980" }
    , [PSCustomObject]@{'Location Name Key'="Cruise Ship, Others"; Latitude = "25.695980"; Longitude = "32.645649" }
    , [PSCustomObject]@{'Location Name Key'="External territories, Australia"; Latitude = "-10.484470"; Longitude = "105.637100" }
    , [PSCustomObject]@{'Location Name Key'="From Diamond Princess, Israel"; Latitude = "32.089556"; Longitude = "34.797614" }
    , [PSCustomObject]@{'Location Name Key'="Ivory Coast"; Latitude = "-22.497511"; Longitude = "17.015369" }
    , [PSCustomObject]@{'Location Name Key'="Jervis Bay Territory, Australia"; Latitude = "-35.140020"; Longitude = "150.728240" }
    , [PSCustomObject]@{'Location Name Key'="Nashua, NH, USA"; Latitude = "42.757870"; Longitude = "-71.463951" }
    , [PSCustomObject]@{'Location Name Key'="None, Austria"; Latitude = "47.516232"; Longitude = "14.550072" }
    , [PSCustomObject]@{'Location Name Key'="None, Iraq"; Latitude = "33.223190"; Longitude = "43.679291" }
    , [PSCustomObject]@{'Location Name Key'="None, Lebanon"; Latitude = "33.854721"; Longitude = "35.862286" }
    , [PSCustomObject]@{'Location Name Key'="North Ireland"; Latitude = "54.597271"; Longitude = "-5.930110" }
    , [PSCustomObject]@{'Location Name Key'="Out-of-state, TN, USA"; Latitude = "36.162663"; Longitude = "-86.781601" }
    , [PSCustomObject]@{'Location Name Key'="Plymonth, MA, USA"; Latitude = "41.955750"; Longitude = "-70.664390" }
    , [PSCustomObject]@{'Location Name Key'="Sterling, AK, USA"; Latitude = "60.537470"; Longitude = "-150.765050" }
    , [PSCustomObject]@{'Location Name Key'="Travis, CA, USA"; Latitude = "38.291790"; Longitude = "-121.921097" }
    , [PSCustomObject]@{'Location Name Key'="Unknown, TN, USA"; Latitude = "36.162663"; Longitude = "-86.781601" }
)
$ManualResolution |Select-Object 'Location Name Key',Latitude,Longitude | Export-Csv -Path ($GitLocalRoot, "\Data-Files\", "Unique-Location-Name-Key-values.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded -Append
