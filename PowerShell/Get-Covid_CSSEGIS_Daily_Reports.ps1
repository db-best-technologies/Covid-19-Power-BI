<#
Title:       Get-Covid_CSSEGIS_Daily_Reports.ps1
Description: Create an CSV file based on daily reports from in the https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_daily_reports folder.
Author:      Bill Ramos, DB Best Technologies
MoreInfo:    https://github.com/db-best-technologies/Covid-19-Power-BI/blob/master/PowerShell/Get-Covid_CSSEGIS_Daily_Reports.yaml
#>

$DebugOptions = Set-DebugOptions -WriteFilesToTemp $true -TempPath "C:\Temp\Covid-Temp-Files" -DeleteTempFilesAtStart $true -UpdateLocalFiles $true -AppendDebugData $false -Workaround $true -ForceDownload $true
Write-Host @DebugOptions 

$Errorlog = @()
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
    GitRawDataFilesMetadata = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/", $DataDir, "/", "CSSEGISandData-COVID-19-Derived-FileInfo.csv" -join ""
    GitRawDataFilesFull     = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/", $DataDir, "/", "CSSEGISandData-COVID-19-Derived-All-Columns.csv" -join ""
}
$WR = $null
$WR = Invoke-WebRequest -Uri $URLs.URLReports
if ( $null -eq $WR.Content ) {
    $Errorlog += $WR.Headers
    $WR.Headers | ft
    Start-Sleep -Seconds 1
    $Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
    if ( $Continue -ne "Yes") { Exit 0 }
}
$URLs.Add( "SourceDataURI", $WR.BaseResponse.RequestMessage.RequestUri.AbsoluteUri )
$URLs.Add( "SourceAuthority", $WR.BaseResponse.RequestMessage.RequestUri.Authority )
$URLs.Add( "RetrievedOnUTC", $WR.BaseResponse.Headers.Date.UtcDateTime )
$URLs.Add( "RetrievedOnPST", $WR.BaseResponse.Headers.Date.LocalDateTime )

$ColumnHeaders = @{
    "01-22-2020" = @('Province/State', 'Country/Region', 'Last Update', 'Confirmed' , 'Deaths', 'Recovered')
    "03-11-2020" = @('Province/State', 'Country/Region', 'Last Update', 'Confirmed' , 'Deaths', 'Recovered', 'Latitude', 'Longitude')
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


$AllColumnsPSO = [PSCustomObject]@{
    'Active'                     = $null
    'Active Original'            = $null
    'Admin2'                     = $null
    'Combined_Key'               = $null
    'Confirmed'                  = $null
    'Country or Region'          = $null
    'Country/Region'             = $null
    'Country_Region'             = $null
    'CSV File Name'              = $null
    'Daily Value'                = $null
    'Deaths'                     = $null
    'FIPS'                       = $null
    'FIPS USA State County code' = $null
    'Last Update'                = $null
    'Last Updated UTC'           = $null
    'Last_Update'                = $null
    'Lat'                        = $null
    'Latitude'                   = $null
    'Location Name Key'          = $null
    'Long_'                      = $null
    'Longitude'                  = $null
    'Province or State'          = $null
    'Province/State'             = $null
    'Province_State'             = $null
    'Recovered'                  = $null
    'USA State County'           = $null
    'Date Reported'              = $null
    'File Number'                = $null
    'USA County State Key'       = $null
    'Days Since First Value'     = $null
    'Days Since First Death'     = $null
    'Days Since First Confirmed' = $null
    'Days Since First Active'    = $null
    'Days Since First Recovered' = $null
    'Attribute'                  = $null
    'Cumulative Value'           = $null
    'Row Number'                 = $null
}


$MappingPSO = [PSCustomObject]@{
    'Attribute'                  = $null
    'Daily Value'                = $null
    'Days Since First Value'     = $null
    'Country or Region'          = $null
    'CSV File Name'              = $null
    'Cumulative Value'           = $null
    'Date Reported'              = $null
    'File Number'                = $null
    'FIPS USA State County code' = $null
    'Last Updated UTC'           = $null
    'Latitude'                   = $null
    'Location Name Key'          = $null
    'Longitude'                  = $null
    'Province or State'          = $null
    'Row Number'                 = $null
    'USA State County'           = $null
    'USA County State Key'       = $null
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

$StatesCsv = Import-Csv -Path ($GitLocalRoot, $DataDir, "USPSTwoLetterStateAbbreviations.csv" -join "\")
$StateHash = @{ }
for ($s = 0; $s -lt $StatesCsv.Length; $s++ ) {
    $StateHash.Add( ($StatesCsv[$s]).'State or Possession', ($StatesCsv[$s]).'Abbreviation' )
}
$StateLook = [PSCustomObject]$StateHash

$FilesLookupHash = [ordered]@{ }
#Check to see files have changes since the last download
$LocalDataFilesMetadata = $GitLocalRoot, "\", $DataDir, "\", "CSSEGISandData-COVID-19-Derived-FileInfo.csv" -join ""
#$TempDataFilesMetadata = $GitLocalRoot, "\", $TempDataLocation, "Daily-Files-Metadata.csv" -join ""
$WebRequest = $null
$WebRequest = Invoke-WebRequest -Uri $URLs.GitRawDataFilesMetadata
if ( $null -eq $WebRequest.Content ) {
    $Errorlog += $WebRequest.Headers
    $WebRequest.Headers | ft
    Start-Sleep -Seconds 1
    $Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
    if ( $Continue -ne "Yes") { Exit 0 }
}
if ( $null -ne $WebRequest -and $null -ne $WebRequest.Content -and -not $DebugOptions.ForceDownload ) {
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
            $FileRef.FileNumber = $FileNumber
            $FilesLookupHash.Add($FileRef.CsvFileName, $FileRef)
            $FileNumber ++
            
        }
        $NextFileNumber = $FileNumber
    }
    else {
        $RowError = @{
            Severity    = "Import of File Metadata Failed"
            Process     = "Retrieving CSV web page URL [$($URLs.GitRawDataFilesMetadata)]"
            Message     = "File not found"
            Correction  = "Download all files"
            CurrentLine = $MyInvocation.ScriptLineNumber
        }
        $ErrorLog += $RowError
        $RowError
        
        $FilesInfo = @()
        $NextFileNumber = 0
    }   
}
else {
    $RowError = @{
        Severity    = "Import of File Metadata missing"
        Process     = "Retrieving web page URL [$($URLs.GitRawDataFilesMetadata)]"
        Message     = "File not found"
        Correction  = "Download all files"
        CurrentLine = $MyInvocation.ScriptLineNumber
    }
    $ErrorLog += $RowError
    $RowError

    $FilesInfo = @()
    $NextFileNumber = 0
  
}

if ( $DebugOptions.WriteFilesToTemp) {
    $FilesLookupHash | ConvertTo-Yaml | Out-File ($DebugOptions.TempPath, "\FileLookupHash.yaml" -join "")
}

$GroupedFileRows = @{ }
# Load in the local or web version of the last data file if it exists
$PriorDataRows = @()
$WebRequest = $null
$WebRequest = Invoke-WebRequest -Uri $URLs.DBBestDerivedData
if ( $null -eq $WebRequest.Content ) {
    $Errorlog += $WebRequest.Headers
    $WebRequest.Headers | ft
    Start-Sleep -Seconds 1
    $Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
    if ( $Continue -ne "Yes") { Exit 0 }
}
if ( $null -ne $WebRequest.Content -and -not $DebugOptions.ForceDownload ) {
    $WebRequest.Content | Out-File -FilePath ( $DebugOptions.TempPath, "\CSSEGISandData-COVID-19-Derived.csv" -join "")
    $PriorDataRows = Import-Csv -Path ( $DebugOptions.TempPath, "\CSSEGISandData-COVID-19-Derived.csv" -join "")
    if ($null -eq $PriorDataRows[0].psobject.properties.Match( 'Date Reported') ) {
        $PriorDataRows | Add-Member -MemberType NoteProperty -Name 'Date Reported' -Value ""
    }

    $MissingLatLong = @()
    $ZeroForLatLong = @()
    $DaysInDerived = @()

    # Recreate the hash table of file and their data
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $GroupedFileRows = @{ }
    if ( $null -ne $PriorDataRows) {
        $FileRows = $null
        $FileNumber = 0
        $FileRows = @()
        $CurrentFile = $PriorDataRows[0].'CSV File Name'
        for ( $Element = 0; $Element -lt $PriorDataRows.Count; $Element ++ ) {
            # First time clean up when Date Reported wasn't there. 
            if ( $PriorDataRows[$Element].'Csv File Name' -eq $CurrentFile) {
                $DateReported = $CurrentFile.Split('.csv')[0]
                $PriorDataRows[$Element].'Date Reported' = $DateReported
                $FileRows += $PriorDataRows[$Element]
            }
            else {
                Write-Host ("Capturing FileNumber = ", $FileNumber, "Current file name = ", $CurrentFile, " Elapsed time so for = ", $timer.Elapsed.TotalSeconds -join "") 
                $GroupedFileRows.Add( $CurrentFile, $FileRows)
                if ($DebugOptions.WriteFilesToTemp ) {
                    $FileRows | Export-Csv -Path ($DebugOptions.TempPath, "\From-Git-CurrentFile-", $CurrentFile -join "") -NoTypeInformation -UseQuotes AsNeeded
                }

                $FileRows = @()
                $CurrentFile = $PriorDataRows[$Element].'CSV File Name'
                $DateReported = $CurrentFile.Split('.csv')[0]
                $PriorDataRows[$Element].'Date Reported' = $DateReported
                $PriorDataRows[$Element].'Row Number' = ($PriorDataRows[$Element].'Row Number')


                $FileRows += $PriorDataRows[$Element]
            }
        }

        Write-Host $timer.Elapsed.TotalSeconds
        $timer = $null
       
        
    }
    else {
        $RowError = @{
            Severity    = "Derived data file not found"
            Process     = "Retrieving CSV web page URL [$($URLs.DBBestDerivedData)]"
            Message     = "Need missing data look for the "
            Correction  = "Download all files"
            CurrentLine = $MyInvocation.ScriptLineNumber
        }
        $ErrorLog += $RowError
        $RowError
    }
}

$ChangeInGitHubFiles = $False
$arrayNewCSVData = @()

if ($GroupedFileRows.Count -ne $FilesLookupHash.Count -or $FilesLookupHash.count -eq 0 ) {
    # Values should be the same unless there was a data loading issue
    $RowError = @{
        Severity              = "Missing data in derived table"
        Process               = "Processing data from  [$($CSVPageURL)]"
        Message               = "Count mismatch where GroupedFileRows.Count -ne FilesLookupHash.Count ", $GroupedFileRows.Count, " -ne " , $FilesLookupHash.Count -join ""
        Correction            = "Tagging missing data as needing download in FilesLookupHash"
        FilesLookupHashSource = $URLs.GitRawDataFilesMetadata
        CurrentLine           = $MyInvocation.ScriptLineNumber
    }
    $ErrorLog += $RowError
    $RowError
    Start-Sleep -Seconds 5
}

foreach ( $Link in $WR.Links) {
    if ( $Link.href -like "*2020.csv" ) {
        # Using the data in the $Link.href string, parse out the file name to use to grab the actual csv data from the GitHub
        $CSVFileName = Split-Path -Path $Link.href -Leaf
        $CSVRawURL = $GitRawRoot, $CSVFileName -join ""
        $CSVPageURL = $URLs.URLReports, $CSVFileName -join "/"

        # Retrieve the GitHub page for the CSV file to pull out the date for the last check-in
        $WR_Page = $null
        $WR_Page = Invoke-WebRequest -Uri $CSVPageURL
        if ( $null -eq $WR_Page.Content ) {
            $Errorlog += $WR_Page.Headers
            $Errorlog += $Link.href
            $WR_Page.Headers | ft
            Start-Sleep -Seconds 1
            $Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
            if ( $Continue -ne "Yes") { Exit 0 }
        }
        Write-Host "Processing file $CSVFileName"
        if ( $null -eq ($WR_Page.Content.split("<relative-time datetime=")[1]) ) {
            $RowError = @{
                Severity    = "Table not found"
                Process     = "Retrieving CSV web page URL [$($CSVPageURL)]"
                Message     = "Could not find table for [$($CSVFileName)]"
                Correction  = "Using the CSV File as the date"
                CsvFileName = $CSVFileName
                CSVPageURL  = $CSVPageURL
                LinkHref    = $Link.href
                CurrentLine = $MyInvocation.ScriptLineNumber
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
                LinkHref    = $Link.href
                CurrentLine = $MyInvocation.ScriptLineNumber
            }
            $ErrorLog += $RowError
            $DateLastModifiedUTC = Get-Date -Date $CSVFileName.Split(".")[0] -Format "yyyy-MM-ddTHH:mm:ssZ"            
        }
        else {
            $DateLastModifiedUTC = $WR_Page.Content.split("<relative-time datetime=")[1].Split(" class=")[0]
            if ($DateLastModifiedUTC -like '"*') { $DateLastModifiedUTC = $DateLastModifiedUTC.Split('"')[1] }
        }
        

        # If the file was loaded before, check to see if the current modified date is > than the one processed
        if ($null -ne $FilesLookupHash.$CsvFileName -and $null -ne $GroupedFileRows.$CSVFileName -and -not $DebugOptions.ForceDownload) {
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
                    CurrentLine = $MyInvocation.ScriptLineNumber
                }
                $ErrorLog += $RowError
                $ChangeInGitHubFiles = $true
                $FilesLookupHash.$CSVFileName.NeedsUpdating = $true
                $FilesLookupHash.$CSVFileName.DateLastModifiedUTC = $DateLastModifiedUTC
                $FilesLookupHash.$CSVFileName.CSVRawURL = $CSVRawURL
                $RowError

                # Get the updated daily CSV file using the $CSVRawURL
                $WR_CSV = $null
                $WR_CSV = Invoke-WebRequest -Uri $CSVRawURL
                if ( $null -eq $WR_CSV.Content ) {
                    $Errorlog += $WR_CSV.Headers
                    $WR_CSV.Headers | ft
                    Start-Sleep -Seconds 1
                    $Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
                    if ( $Continue -ne "Yes") { Exit 0 }
                }
                $WR_CSV.Content | Out-File -FilePath ($TempDataLocation, $CSVFileName -join "")
                # Write back out the CSV files to Temp location for debugging
                $CSVData = Import-Csv -Path ($TempDataLocation, $CSVFileName -join "")
                $PeriodEnding = $CSVFileName.Split('.csv')[0]
                $CSVData | Add-Member -MemberType NoteProperty -Name 'Date Reported' -Value $PeriodEnding
                $CSVData | Add-Member -MemberType NoteProperty -Name 'CSV File Name' -Value $CSVFileName

                if ( $DebugOptions.WriteFilesToTemp) {
                    $OutputPath = ($DebugOptions.TempPath, "\", $CSVFileName -join "")
                    $CSVData | Export-Csv -Path $OutputPath -NoTypeInformation -UseQuotes AsNeeded
                }
                if ( $DebugOptions.UpdateLocalFiles ) {
                    $OutputPath = ($GitLocalRoot, "\Working Files\", "$CSVFileName" -join "") 
                    $CSVData | Export-Csv -Path $OutputPath -NoTypeInformation -UseQuotes AsNeeded
                }
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
                CurrentLine = $MyInvocation.ScriptLineNumber
            }
            $ErrorLog += $RowError
            $RowError 

            $ChangeInGitHubFiles = $true
            # New file  - The end result is each record is added as a PSCustomObject to the $CSVData array.
            # To load the CSV correctly into memory, we need to write it out to a file and read it back in. 
            # Get the daily CSV file using the $CSVRawURL
            $WR_CSV = $null
            $WR_CSV = Invoke-WebRequest -Uri $CSVRawURL
            if ( $null -eq $WR_CSV.Content ) {
                $Errorlog += $WR_CSV.Headers
                $WR_CSV.Headers | ft
                Start-Sleep -Seconds 1
                $Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
                if ( $Continue -ne "Yes") { Exit 0 }
            }
            $WR_CSV.Content | Out-File -FilePath ($TempDataLocation, $CSVFileName -join "")
            # Write back out the CSV files to Temp location for debugging
            $CSVData = Import-Csv -Path ($TempDataLocation, $CSVFileName -join "")
            # Remove-Item -LiteralPath ($TempDataLocation, $CSVFileName -join "")

            # Add all the file name to the records so they can be related to new Daily-Files-Metadata.csv for data lineage
            $PeriodEnding = $CSVFileName.Split(".")[0]   # This takes 02-01-2020.CSV and removes the .CSV
            $CSVData | Add-Member -MemberType NoteProperty -Name 'CSV File Name' -Value $CSVFileName
            $CSVData | Add-Member -MemberType NoteProperty -Name 'Date Reported' -Value $PeriodEnding

            if ( $DebugOptions.WriteFilesToTemp) {
                $OutputPath = ($DebugOptions.TempPath, "\", $CSVFileName -join "")
                $CSVData | Export-Csv -Path $OutputPath -NoTypeInformation -UseQuotes AsNeeded
            }
            if ( $DebugOptions.UpdateLocalFiles ) {
                $OutputPath = ($GitLocalRoot, "\Working Files\", "$CSVFileName" -join "") 
                $CSVData | Export-Csv -Path $OutputPath -NoTypeInformation -UseQuotes AsNeeded
            }
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
            $FileMetadata
            $NextFileNumber ++
        }        
    }
}
$ErrorLog
$arrayNewCSVData
if ($null -eq $arrayNewCSVData ) {
    #Nothing more to process
    $RowError = @{
        Severity    = "No new files"
        Process     = "Checking for changed data"
        Message     = "Revised date:$DateLastModifiedUTC"
        Correction  = "Noting to process"
        CurrentLine = $MyInvocation.ScriptLineNumber
    }
    $ErrorLog += $RowError
    $RowError 
    $ErrorLog | ConvertTo-Json | Out-File -FilePath  ($TempDataLocation, "Error-Log.json" -join "")
}
else {

    # Work the data in the $CSVLinks array by the CsvTodayKey (report date)
    $SortedCSVs = $arrayNewCSVData | Sort-Object -Property CsvFileName 

    # Start the process of reading each of the file records and the rows within them
    $UnpivotedRows = @()
    $FullDataRow = @()

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
    
        $ActualColumns = $CSV.CSVData[0].psobject.properties.name

        for ( $RowNumber = 0; $RowNumber -lt $Csv.CSVData.Length; $RowNumber++ ) {
            $Row = $Csv.CSVData[$RowNumber]
            $Mapping = $MappingPSO.PSObject.copy()
            $AllColumns = $AllColumnsPSO.PSObject.copy()

            #Map the base columns to the new column names for the row
            for ($i = 0; $i -lt $ActualColumns.Count; $i++ ) {

                $Key = $NewColumnsMapping.($ActualColumns[$i])
                $AllColumns.($ActualColumns[$i]) = $Row.($ActualColumns[$i]) 

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
                $Mapping.$Key = $Value 
            }
            Write-Host ("File # = ", $FileNumber, " Processing Row# ", $RowNumber, " out of ", $Csv.CSVData.Length, " Country = ", $Mapping.'Country or Region' -Join "")

            $Mapping.'Date Reported' = $DateReported 


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
                    $Mapping.'Province or State' = $Value.Trim()
                }
                if ( $Mapping.'Province or State' -like "*, *" ) {
                    # Looking at older file format. New format as the full state name
                    $County, $StateCode = ($Mapping.'Province or State').Split(", ")
                    if ($County -like "*County") { 
                        $CountyValue = $County.Split(" County")[0]
                    }
                    else { $CountyValue = $County }
                    $Mapping.'USA State County' = $CountyValue
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
                                CurrentLine = $MyInvocation.ScriptLineNumber
                            }
                            $ErrorLog += $RowError
                        }
                    }
                }
                if ($Mapping.'Province or State' -ne "" -and $null -ne $Mapping.'Province or State') {
                    $Values += $Mapping.'Province or State'.Trim()
                }
            
            }
            if ( ($Mapping.'Country or Region').Length -gt 0 ) {
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
                    CurrentLine = $MyInvocation.ScriptLineNumber
                }
                $ErrorLog += $RowError
                $Value = "Unknown row in file # $FileNumber and row number $RowNumber"
            }

            $Mapping.'Location Name Key' = $Value.Trim() 
            if ( $Value.Split(', ').Count -eq 3 -and $Value.Split(', ')[2] -eq "USA" ) {
                $TI = (Get-Culture).TextInfo
                $Mapping.'USA County State Key' = $TI.ToTitleCase($Value.Split(', USA')[0])
            }


            $Mapping.'File Number' = $FileNumber
            $Mapping.'Row Number' = $RowNumber

            $Active = 0

            $Mapping.Attribute = "Confirmed"
            $Mapping.'Cumulative Value' = [int]($Row.Confirmed) 
            $UnpivotedRows += [PSCustomObject]$Mapping

            $AllColumns.'Days Since First Value' = [int]($Row.Confirmed)
            $AllColumns.'Days Since First Confirmed' = [int]($Row.Confirmed)
        
            $Mapping.Attribute = "Deaths"
            $Mapping.'Cumulative Value' = [int]($Row.Deaths)
            $UnpivotedRows += [PSCustomObject]$Mapping
            $AllColumns.'Days Since First Death' = [int]($Row.Deaths)
        
            $Mapping.Attribute = "Recovered"
            $Mapping.'Cumulative Value' = [int]($Row.Recovered)
            $UnpivotedRows += [PSCustomObject]$Mapping
            $AllColumns.'Days Since First Recovered' = [int]($Row.Recovered)

            $Mapping.Attribute = "Active"
            $Mapping.'Cumulative Value' = [int]($Row.Active)
            if ( $Mapping.'Cumulative Value' -eq 0 ) {
                $Mapping.'Cumulative Value' = $AllColumns.'Days Since First Confirmed' - $AllColumns.'Days Since First Death' - $AllColumns.'Days Since First Recovered'
            }
            if ( [int]($Row.Active) -ne $Mapping.'Cumulative Value' ) {
                $AllColumns.'Active Original' = [int]($AllColumns.Active)
            }
            $AllColumns.Active = $Mapping.'Cumulative Value'
            $AllColumns.'Days Since First Active' = $Mapping.'Cumulative Value'
            $UnpivotedRows += [PSCustomObject]$Mapping    
            
            foreach ( $MK in $Mapping.PSObject.Properties.Name) {
                if ( $null -eq $AllColumns.$MK -and $null -ne $Mapping.$MK ) {
                    $AllColumns.$MK = $Mapping.$MK
                }
            }
            $FullDataRow += $AllColumns

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

    # Write out the updated CSSEGISandData-COVID-19-Derived.csv as needed
    $FirstTime = $True
    $OrderedKeys = $GroupedFileRows.Keys | Sort-Object
    $SelectColumnList = @(
        'Attribute'                 ,
        'Daily Value'               ,
        'Days Since First Value'    ,
        'Country or Region'         ,
        'CSV File Name'             ,
        'Cumulative Value'          ,
        'Date Reported'             ,
        'FIPS USA State County code',
        'Last Updated UTC'          ,
        'Location Name Key'         ,
        'Province or State'         ,
        'Row Number'                ,
        'USA State County'          ,
        'USA County State Key'      
    )
    
    $SortList = @(
        @{Expression = "CSV File Name"; Descending = $False }
        , @{Expression = "Country or Region"; Descending = $False }
        , @{Expression = "Province or State"; Descending = $False }
        , @{Expression = "USA State County"; Descending = $False }
    )

    foreach ( $KeyValue in $OrderedKeys) {
        # $Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
        # if ( $Continue -ne "Yes") { Exit 0 }
        Write-Host $KeyValue
  
        if ( $FirstTime -eq $true -and $DebugOptions.UpdateLocalFiles) {
            $GroupedFileRows.$KeyValue | Select-Object -Property $SelectColumnList | Sort-Object -Property $SortList  | Export-Csv -Path ($GitLocalRoot, "\", $DataDir, "\", "CSSEGISandData-COVID-19-Derived.csv" -join "") -NoTypeInformation 
            $FirstTime = $false
        }
        else {
            $GroupedFileRows.$KeyValue | Select-Object -Property $SelectColumnList | Sort-Object -Property $SortList | Export-Csv -Path ($GitLocalRoot, "\", $DataDir, "\", "CSSEGISandData-COVID-19-Derived.csv" -join "") -NoTypeInformation -Append
        }
        if ( $DebugOptions.WriteFilesToTemp ) {
            $GroupedFileRows.$KeyValue | Select-Object -Property $SelectColumnList | Sort-Object -Property $SortList | Export-Csv -Path ( $DebugOptions.TempPath , "\", "CSSEGISandData-COVID-19-Derived-", $KeyValue -join "") -NoTypeInformation
        }
    }

    # Write out the new or updated Daily-Files-Metadata.csv
    $LocalDataFilesMetadata | Split-Path -LeafBase
    if ( $DebugOptions.WriteFilesToTemp) {
        $OutputPath = ($DebugOptions.TempPath, "\", ($LocalDataFilesMetadata | Split-Path -LeafBase), ".yaml" -join "")
        $FilesInfo | ConvertTo-Yaml | Out-File -Path $OutputPath
    }
    if ( $DebugOptions.UpdateLocalFiles ) {
        $OutputPath = $LocalDataFilesMetadata
        $FilesInfo | Export-Csv -Path $OutputPath -NoTypeInformation 
    }
}

if ( $DebugOptions.WriteFilesToTemp ) {
    $FullDataRow |  Sort-Object -Property $SortList | Export-Csv -Path ( $DebugOptions.TempPath , "\", "CSSEGISandData-COVID-19-Derived-FullList.csv" -join "") -NoTypeInformation
}

$Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
if ( $Continue -ne "Yes") { Exit 0 }


if ( 1 -eq 1 ) {


    if ($DebugOptions.WriteFilesToTemp ) {
        $OutputPath = $DebugOptions.TempPath, "\", "Missing-Lat-Long-Records.csv" -join "" 
        $MissingLatLong = $PriorDataRows | Where-Object { ( $_.Latitude -eq "" -or $_.Longitude -eq "" ) } | Sort-Object -Property 'Location Name Key' -Unique | Select-Object 'Location Name Key', Latitude, Longitude, 'CSV File Name', 'Row Number'
        Write-Host "Number of records with Missing Lat/Long: ", $MissingLatLong.Count
        $MissingLatLong | Export-Csv -Path $OutputPath -NoTypeInformation -UseQuotes AsNeeded
    }
    if ($DebugOptions.UpdateLocalFiles) {
        $OutputPath = $GitLocalRoot, "\Working Files\", "Missing-Lat-Long-Records.csv" -join ""
        Write-Host "Number of records with Missing Lat/Long: ", $MissingLatLong.Count
        $MissingLatLong | Export-Csv -Path $OutputPath -NoTypeInformation -UseQuotes AsNeeded
    }
    $ZeroForLatLong = $PriorDataRows | Where-Object { ( $_.Latitude -eq "0" -and $_.Longitude -eq "0" ) } | Sort-Object -Property 'Location Name Key' -Unique | Select-Object 'Location Name Key', Latitude, Longitude, 'CSV File Name', 'Row Number'
    Write-Host "Number of records with 0 values for Lat and Long: ", $MissingLatLong.Count
    $ZeroForLatLong | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Zeros-For-Lat-Long-Records.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded


    $UnknownOrUnassignedCounties = $PriorDataRows | Where-Object { ( $_.'USA State County' -eq "Unknown" -or $_.'USA State County' -eq "Unassigned" ) } | Sort-Object -Property @{Expression = 'Location Name Key' } -Unique 
    Write-Host "County values where values are Unknown or Unassigned: ", $UnknownOrUnassignedCounties.Count
    $UnknownOrUnassignedCounties | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Unassigned-or-Unknown-Counties.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded

    $UniqueLocationKeys = $PriorDataRows | Sort-Object -Property 'Location Name Key' -Unique | Select-Object 'Location Name Key', Latitude, Longitude, 'Country or Region', 'Province or State', 'USA State County', 'FIPS USA State County code'
    Write-Host "Count of unique values for 'Location Name Key': ", $UniqueLocationKeys.Count
    $UniqueLocationKeys | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Unique-Location-Name-Key-values.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded

    $SpacesInCountyValue = $PriorDataRows | Where-Object { ( $_.'Location Name Key' -eq " Norfolk, MA, USA" -or $_.'Location Name Key' -eq " Montreal, QC, Canada" ) }
    Write-Host "Count of SpacesInCountyValue: ", $SpacesInCountyValue.Count
    $SpacesInCountyValue | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Spaces-In-County-Value.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded

    $UniqueLocationKeysWithLatLong = $PriorDataRows | Where-Object { ( $_.Latitude -ne "0" -and $_.Latitude -ne "" -and $_.Longitude -ne "0" -and $_.Longitude -ne "" ) } | Sort-Object -Property 'Location Name Key' -Unique | Select-Object 'Location Name Key', Latitude, Longitude, 'Country or Region', 'Province or State', 'USA State County', 'FIPS USA State County code'
    Write-Host "Count of unique values for 'Location Name Key' with Lat and Long: ", $UniqueLocationKeysWithLatLong.Count
    $UniqueLocationKeysWithLatLong | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Unique-Location-Name-Key-With-Lat-and-Long.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded

    $OddStateValues = $PriorDataRows | Where-Object { ( $_.'Province or State' -eq "None" -or $_.'Province or State' -eq "US" -or $_.'Province or State' -eq "Recovered" ) } | Sort-Object -Property 'Location Name Key'# -Unique
    Write-Host "Count of unique values for OddStateValues: ", $OddStateValues.Count
    $OddStateValues | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Odd-State-Values.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded


    $FirstConfirmedReports = $PriorDataRows | Where-Object { ( $_.'Attribute' -eq "Confirmed" -and $_.'Cumulative Value' -ne "0" -and $_.'Cumulative Value' -ne ""  ) } | Sort-Object -Property @{Expression = 'Location Name Key' }, @{Expression = 'CSV File Name' } -Unique
    Write-Host "Count of unique values for FirstConfirmedReports: ", $FirstConfirmedReports.Count
    $FirstConfirmedReports | Export-Csv -Path ($GitLocalRoot, "\Data-Files\", "First-Confirmed-Reports.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded


    $FirstDeathReports = $PriorDataRows | Where-Object { ( $_.'Attribute' -eq "Deaths" -and $_.'Cumulative Value' -ne "0" -and $_.'Cumulative Value' -ne ""  ) } | Sort-Object -Property @{Expression = 'Location Name Key' }, @{Expression = 'CSV File Name' } -Unique
    Write-Host "Count of unique values for FirstDeathReports: ", $FirstDeathReports.Count
    $FirstDeathReports | Export-Csv -Path ($GitLocalRoot, "\Data-Files\", "First-Deaths-Reports.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded


    $FirstRecoveredReports = $PriorDataRows | Where-Object { ( $_.'Attribute' -eq "Recovered" -and $_.'Cumulative Value' -ne "0" -and $_.'Cumulative Value' -ne ""  ) } | Sort-Object -Property @{Expression = 'Location Name Key' }, @{Expression = 'CSV File Name' } -Unique
    Write-Host "Count of unique values for FirstRecoveredReports: ", $FirstRecoveredReports.Count
    $FirstRecoveredReports | Export-Csv -Path ($GitLocalRoot, "\Data-Files\", "First-Recovered-Reports.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded


    $USStateLatLongData = $PriorDataRows | Where-Object { ( $_.'Country or Region' -eq "USA" -and $_.'Province or State' -ne "" -and $_.'USA State County' -eq "" -and $_.Latitude -ne "0" -and $_.Latitude -ne "" -and $_.Longitude -ne "0" -and $_.Longitude -ne "" ) } | Sort-Object -Property 'Location Name Key' -Unique | Select-Object 'Location Name Key', Latitude, Longitude, 'Country or Region', 'Province or State', 'USA State County', 'FIPS USA State County code'
    Write-Host "Count of unique values for USStateLatLongData: ", $USStateLatLongData.Count
    $USStateLatLongData | Export-Csv -Path ($GitLocalRoot, "\Data-Files\", "US-State-Lat-Long-Data.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded

    #Create one file for all of the reported locations to use as a look up file for the 'Location Name Key' value
    $UniqueLocationKeys[0].psobject.Properties.Name
    $UniqueLocationKeysWithLatLong[0].psobject.Properties.Name
    $MissingLatLong.Count 
    $ZeroForLatLong.Count

    $ArrayMissing = @()
    $ArrayFound = @()
    foreach ( $Location in $UniqueLocationKeys ) {
        if ( ( $Location.Latitude -eq "0" -and $Location.Longitude - "0" ) -or ($Location.Latitude -eq "" -or $Location.Longitude -eq "") ) {
            $LatLong = $UniqueLocationKeysWithLatLong | Where-Object { ( $_.'Location Name Key' -eq $Location.'Location Name Key' ) }
            if ( $null -eq $LatLong ) {

                $ArrayMissing += $Location
            }
            else {
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
    $ArrayFound | Select-Object 'Location Name Key', Latitude, Longitude, 'Country or Region', 'Province or State', 'USA State County', 'FIPS USA State County code' | Export-Csv -Path ($GitLocalRoot, "\Data-Files\", "Unique-Location-Name-Key-values.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded 
    #Used https://www.latlong.net/
    $ManualResolution = @(
        [PSCustomObject]@{'Location Name Key' = "Ashland, NE, USA"; Latitude = "41.036140"; Longitude = "-96.360940"; 'Country or Region' = "USA"; 'Province or State' = "NE"; 'USA State County' = "Ashland"; 'FIPS USA State County code' = "99999" }
        , [PSCustomObject]@{'Location Name Key' = "Australia"; Latitude = "-25.274399"; Longitude = "133.775131"; 'Country or Region' = "Australia"; 'Province or State' = ""; 'USA State County' = ""; 'FIPS USA State County code' = "" }
        , [PSCustomObject]@{'Location Name Key' = "Bavaria, Germany"; Latitude = "48.917431"; Longitude = "11.407980" ; 'Country or Region' = "Germany"; 'Province or State' = "Bavaria"; 'USA State County' = ""; 'FIPS USA State County code' = "" }
        , [PSCustomObject]@{'Location Name Key' = "Cruise Ship, Others"; Latitude = "25.695980"; Longitude = "32.645649" ; 'Country or Region' = "Others"; 'Province or State' = "Cruise Ship"; 'USA State County' = ""; 'FIPS USA State County code' = "" }
        , [PSCustomObject]@{'Location Name Key' = "External territories, Australia"; Latitude = "-10.484470"; Longitude = "105.637100" ; 'Country or Region' = "Australia"; 'Province or State' = "NE"; 'USA State County' = ""; 'FIPS USA State County code' = "" }
        , [PSCustomObject]@{'Location Name Key' = "From Diamond Princess, Israel"; Latitude = "32.089556"; Longitude = "34.797614" ; 'Country or Region' = "Israel"; 'Province or State' = "From Diamond Princess"; 'USA State County' = ""; 'FIPS USA State County code' = "" }
        , [PSCustomObject]@{'Location Name Key' = "Ivory Coast"; Latitude = "-22.497511"; Longitude = "17.015369" ; 'Country or Region' = "Ivory Coast"; 'Province or State' = ""; 'USA State County' = ""; 'FIPS USA State County code' = "" }
        , [PSCustomObject]@{'Location Name Key' = "Jervis Bay Territory, Australia"; Latitude = "-35.140020"; Longitude = "150.728240" ; 'Country or Region' = "Australia"; 'Province or State' = "Jervis Bay Territory"; 'USA State County' = ""; 'FIPS USA State County code' = "" }
        , [PSCustomObject]@{'Location Name Key' = "Nashua, NH, USA"; Latitude = "42.757870"; Longitude = "-71.463951" ; 'Country or Region' = "USA"; 'Province or State' = "NH"; 'USA State County' = "Nashua"; 'FIPS USA State County code' = "99999" }
        , [PSCustomObject]@{'Location Name Key' = "None, Austria"; Latitude = "47.516232"; Longitude = "14.550072" ; 'Country or Region' = "Austria"; 'Province or State' = "None"; 'USA State County' = ""; 'FIPS USA State County code' = "" }
        , [PSCustomObject]@{'Location Name Key' = "None, Iraq"; Latitude = "33.223190"; Longitude = "43.679291" ; 'Country or Region' = "Iraq"; 'Province or State' = "None"; 'USA State County' = ""; 'FIPS USA State County code' = "99999" }
        , [PSCustomObject]@{'Location Name Key' = "None, Lebanon"; Latitude = "33.854721"; Longitude = "35.862286" ; 'Country or Region' = "Lebanon"; 'Province or State' = "None"; 'USA State County' = ""; 'FIPS USA State County code' = "99999" }
        , [PSCustomObject]@{'Location Name Key' = "North Ireland"; Latitude = "54.597271"; Longitude = "-5.930110" ; 'Country or Region' = "Ireland"; 'Province or State' = "Belfast"; 'USA State County' = ""; 'FIPS USA State County code' = "99999" }
        , [PSCustomObject]@{'Location Name Key' = "Out-of-state, TN, USA"; Latitude = "36.162663"; Longitude = "-86.781601" ; 'Country or Region' = "USA"; 'Province or State' = "TM"; 'USA State County' = "Out-of-state"; 'FIPS USA State County code' = "99999" }
        , [PSCustomObject]@{'Location Name Key' = "Plymonth, MA, USA"; Latitude = "41.955750"; Longitude = "-70.664390" ; 'Country or Region' = "USA"; 'Province or State' = "MA"; 'USA State County' = "Plymonth"; 'FIPS USA State County code' = "99999" }
        , [PSCustomObject]@{'Location Name Key' = "Sterling, AK, USA"; Latitude = "60.537470"; Longitude = "-150.765050" ; 'Country or Region' = "USA"; 'Province or State' = "AK"; 'USA State County' = "Sterling"; 'FIPS USA State County code' = "99999" }
        , [PSCustomObject]@{'Location Name Key' = "Travis, CA, USA"; Latitude = "38.291790"; Longitude = "-121.921097" ; 'Country or Region' = "USA"; 'Province or State' = "CA"; 'USA State County' = "Travis"; 'FIPS USA State County code' = "99999" }
        , [PSCustomObject]@{'Location Name Key' = "Unknown, TN, USA"; Latitude = "36.162663"; Longitude = "-86.781601" ; 'Country or Region' = "USA"; 'Province or State' = "TM"; 'USA State County' = "Unknown"; 'FIPS USA State County code' = "99999" }
    )
    $ManualResolution | Select-Object 'Location Name Key', Latitude, Longitude, 'Country or Region', 'Province or State', 'USA State County', 'FIPS USA State County code' | Export-Csv -Path ($GitLocalRoot, "\Data-Files\", "Unique-Location-Name-Key-values.csv" -join "") -NoTypeInformation -UseQuotes AsNeeded -Append
}