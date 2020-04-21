<#
Title:       Get-Covid_CSSEGIS_Daily_Reports.ps1
Description: Create an CSV file based on daily reports from in the https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_daily_reports folder.
Author:      Bill Ramos, DB Best Technologies
MoreInfo:    https://github.com/db-best-technologies/Covid-19-Power-BI/blob/master/PowerShell/Get-Covid_CSSEGIS_Daily_Reports.yaml
#>

if ( $true ) <# Setup execution environment #> {
    $DebugParameters = @{
        WriteFilesToTemp       = $true 
        TempPath               = "C:\Temp\Covid-Temp-Files" 
        DeleteTempFilesAtStart = $false 
        UpdateLocalFiles       = $true 
        AppendDebugData        = $false 
        Workaround             = $false 
        ForceDownload          = $true 
        LoadFromWorkingFiles   = $false
        LoadNewUSFiles         = $true
        LoadKeyFiles           = $true
    }
    $DebugOptions = Set-DebugOptions @DebugParameters
    $DebugOptions 
    Start-Sleep -Seconds 5

    if ( $true ) <# Define local variables #> {
        $Errorlog = @()
        $GitLocalRoot = Get-Location

        $LeafDataFile = "DBT_JHU_Unpivoted_Data"
        $DataDir = "Data-Files"
        $WorkingFiles = "Working Files"
        $GitSourceAccount = "CSSEGISandData"
        $GitSourceProject = "COVID-19"
        $GitBranch = "master"
        $RowFmt = "0000"
        $UIDFmt = "0000000000"

    } <# END: if ( $true )  Define local variables #>

    $Paths = @{
        JSU_COVID_19_master_Branch_data_PAGE    = "https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data"
        JSU_COVID_19_master_Branch_data_RAW     = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/"

        JSU_csse_covid_19_daily_reports_PAGE    = "https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_daily_reports"
        JSU_csse_covid_19_daily_reports_RAW     = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/"
        
        JSU_csse_covid_19_daily_reports_us_PAGE = "https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_daily_reports_us"
        JSU_csse_covid_19_daily_reports_us_RAW  = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports_us/"
        
        JSU_web_data_branch_PAGE                = "https://github.com/CSSEGISandData/COVID-19/tree/web-data"
        JSU_web_data_branch_Override_PAGE       = "https://github.com/CSSEGISandData/COVID-19/tree/web-data/override" 
        JSU_web_data_branch_Override_RAW        = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/web-data/override/"

        JSU_web_data_branch_Data_PAGE           = "https://github.com/CSSEGISandData/COVID-19/tree/web-data/data"
        JSU_web_data_branch_Data_RAW            = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/web-data/data/"


        DBB_Covid_19_Power_BI_PAGE              = "https://github.com/db-best-technologies/Covid-19-Power-BI/tree/dev"
        DBB_Covid_19_Power_BI_data_files_PAGE   = "https://github.com/db-best-technologies/Covid-19-Power-BI/tree/dev/Data-Files"
        DBB_GitHub_Data_Files_RAW               = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/dev/Data-Files/"
        DBB_GitHub_Working_Files_RAW            = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/dev/Working Files/"
    }
    
    $URLs = [ordered]@{
        UID_ISO_FIPS_LookUp_Table                = $Paths.JSU_COVID_19_master_Branch_data_RAW, "UID_ISO_FIPS_LookUp_Table.csv" -join ""
        dimUS_zip_codes_states                   = $Paths.DBB_GitHub_Data_Files_RAW, "Dimension.ZipCode_City_State_Mapping.csv" -join ""
        web_data_override                        = $Paths.JSU_web_data_branch_Override_RAW, "override.csv" -join ""

        JSU_csse_covid_19_daily_reports_PAGE     = $Paths.JSU_csse_covid_19_daily_reports_PAGE
        JSU_csse_covid_19_daily_reports_RAW      = $Paths.JSU_csse_covid_19_daily_reports_RAW

        DBT_Daily_Reports_Files_Loaded           = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/Data-Files/DBT_Daily_Reports_Files_Loaded.csv"
        csse_covid_19_daily_reports_raw          = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports"
        CSSEGISandData_web_data_override_page    = "https://github.com/CSSEGISandData/COVID-19/tree/web-data/override"
        
        CSSEGISandData__daily_reports_page       = "https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data"
        CSSEGISandData_Readme_md                 = "https://github.com/CSSEGISandData/COVID-19/blob/master/README.md"
        DBBestDerivedData                        = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/dev/", $DataDir, "/", $LeafDataFile, ".csv" -join ""
        DBBestDerivedMetadata                    = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/dev/", $DataDir, "/", $LeafDataFile, ".json" -join ""
        DBT_JHU_Files_Processed_For_Current_Data = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/dev/", $WorkingFiles, "/", $LeafDataFile, "-SourceFiles.csv" -join ""
        DBT_JHU_Unpivoted_Data                   = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/dev/", $WorkingFiles, "/", $LeafDataFlie, ".csv" -join ""
        csse_covid_19_daily_reports_us           = "https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_daily_reports_us"
        DBB_Last_Upload_AllColumns               = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/dev/Working%20Files/DBT_FullDataRow_Daily_Reports.csv"
        DBT_FullDataRow_Daily_Reports            = "$($DBB_GitHub_Working_Files)DBT_FullDataRow_Daily_Reports.csv"
        
    }

    $LocalFiles = [ordered]@{
        LocalWorkingGitPath                       = "$((Get-location).Path)\Working Files\"
        LocalDataGitPath                          = "$((Get-location).Path)\Data-Files\"
        DBT_Daily_Reports_Files_Loaded            = "$((Get-location).Path)\Data-Files\Table.Covid_19_Cases_By_County_State_Country.json"
        UID_ISO_FIPS_LookUp_Table                 = "$((Get-location).Path)\Data-Files\Dimension.County_State_Country.csv"
        dimUS_zip_codes_states                    = "$((Get-location).Path)\Data-Files\Dimension.ZipCode_City_State_Mapping.csv"
        DBT_JHU_Unpivoted_Data                    = "$((Get-location).Path)\Data-Files\Fact.Covid_19_Cases_By_County_State_Country.csv"
        DBB_Last_Upload_AllColumns                = "$((Get-location).Path)\Working Files\JHU__master_csv_csse_covid__19_daily_reports__AllColumns.csv"
        DBT_FullDataRow_Daily_Reports             = "$((Get-location).Path)\Working Files\JHU__master_csv_csse_covid__19_daily_reports__FullDataRow.csv"
        csse_covid_19_daily_reports_us_local_path = "$((Get-location).Path)\Working Files\JHU__master_csv_csse_covid__19_daily_reports_us__"
        JHU_web_data_override_location_mapping    = "$((Get-location).Path)\Working Files\JHU__web-data__override__override.csv"
        dim_USPS_State_Code                       = "$((Get-location).Path)\Working Files\USPS__pe.usps.com__28apb.csv"
        JHU_Daily_Files                           = "$((Get-location).Path)\Working Files\JHU__master__csv_csse_covid_19_daily_reports__"
    }

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
        'Combined_Key'   = "Combined_Key"
        'Province/State' = "Province or State"
        'Country/Region' = "Country or Region"
        'Latitude'       = "Latitude"
        'Longitude'      = "Longitude"
        'CSV File Name'  = 'CSV File Name'
    }
    $LocationKeyClass = @{  # Create an Index for the Location Name Key values
        'Location Name Key'          = ""
        'Number of Rows'             = 0        # Should always be count of 'CSV Rows PSObj Array'
        'CSV Rows PSObj Array'       = @()      # Array of $AllColumnPSO class items
        'DayZeroItems'               = $null    # As a PSCustomObject using $DayZeroItemsClass
        'Latitude'                   = $null
        'Longitude'                  = $null
        'Population'                 = $null
        'Combined_Key'               = $null
        'Country or Region'          = $null
        'Province or State'          = $null
        'USA State County'           = $null
        'FIPS USA State County code' = $null
        'State'                      = $null   # US State code
        'Name'                       = $null   # US State Name
        'USA or Global'              = $null   # Values: "United States", "Global"
        'County State Key'           = $null   # US County, US State Code in Upper Case for Hospital key .ToUpper()
    }
    $LocationNameKeyIndex = @{ 
        # Index of values by 'Location Name Key'
        # Value for Location Name  =  Hash Table of Type $LocationKeyClass
    }
    $UIDClass = [PSCustomObject]@{
        UID                   = $null
        iso2                  = $null
        iso3                  = $null
        code3                 = $null
        FIPS                  = $null
        Admin2                = $null
        Province_State        = $null
        Country_Region        = $null
        Lat                   = $null
        Long_                 = $null
        Combined_Key          = $null
        Population            = $null
        State_Code            = $null
        'Location Name Key'   = $null
        'US State County Key' = $null
        Row_No_Source_File    = $null
    }
    $AllColumnsPSO = [PSCustomObject]@{
        'Location Index'             = -1
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

        'US State Name'              = $null
        'Other Data Prov/State'      = $null
        'US Invalid State Name'      = $null
        'US Invalid County Name'     = $null
        'Ship Name'                  = $null 
        'Combined_Key_NotFound'      = $null
        'State_Code'                 = $null
        'Population'                 = $null

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
    
        'Confirmed Delta Value'      = $null
        'Deaths Delta Value'         = $null
        'Recovered Delta Value'      = $null
        'Active Delta Value'         = $null
    }
    
    $DayZeroItemsClass = [PSCustomObject]@{
        'Location Name Key'                 = $null
        'Event First CSV File Name'         = $null
        'Event First Location Name Key'     = $null
        'Event First Date'                  = $null
        'Event First Value'                 = $null

        'Confirmed First CSV File Name'     = $null
        'Confirmed First Location Name Key' = $null
        'Confirmed First Date'              = $null
        'Confirmed First Value'             = $null

        'Deaths First CSV File Name'        = $null
        'Deaths First Location Name Key'    = $null
        'Deaths First Date'                 = $null
        'Deaths First Value'                = $null

        'Recovered First CSV File Name'     = $null
        'Recovered First Location Name Key' = $null
        'Recovered First Date'              = $null
        'Recovered First Value'             = $null

        'Active First CSV File Name'        = $null
        'Active First Location Name Key'    = $null
        'Active First Date'                 = $null
        'Active First Value'                = $null
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
        'Combined_Key'               = $null 
        'Longitude'                  = $null
        'Province or State'          = $null
        'Population'                 = $null
        'Row Number'                 = $null
        'USA State County'           = $null
        'USA County State Key'       = $null
        'US State Name'              = $null
        'Ship Name'                  = $null 
        'State_Code'                 = $null
    }
    $CountryReplacements = [PSCustomObject]@{
        <#    'Mainland China' = "China"
        'South Korea'    = "Korea, South"
        'Taiwan'         = 'Taiwan*'
        'Macau'          = "China"
        'Hong Kong'      = "China"
        'US'             = "USA"
    #>
    }
    $CountyReplacements = [PSCustomObject]@{
        #    'New York City'       = "New York"
        #    'Brockton'            = "Plymonth"
        #    'Dukes and Nantucket' = "Nantucket"
        #    'Unknown'             = ""
        #    'Soldotna'            = "Kenai Peninsula"
        #    'LeSeur'              = "Le Sueur"
        #    'Unassigned'          = ""
    }
    $StateReplacements = [PSCustomObject]@{
        #    'Chicago'                                     = "Cook, IL"
        #    '(From Diamond Princess)'                     = "Diamond Princess Japan, TX"
        #    'Grand Princess Cruise Ship'                  = "Grand Princess Oakland, CA"
        #    'Grand Princess'                              = "Grand Princess Oakland, CA"
        #    'Diamond Princess'                            = "Diamond Princess Japan, TX"
        #    'United States Virgin Islands'                = "St. Croix, PR"
        #    'Unassigned Location (From Diamond Princess)' = "Diamond Princess Japan, TX"
        #    'Chicago, IL'                                 = "Cook, IL"
        #    'Lackland, TX'                                = "Bexar, TX"
        #    'None'                                        = ""
        #    'US'                                          = ""
        #    'Recovered'                                   = ""
        #     'Wuhan Evacuee'                               = 'California'
    }

    if ( $DebugOptions.LoadKeyFiles ) <# Using dimUSPSStateCodeWithLatLong.csv to create  $StateCodeFromName and $StateNameFromCode #> {
        # Example:  $StateCodeFromName.'CA'          -> "California"
        #           $StateCodeFromName.'California'  -> "CA" 
        $USStateCSV = Import-Csv -Path $LocalFiles.dim_USPS_State_Code
        Write-Host "Creating indexes StateCodeFromName and StateNameFromCode"
        $StateCodeFromName = @{ }
        $StateNameFromCode = @{ }
        if ( $USStateCSV[0].psobject.Properties.Match('Combined_Key').Name.Length -eq 0 ) {
            $USStateCSV | Add-Member -MemberType NoteProperty -Name "Combined_Key" -Value $null
        }
        foreach ( $State  in $USStateCSV ) {
            $StateCode = $State.State_Code
            $StateName = $State.Province_State
            if ( $State.Combined_Key.Length -eq 0 ) {
                $State.Combined_Key = Get-BuildCombinedKey $StateName, "US"
            }
            $StateCodeFromName.Add( $StateName, $StateCode)
            $StateNameFromCode.Add( $StateCode, $StateName )
        } 
        $USStateCSV | Export-Csv -Path "C:\Temp\Covid-Temp-Files\USPS__pe.usps.com__28apb.csv" -NoTypeInformation
    }<# END: Using dimUSPSStateCodeWithLatLong.csv to create  $StateCodeFromName and $StateNameFromCode #>

    if ( $DebugOptions.LoadKeyFiles ) <# Load of $Combined_Key index from dimUID_ISO_FIPS_LookUp_Table.csv #> {
        # UID: 84070005; Combined_Key: "Federal Correctional Institution (FCI), Michigan, US" 42.094563, -83.669482
        # UID: 84070004 ; Combined_Key: "Michigan Department of Corrections (MDOC),Michigan,US" 42.733158, -84.550168
        $FIPS_WR = Invoke-WebRequest -Uri $URLs.UID_ISO_FIPS_LookUp_Table
        if ( $null -eq $FIPS_WR.Content ) {
            $Errorlog += $FIPS_WR.Headers
            $FIPS_WR.Headers | ft
            Start-Sleep -Seconds 1
            $Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
            if ( $Continue -eq "No") { Exit 0 }
        }
        if ( $null -ne $FIPS_WR -and $null -ne $FIPS_WR.Content ) {
            #Download the Metadata file from our GitHub project
            Write-Host "Creating index for dimUID_ISO_FIPS_LookUp_Table.csv for Combined_Key lookup" 
            $FIPS_WR.Content | Out-File -FilePath  $LocalFiles.UID_ISO_FIPS_LookUp_Table
            $UID_ISO_FIPS_LookupCSV = Import-Csv -Path $LocalFiles.UID_ISO_FIPS_LookUp_Table | Sort-Object  Country_Region, Province_State
            $UID_ISO_FIPS_LookupCSV | Add-Member -MemberType NoteProperty -Name 'State_Code' -Value $null
            $UID_ISO_FIPS_LookupCSV | Add-Member -MemberType NoteProperty -Name 'Location Name Key' -Value $null
            $UID_ISO_FIPS_LookupCSV | Export-Csv -path $LocalFiles.UID_ISO_FIPS_LookUp_Table -NoTypeInformation

            $Combined_Key = @{ }
            if ( $false ) {
                #Missing Combined_Key = 'Federated States Of Micronesia, US'
                $UID = $UID_ISO_FIPS_LookupCSV[1250] # Grab a value
                $UID.UID = "85099999"
                $UID.iso2 = "FM"
                $UID.iso3 = $null
                $UID.code3 = "85099999"
                $UID.FIPS = "64003"
                $UID.Admin2 = $null
                $UID.Province_State = "Federated States of Micronesia"
                $UID.Country_Region = "US"
                $UID.Lat = "6.916667" # https://tools.wmflabs.org/geohack/geohack.php?pagename=Federated_States_of_Micronesia&params=6_55_N_158_15_E_
                $UID.Long_ = "158.25" # https://tools.wmflabs.org/geohack/geohack.php?pagename=Federated_States_of_Micronesia&params=6_55_N_158_15_E_
                $UID.Combined_Key = $UID.Province_State, $UID.Country_Region -join ", "
                $UID.Population = "112640" # https://en.wikipedia.org/wiki/Federated_States_of_Micronesia
                $UID.State_Code = "FM"
                $UID.'Location Name Key' = "FM, US"
                $UID.'US State County Key' = $UID.Combined_Key
                $Combined_Key.Add( $UID.Combined_Key, $UID )
            }
            $ProgressValue = $null 
            foreach ( $UID in $UID_ISO_FIPS_LookupCSV ) {
                $UID.UID = ([int]$UID.UID).ToString("0000000000")
                # Create the location code based on the parts of Combined_Key
                if ( "US" -eq $UID.Country_Region ) {
                    if ( ($StateCodeFromName.($UID.Province_State).State_Code).Length -gt 0 ) {
                        $UID.State_Code = $StateCodeFromName.($UID.Province_State).State_Code 
                    }
                    else {
                        $UID.State_Code = $UID.Province_State 
                    }
                    $UID.'Location Name Key' = Get-BuildCombinedKey $UID.Admin2, $UID.State_Code, $UID.Country_Region        
                }
                else { 
                    $UID.'Location Name Key' = Get-BuildCombinedKey $UID.Admin2, $UID.Province_State, $UID.Country_Region   
                }
                
                # Make corrections based on $UID.UID
                if ( [int]$UID.UID -eq [int]("84070005") ) {
                    $UID.Lat = "42.094563"
                    $UID.Long_ = "-83.669482"
                }
                elseif ( [int]$UID.UID -eq [int]("84070004") ) {
                    $UID.Lat = "42.733158"
                    $UID.Long_ = "-83.550168"
                }
                $Combined_Key.Add( $UID.Combined_Key, $UID )
                $ProgressValueKey = $UID.Province_State, $UID.Country_Region -join " | "
                if ( $ProgressValue -ne $ProgressValueKey ) {
                    Write-Host "Progress: ", $ProgressValueKey
                    $ProgressValue = $ProgressValueKey
                }
            }
            $UID_ISO_FIPS_LookupCSV | Export-Csv -Path $LocalFiles.UID_ISO_FIPS_LookUp_Table -NoTypeInformation
        }
    } <# END: Load of $Combined_Key index from dimUID_ISO_FIPS_LookUp_Table.csv #>


    if ( $DebugOptions.LoadKeyFiles ) <# Using dimUS_zip_codes_states.csv to create $CountyNameFromZip and $CountyNameFromCity #> { 
        # Load Data-Files/dimUS_zip_codes_states.csv 
        # Usage examples: $CountyNameFromZip.'89027'.county             -> "Clark"
        # Usage examples: $CountyNameFromCity.'Mesquite, Nevada'.county -> "Clark"
    
        $CITY_WR = Invoke-WebRequest -Uri $URLs.dimUS_zip_codes_states
        if ( $null -eq $CITY_WR.Content ) {
            $Errorlog += $CITY_WR.Headers
            $CITY_WR.Headers | ft
            Start-Sleep -Seconds 1
            $Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
            if ( $Continue -eq "No") { Exit 0 }
        }
        if ( $null -ne $CITY_WR -and $null -ne $CITY_WR.Content ) {
            #Download the Metadata file from our GitHub project
            Write-Host "Creating index for: ", $URLs.GetRawZipCodes
            $FileName = $URLs.dimUS_zip_codes_states | Split-Path -Leaf 
            $ZipFilePath = ($GitLocalRoot, $DataDir, $FileName -join "\")
            $CITY_WR.Content | Out-File -FilePath  $ZipFilePath
            $CITY_CSV = Import-Csv -Path $ZipFilePath | Sort-Object  state, city
            # $CITY_CSV | Add-Member -MemberType NoteProperty -Name 'City_State_Key' -Value $null
            # $CITY_CSV | Add-Member -MemberType NoteProperty -Name 'Combined_Key' -Value $null
            $CountyNameFromCity = @{ }
            $CountyNameFromZip = @{ }
            $CurrentState = $null
            foreach ( $Zip in $CITY_CSV ) {
                if ( $Zip.zip_code.Length -gt 0 -and $null -eq $CountyNameFromZip.($Zip.zip_code) ) {
                    $Zip.City_State_Key = $StateNameFromCode.($Zip.state).Province_State -join ", "
                    if ( ",PR,AE,AA,AP,AS,FM,GU,MP," -like "*,$($Zip.state),*") {
                        switch ($Zip.state) {
                            "PR" { $Zip.Combined_Key = $Combined_Key.'Puerto Rico, US'.Combined_Key }
                            "AA" { $Zip.Combined_Key = "Armed Forces, US" }
                            "AE" { $Zip.Combined_Key = "Armed Forces, US" }
                            "AP" { $Zip.Combined_Key = "Armed Forces, US" }
                            "FM" { $Zip.Combined_Key = 'Federated States Of Micronesia, US' }   # FM - FIPS = "64003"
                            "GU" { $Combined_Key.'Guam, US'.Combined_Key }
                            "MP" { $Combined_Key.'Northern Mariana Islands, US'.Combined_Key }
                            Default { $Zip.Combined_Key = "Unassigned, US" }
                        }
                    }
                    else {
                        $PossibleKey = Get-BuildCombinedKey $Zip.county, $StateNameFromCode.($Zip.state).Province_State, "US"  
                        if ( $null -ne $Combined_Key.($PossibleKey) ) {
                            
                        }
                        else {
                            $Zip.Combined_Key = $Combined_Key.($Zip.county, $StateNameFromCode.($Zip.state).Province_State, "US" -join ", ").Combined_Key
                        }
                    }
                    $CountyNameFromZip.Add( $Zip.zip_code, $Zip  )
                    
                }
                if ( $Zip.county.Length -eq 0 ) { continue }
                if ( $Zip.city.Length -eq 0 ) { continue }
                if ( $Zip.state.Length -eq 0 ) { continue }
    
                $KeyValue = $Zip.city, $StateNameFromCode.($Zip.state) -join ", "
                if ( $null -eq $CountyNameFromCity.$KeyValue ) {
                    $Zip.City_State_Key = $KeyValue
                    $CountyNameFromCity.Add( $KeyValue, $Zip  )
                }
                else {
                    $Zip.Combined_Key = $Combined_Key.($Zip.county, $StateNameFromCode.($Zip.state).Province_State, "US" -join ", ").Combined_Key
                    $Zip.City_State_Key = $KeyValue
                }
                if ($CurrentState -ne $Zip.state) {
                    $CurrentState = $Zip.state
                    Write-host "Indexing : ", $StateNameFromCode.($Zip.state)
                }
            
            }
            
            $CITY_CSV | Export-Csv -path ($DebugOptions.TempPath , $FileName -join "\") -NoTypeInformation
        }
    } <# END: Using dimUS_zip_codes_states.csv to create $CountyNameFromZip and $CountyNameFromCity #>
    
    if ( $DebugOptions.LoadKeyFiles ) <# Process overrides to match Combined_Key in dimUID_ISO_FIPS_LookUp_Table.csv #> { 

        $Combined_Key_Replacements = [PSCustomObject]@{
            'Lackland, Texas, US'                               = 'Diamond Princess'
            'Lackland, TX (From Diamond Princess), US'          = 'Diamond Princess'
            'London, ON, Canada'                                = 'Ontario, Canada'
            'Montreal, QC, Canada'                              = 'Quebec, Canada'
            'None, Iraq'                                        = 'Iraq'
            'Omaha, NE (From Diamond Princess), US'             = 'Diamond Princess'
            'Toronto, ON, Canada'                               = 'Ontario, Canada'
            'Travis, California, US'                            = 'Solano, California, US'
            'Travis, CA (From Diamond Princess), US'            = 'Diamond Princess'
            'District of Columbia, US'                          = "District of Columbia, District of Columbia ,US"
            'Bahamas, The'                                      = 'Bahamas'
            'The Bahamas'                                       = 'Bahamas'
            'Bavaria, Germany'                                  = 'Germany'
            'Cape Verde'                                        = 'Cabo Verde'
            'Cruise Ship, Others'                               = 'Diamond Princess'
            'Diamond Princess cruise ship, Others'              = 'Diamond Princess'
            'Diamond Princess, Cruise Ship'                     = 'Diamond Princess'
            'From Diamond Princess, Australia'                  = 'Diamond Princess'
            'From Diamond Princess, Israel'                     = 'Diamond Princess'
            'Unassigned Location (From Diamond Princess), US'   = 'Diamond Princess'
            'None, Austria'                                     = 'Austria'
            'Czech Republic'                                    = 'Czechia'
            'Gambia, The'                                       = 'Gambia'
            'The Gambia'                                        = 'Gambia'
            'Ivory Coast'                                       = "Cote d'Ivoire"
            'Republic of the Congo'                             = 'Congo (Brazzaville)'
            'Vatican City'                                      = 'Holy See'
            'Iran (Islamic Republic of)'                        = 'Iran'
            'North Ireland'                                     = 'Ireland'
            'Republic of Ireland'                               = 'Ireland'
            'Republic of Korea'                                 = 'Korea, South'
            'None, Lebanon'                                     = 'Lebanon'
            'Republic of Moldova'                               = 'Moldova'
            'Macau, Macao SAR'                                  = 'North Macedonia'
            'Russian Federation'                                = 'Russia'
            'Taiwan, Taipei and environs'                       = 'Taiwan*'
            'Taiwan, Taiwan*'                                   = 'Taiwan*'
            'East Timor'                                        = 'Timor-Leste'
            'UK'                                                = 'United Kingdom'
            'UK, United Kingdom'                                = 'United Kingdom'
            'Viet Nam'                                          = 'Vietnam'
            'occupied Palestinian territory'                    = 'West Bank and Gaza'
            'Palestine'                                         = 'West Bank and Gaza'
            'Faroe Islands'                                     = 'Faroe Islands, Denmark'
            'Greenland'                                         = 'Greenland, Denmark'
            'Fench Guiana, France'                              = 'French Guiana, France'
            'French Guiana'                                     = 'French Guiana, France'
            'Guadeloupe'                                        = 'Guadeloupe, France'
            'Martinique'                                        = 'Martinique, France'
            'Mayotte'                                           = 'Mayotte, France'
            'Reunion'                                           = 'Reunion, France'
            'Saint Barthelemy'                                  = 'Saint Barthelemy, France'
            'Saint Martin'                                      = 'St Martin, France'
            'St. Martin'                                        = 'St Martin, France'
            'Aruba'                                             = 'Aruba, Netherlands'
            'Curacao'                                           = 'Curacao, Netherlands'
            'Cayman Islands'                                    = 'Cayman Islands, United Kingdom'
            'Channel Islands'                                   = 'Channel Islands, United Kingdom'
            'Guernsey'                                          = 'Channel Islands, United Kingdom'
            'Jersey'                                            = 'Channel Islands, United Kingdom'
            'Falkland Islands (Islas Malvinas), United Kingdom' = 'Falkland Islands (Malvinas), United Kingdom'
            'Gibraltar'                                         = 'Gibraltar, United Kingdom'
            'Northwest Territories, Canada'                     = 'Northwest Territories,Canada'
            'ON, Canada'                                        = 'Ontario, Canada'
            'QC, Canada'                                        = 'Quebec, Canada'
            'Grand Princess Cruise Ship, US'                    = 'Grand Princess, Canada'
            'Hong Kong, Hong Kong SAR'                          = 'Hong Kong, China'
            'Hong Kong'                                         = 'Hong Kong, China'
            'Hong Kong, Hong Kong'                              = 'Hong Kong, China'
            'Macau, Macau'                                      = "Macau, China"
            'Taiwan, Taiwan'                                    = 'Taiwan*'
            'Chicago, US'                                       = 'Cook, Illinois, US'
            'U.S., US'                                          = 'US'
            'US, US'                                            = 'US'
            'Washington, D.C., US'                              = 'District of Columbia, District of Columbia ,US'
            'Guam'                                              = 'Guam, US'
            'United States Virgin Islands, US'                  = 'Virgin Islands, US'
            'Puerto Rico'                                       = 'Puerto Rico, US'
            'OR , US'                                           = 'Oregon, US'
            'Wuhan Evacuee, US'                                 = 'Bexar, Texas, US'
            'South Korea'                                       = "Korea, South"
            'Macau'                                             = "Macao SAR, China"
            'Mainland China'                                    = "China"
            'Calgary, Alberta, Canada'                          = 'Alberta, Canada'
            'Edmonton, Alberta, Canada'                         = 'Alberta, Canada'
            'Jefferson Parish, Louisiana, US'                   = 'Jefferson Davis, Louisiana, US'
            'New York, New York, US'                            = 'New York City, New York, US'
            'Unassigned Location, Vermont, US'                  = 'Unassigned, Vermont, US'
            'Unassigned Location, Washington, US'               = 'Unassigned, Washington, US'
            'Unknown Location, Massachusetts, US'               = 'Unassigned, Massachusetts, US'
            'Virgin Islands, U.S., US'                          = 'Virgin Islands, US'
            'United Kingdom, United Kingdom'                    = 'United Kingdom'
            'Netherlands, Netherlands'                          = 'Netherlands'
            'Jervis Bay Territory, Australia'                   = 'New South Wales, Australia'
            'France, France'                                    = 'France'
            'External territories, Australia'                   = 'Australian Capital Territory, Australia'
            'Denmark, Denmark'                                  = 'Denmark'
        }

        if ($null -ne $UID_ISO_FIPS_LookupCSV ) <# If the LookupCSV arra is still in memory , all is good #> { 
            # New records added will have UID -gt 0084099999
            $NextMaxUID = ($UID_ISO_FIPS_LookupCSV | Sort-Object -Property 'UID' -Bottom 1).UID
            $NextMaxUID = ( [int]$NextMaxUID + 1 ).ToString("0000000000")

            $WR_Override = Invoke-WebRequest -Uri $URLs.web_data_override
            $CSV_Override = $WR_Override.Content
    
            $CSV_Override | Out-File -LiteralPath $LocalFiles.JHU_web_data_override_location_mapping
            $CSV_Override = Import-Csv -Path $LocalFiles.JHU_web_data_override_location_mapping
            $CSV_Override | Add-Member -MemberType NoteProperty -Name 'old_combined_key' -Value $null
            $CSV_Override | Add-Member -MemberType NoteProperty -Name 'combined_key' -Value $null
            $CSV_Override | Add-Member -MemberType NoteProperty -Name 'UID' -Value $null
            $CSV_Override | Add-Member -MemberType NoteProperty -Name 'In_DBT_Exceptions' -Value $null
        } <# If the LookupCSV array is still in memory , all is good #> else {
            Write-Host "Need to to run code for 'Load_Combined_key'"
            exit 0
        }
        $RowNum = 0
        
        foreach ( $row in $CSV_Override ) {
            $Row.old_combined_key = Get-BuildCombinedKey $Row.old_county, $Row.old_province_state, $Row.old_counrty_region 
            $row.combined_key = Get-BuildCombinedKey $Row.County, $Row.Province_State, $Row.Country_Region
            # Write-Host "Old: [", $Row.old_combined_key, "] maps to Combined_key: [", $row.combined_key, "]"
            $UID = $Combined_Key.($Row.combined_key)
            if ( $null -eq $UID ) {
                $UID = $Combined_Key.($Combined_Key_Replacements.$Row.Combined_Key)
                if ($null -eq $UID ) {
                    Write-Host "New combined key had no match [", $Row.combined_key, "] creating new one with UID: [" , $NextMaxUID "]" 
                    $Row.In_DBT_Exceptions = "Old:", $Row.old_combined_key, " Combined_Key no match: ", $Row.combined_key -join ""
                    $UID = $Combined_Key.'US'.psobject.Copy()
                    foreach ( $Val in $UID.psobject.Properties.Name) {
                        $UID.($Val) = $null
                    }
                    $UID.UID = $NextMaxUID
                    $UID.iso2 = $false
                    $UID.iso3 = $false
                    $UID.code3 = $NextMaxUID
                    $UID.FIPS = $Row.FIPS
                    $UID.Admin2 = $Row.County
                    $UID.Province_State = $Row.Province_State
                    $UID.Country_Region = $Row.Country_Region
                    $UID.Lat = $Row.Lat
                    $UID.Long_ = $Row.Long_
                    $UID.Combined_Key = $Combined_Key.($Combined_Key_Replacements.$Row.Combined_Key)
                    $UID.Population = $null
                    $UID.State_Code = $StateCodeFromName.$Row.Province_State
                    $UID.'Location Name Key' = $Row.Combined_Key

                    $Row.In_DBT_Exceptions = $Combined_Key_Replacements.$Row.combined_key
                    $Combined_Key.Add( $UID.Combined_Key, $UID )
                    $NextMaxUID = ( [int]$NextMaxUID + 1 ).ToString("0000000000")
                    $UID 
                }
            }
            $Row.UID = ([int]$UID.UID).ToString("0000000000") 
            if ( $Combined_Key_Replacements.($Row.old_combined_key).Length -eq 0 ) { 
                $Combined_Key_Replacements | Add-Member -Type NoteProperty -Name $Row.old_combined_key -Value $Row.combined_key
            }
            $RowNum ++    
        }
        $CSV_Override | Export-Csv -Path $LocalFiles.JHU_web_data_override_location_mapping
        $CSV_Override | Where-Object { ( $_.In_DBT_Exceptions.Length -gt 0) } | Export-Csv -Path ( $DebugOptions.TempPath, "override_no_matches.csv" -join "\" ) -NoTypeInformation
        $Combined_Key_Replacements | ConvertTo-Json -Depth 5 | Out-File "$($LocalFiles.LocalWorkingGitPath)DBT_web_data_override_combined_key_fixup.json"

    } <# END: Process replacements to match Combined_Key in dimUID_ISO_FIPS_LookUp_Table.csv #>

} <# END if ( $true ): Setup execution environment #> 


if ( $true ) <# Experiment validating Combined_Key UID value #> {
    #It appears the mapping table supports data after 03-11-2020, lets do some mapping.
    # Ready for data collection
    $FilesInfo = @()
    $CSVData = [PSCustomObject]@{ }
    $ChangeInGitHubFiles = $False
    $arrayNewCSVData = @()
    $UnpivotedRows = @()
    $FullDataRow = @()
    $LocationNameKeyIndex = @{ }
    $NextFileNumber = 0
    $WR_daily_reports = $null
    $WR_daily_reports = Invoke-WebRequest -Uri $URLs.JSU_csse_covid_19_daily_reports_PAGE
    $StopAtFile = "03-22-2020.csv"
    $CSVFileNamesArray = $WR_daily_reports.Links | Where-Object { ( $_.href -like "*-2020.csv" <# -and $_.title -le $StopAtFile #>) } | Select-Object -Property title | Sort-Object -Property title
    $Unresolved_Combined_Keys = @()
    foreach ( $Link in $CSVFileNamesArray ) <# Download each of the files matching the criteria #> {
        $CSVPageURL = $URLs.JSU_csse_covid_19_daily_reports_PAGE, $Link.title -join "/"
        $DateLastModifiedUTC = Get-Date -Date $Link.title.Split(".")[0] -Format "yyyy-MM-ddTHH:mm:ssZ"   
        $ChangeInGitHubFiles = $true
        $WR_CSV = $null
        $WR_CSV = Invoke-WebRequest -Uri ( $URLs.JSU_csse_covid_19_daily_reports_RAW, $Link.title -join "" )
        $WR_CSV.Content | Out-File -FilePath ( $LocalFiles.JHU_Daily_Files, $Link.title -join "")

        # Need to replace the column names with the newest names used starting 03-22-2020
        if ( $Link.Title -ge "03-22-2020.csv") {
            ((Get-Content -path ( $LocalFiles.JHU_Daily_Files, $Link.title -join "")  -Raw) -replace 'FIPS,Admin2,Province_State,Country_Region,Last_Update,Lat,Long_,Confirmed,Deaths,Recovered,Active,Combined_Key', 'FIPS,Admin2,Province_State,Country_Region,Last_Update,Latitude,Longitude,Confirmed,Deaths,Recovered,Active,Combined_Key') | Set-Content -Path ( $LocalFiles.JHU_Daily_Files, $Link.title -join "")     
        }
        else {
            ((Get-Content -path ( $LocalFiles.JHU_Daily_Files, $Link.title -join "")  -Raw) -replace 'Province/State,Country/Region,Last Update,', 'Province_State,Country_Region,Last_Update,') | Set-Content -Path ( $LocalFiles.JHU_Daily_Files, $Link.title -join "")
        }       
        $CSVData = Import-Csv -Path  ( $LocalFiles.JHU_Daily_Files, $Link.title -join "")
        $PeriodEnding = $Link.title.Split(".")[0]   # This takes 02-01-2020.CSV and removes the .CSV
        if ( $CSVData[0].psobject.Properties.Match('Latitude').Name.Length -eq 0 ) {
            # Data comes from the matching valid Combined_Key after a match
            $CSVData | Add-Member -MemberType NoteProperty -Name 'Latitude' -Value $null
            $CSVData | Add-Member -MemberType NoteProperty -Name 'Longitude' -Value $null     
        }
        if ( $CSVData[0].psobject.Properties.Match('FIPS').Name.Length -eq 0 ) {
            $CSVData | Add-Member -MemberType NoteProperty -Name 'FIPS' -Value $null
            $CSVData | Add-Member -MemberType NoteProperty -Name 'Admin2' -Value $null
            $CSVData | Add-Member -MemberType NoteProperty -Name 'Combined_Key' -Value $null
            $CSVData | Add-Member -MemberType NoteProperty -Name 'Active' -Value $null
        }
        $CSVData | Add-Member -MemberType NoteProperty -Name 'Date_Reported' -Value $PeriodEnding
        $CSVData | Add-Member -MemberType NoteProperty -Name 'State_Code' -Value $null
        $CSVData | Add-Member -MemberType NoteProperty -Name 'Is_Valid_Combined_Key' -Value $null
        $CSVData | Add-Member -MemberType NoteProperty -Name 'What_Changed' -Value ""
        $CSVData | Add-Member -MemberType NoteProperty -Name 'RowNumber' -Value $null
        $CSVData | Add-Member -MemberType NoteProperty -Name 'FileNumber' -Value $null
        $CSVData | Add-Member -MemberType NoteProperty -Name 'File_Name_Source' -Value "daily"
        $CSVData | Add-Member -MemberType NoteProperty -Name 'UID' -Value $null
        $RowNumber = 0
        foreach ( $Line in $CSVData ) <# Need to look for exceptions in the data and fix them up #> {
            # Do the obvious check first
            if ( $Line.Country_Region -eq "Mainland China" ) {
                $Line.Country_Region = "China"
                $Line.What_Changed = $Line.What_Changed, ': Replace [Mainland China] with [China]' -join " "
            }
            $Line.Combined_Key = Get-BuildCombinedKey $Line.Admin2, $Line.Province_State, $Line.Country_Region
            $UID = $Combined_Key.($Line.Combined_Key)
            if ( $null -eq $UID ) {
                # Check for known replacements
                if ( $Combined_Key_Replacements.($Line.Combined_Key).Length -gt 0 ) {
                    $Line.Combined_Key = $Combined_Key_Replacements.($Line.Combined_Key)
                    $UID = $Combined_Key.($Line.Combined_Key)
                    $Line.What_Changed = $Line.What_Changed, ': Replaced', $Line.Combined_Key, "with", $UID.Combined_Key -join " "
                    $Line.Combined_Key = $UID.Combined_Key
                }
                else { 
                    <#
                        if ( $Line.Province_State -eq $Line.Country_Region ) {
                            $Line.Province_State = $null
                            $Line.What_Changed = $Line.What_Changed, ': Duplicate Province_State = $null' -join " "
                        }
                        #>
                    if ( $Line.Province_State.Length -gt 0 -and $Line.Province_State.Split(', ').Count -eq 2 ) {
                        $County, $StateCode = $Line.Province_State.Split(', ')
                        $County = $County.Trim()
                        $StateCode = $StateCode.Trim()
                        if ( $Line.Country_Region -eq "US" ) {
                            if ( $StateNameFromCode.($StateCode).Length -gt 0  ) {
                                $Line.Province_State = $StateNameFromCode.($StateCode)
                                $Line.State_Code = $StateCode
                                $Line.What_Changed = $Line.What_Changed, ': Set Province_State using ', $StateCode -join " "    
                            }
                            else {
                                $Line.State_Code = $StateCode
                                $Line.Province_State = $StateCode
                                $Line.What_Changed = $Line.What_Changed, ': Used ', $StateCode, 'for Province_State using ', $StateCode -join " "    
                            }
                            if ($County -like "* County") { 
                                $County = $County.Split(" County")[0].Trim()
                                $Line.Admin2 = $County
                                $Line.What_Changed = $Line.What_Changed, ': Removed " County"' -join " "    
                            }
                            else { 
                                $Line.Admin2 = $County
                                $Line.What_Changed = $Line.What_Changed, ': Set Admin2 to', $County -join " "    
                            }
                            $Line.Combined_Key = Get-BuildCombinedKey $Line.Admin2, $Line.Province_State, $Line.Country_Region
                            $UID = $Combined_Key.($Line.Combined_Key)
                            if ( $null -eq $UID ) {
                                if ( $null -eq $CountyNameFromCity.($County, $Line.Province_State -join ", " ) ) {
                                    $Line.Is_Valid_Combined_Key = 'N'
                                }
                                else {
                                    $Line.Admin2 = $CountyNameFromCity.($County, $Line.Province_State -join ", " ).county
                                    $Line.Combined_Key = Get-BuildCombinedKey $Line.Admin2, $Line.Province_State, $Line.Country_Region
                                    $Line.What_Changed = $Line.What_Changed, ': Set Admin2 to', $Line.Admin2 , 'using city ', $County -join " "
                                    $UID = $Combined_Key.($Line.Combined_Key) 
                                }   
                            }
                        }
                        else <# Not a US, but there was a comma for a Province or something #> {
                            $Line.Admin2 = $County
                            $Line.Province_State = $StateCode
                            $Line.Combined_Key = Get-BuildCombinedKey $County, $StateCode, $Line.Country_Region
                            $UID = $Combined_Key.($Line.Combined_Key)
                            if ( $null -eq $UID ) {
                                $Line.Is_Valid_Combined_Key = 'N'
                            }
                        }
                    }
                    elseif ( $Line.Province_State.Length -gt 0 ) {
                        $Line.Combined_Key = Get-BuildCombinedKey $Line.Province_State, $Line.Country_Region
                        $UID = $Combined_Key.($Line.Combined_Key)
                        if ( $null -eq $UID ) {
                            $Line.Is_Valid_Combined_Key = 'N'
                        }
                    }
                    else {
                        $Line.Combined_Key = Get-BuildCombinedKey $Line.Country_Region
                        $UID = $Combined_Key.($Line.Combined_Key)
                        if ( $null -eq $UID ) {
                            $Line.Is_Valid_Combined_Key = 'N'
                        }
                    }
                }
            }
            if ( $null -ne $UID ) {
                $Line.Is_Valid_Combined_Key = 'Y'
            }
            else {
                if ( $Combined_Key_Replacements.($Line.Combined_Key).Length -gt 0 ) {
                    $Line.What_Changed = $Line.What_Changed, ': Replaced', $Line.Combined_Key, "with", $UID.Combined_Key -join " "
                    $Line.Combined_Key = $Combined_Key_Replacements.($Line.Combined_Key)
                    $UID = $Combined_Key.($Line.Combined_Key)
                }
            }
            if ( $null -ne $UID ) {
                $Line.Is_Valid_Combined_Key = 'Y'
                $Line.Combined_Key = $UID.Combined_Key
                $Line.UID = ([int]$UID.UID).ToString("0000000000")
                $Line.Admin2 = $UID.Admin2
                $Line.FIPS = ([int]$UID.FIPS).ToString("00000")
                $Line.Province_State = $UID.Province_State
                $Line.Country_Region = $UID.Country_Region
                $Line.Latitude = $UID.Lat
                $Line.Longitude = $UID.Long_
                if ( $Line.Active.Length -eq 0 -and [int]$Line.Confirmed -ne 0 ) {
                    $Line.Active = [int]$Line.Confirmed - [int]$Line.Deaths - [int]$Line.Recovered
                    $Line.What_Changed = $Line.What_Changed, ': Computed Active as Confirmed', $Line.Confirmed, '- Deaths', $Line.Deaths, '- Recovered ', $Line.Recovered -join " "
                }
            }
            else {
                $Line.Is_Valid_Combined_Key = 'N'
                $Unresolved_Combined_Keys += $Line
                $Line.What_Changed = "[$($Line.What_Changed)]", ': NO Combined_Key match with', "[$($Line.Combined_Key)]" -join " "
            }
            $Line.RowNumber = ([int]$RowNumber).ToString("0000")
            $Line.FileNumber = ([int]$NextFileNumber).ToString("000")
                
            Write-Host "Processed: ", $Link.title, ([int]$Line.RowNumber).ToString("0000") , $Line.Combined_Key, $Line.Valid_Combined_Key, $Line.Is_Valid_Combined_Key
            $RowNumber ++
        } <# END: foreach ( $Line in $CSVData ) #>

        $Columns = 'UID', 'FIPS', 'Admin2', 'Province_State', 'Country_Region', 'Last_Update', 'Latitude', 'Longitude', 'Confirmed', 'Deaths', 'Recovered', 'Active', 'Combined_Key', 'Date_Reported', 'File_Name_Source', 'State_Code', 'Is_Valid_Combined_Key', 'What_Changed' , 'RowNumber' , 'FileNumber'

        $CSVData | Select-Object -Property $Columns | Export-Csv -Path  ( $LocalFiles.JHU_Daily_Files, $Link.title -join "") -NoTypeInformation
    
        $FileMetadata = [PSCustomObject]@{
            CsvFileName         = $Link.Title
            PeriodEnding        = $PeriodEnding
            CSVRawURL           = ( $URLs.JSU_csse_covid_19_daily_reports_RAW, $Link.title -join "" )
            CSVPageURL          = $CSVPageURL
            DateLastModifiedUTC = $DateLastModifiedUTC
            FileNumber          = $NextFileNumber
            NeedsUpdating       = $true
        } 
        $FilesInfo += $FileMetadata
        $FileMetadata | Add-Member -MemberType NoteProperty -Name 'CSVData' -Value $CSVData
        $arrayNewCSVData += $FileMetadata
    
        $NextFileNumber ++          
            
    } <# END: foreach ( $Line in $CSVData ) #>

    if ( $Unresolved_Combined_Keys.count -gt 0 ) {
        $Unresolved_Combined_Keys | Sort-Object 'Combined_Key' -Unique | Export-Csv -Path  ( $LocalFiles.JHU_Daily_Files, "Unresolved_Combined_Keys.csv", $Link.title -join "") -NoTypeInformation
    }

} <# END if ( $false ): Experiment against enisting Combined_Key UID value #>

  



if ( $true ) <# Execution of the loading of data #> { 
    if ( $DebugOptions.LoadFromWorkingFiles ) {
        $FilesInfo = @()
        $arrayNewCSVData = @()
        $GroupedFileRows = @{ }

        $GitLocalRoot = "C:\Users\Bill\OneDrive\Bill\Documents\My GitLab\Covid-19-Power-BI"
        $WorkingFilesPath = $GitLocalRoot, "Working Files" -join "\"
        $WorkingFiles = Get-ChildItem -path $WorkingFilesPath | Where-Object { ( $_.Name -like "*-2020.csv" ) } | Sort-Object -Property Name
        if ( $null -eq $WorkingFiles ) {
            Write-Error "No files in 'Working files' at: ", $WorkingFilesPath
        }
        else  <# otherwise, load the local files #> {
            foreach ( $Link in $WorkingFiles) {
                $CSVFileName = $Link.Name
                $FileNameFullPath = $WorkingFilesPath, "\", $CSVFileName -join ""
                if ( $false ) {
                    start notepad++ ('"', $FileNameFullPath, '"' -join "")
                }
                Write-Host "Processing file: ", $CSVFileName, "      in path: ", $WorkingFilesPath
                $DateLastModifiedUTC = Get-Date -Date $CSVFileName.Split(".")[0] -Format "yyyy-MM-ddTHH:mm:ssZ"
                $ChangeInGitHubFiles = $true
                $CSVData = Import-Csv -Path ($TempDataLocation, $CSVFileName -join "")
                $PeriodEnding = $CSVFileName.Split(".")[0]
                $CSVRawURL = $GitRawRoot, $CSVFileName -join "" 
                $CSVPageURL = $URLs.JSU_csse_covid_19_daily_reports_PAGE, $CSVFileName -join "/"
        
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
        } <# endif loading of local files #>
    } <# end if ($DebugOptions.LoadFromWorkingFiles -eq $true #>
    else <# load data from the JSU_csse_covid_19_daily_reports_PAGE_page as needed #> {

        $WR = $null
        $WR = Invoke-WebRequest -Uri $URLs.JSU_csse_covid_19_daily_reports_PAGE
        if ( $null -eq $WR.Content ) {
            $Errorlog += $WR.Headers
            $WR.Headers | ft
            Start-Sleep -Seconds 1
            $Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
            if ( $Continue -ne "Yes") { Exit 0 }
        
        }

        if ( $DebugOptions.ForceDownload -eq $false ) <# Do a normal process of downloading only the latest files #> { 
            $FilesLookupHash = [ordered]@{ }
            #Check to see files have changes since the last download
            $WebRequest = $null
            $WebRequest = Invoke-WebRequest -Uri $URLs.DBT_Daily_Reports_Files_Loaded
            if ( $null -eq $WebRequest.Content ) {
                $Errorlog += $WebRequest.Headers
                $WebRequest.Headers | ft
                Start-Sleep -Seconds 1
                $Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
                if ( $Continue -ne "Yes") { Exit 0 }
            }
            if ( $null -ne $WebRequest -and $null -ne $WebRequest.Content -and -not $DebugOptions.ForceDownload ) {
                #Download the Metadata file from our GitHub project
                $WebRequest.Content | Out-File -FilePath $LocalFiles.DBT_Daily_Reports_Files_Loaded

                $FilesInfo = Import-Csv -Path $LocalFiles.DBT_Daily_Reports_Files_Loaded | Sort-Object  PeriodEnding
                if ( $null -eq $FilesInfo[0].psobject.Properties.Match('Source_Type') ) {
                    $FilesInfo | Add-Member -MemberType NoteProperty -Name 'Source_Type' -Value 'csse_covid_19_daily_reports'
                }

                if ( $null -ne $FilesInfo ) {
                    $CSVFileCount = $FilesInfo.count
                }
                else {
                    $RowError = @{
                        Severity    = "Import of File Metadata Failed"
                        Process     = "Retrieving CSV web page URL [$($URLs.DBT_JHU_Files_Processed_For_Current_Data)]"
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
                    Process     = "Retrieving web page URL [$($URLs.DBT_JHU_Files_Processed_For_Current_Data)]"
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
                $FilesInfo | ConvertTo-Json -Depth 5 | Out-File ($DebugOptions.TempPath, "\FileLookupHash.json" -join "")
            }

            if ( $false ) <# old process for loading up hash table of prior values #> {

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
                    $WebRequest.Content | Out-File -FilePath $LocalFiles.DBB_Last_Upload_AllColumns
                    $PriorDataRows = Import-Csv -Path $LocalFiles.DBB_Last_Upload_AllColumns
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
            } <# old process for loading up hash table of prior values #>
        } <# Endif not a forced download #>
        else {
            $FilesInfo = @()
            $ChangeInGitHubFiles = $False
            $arrayNewCSVData = @()
            $UnpivotedRows = @()
            $FullDataRow = @()
            $LocationNameKeyIndex = @{ }

        }

        $NextFileNumber = 0
        if ( $FilesInfo.Count -gt 0 ) {
            $LastFileLoaded = $FilesInfo[$FilesInfo.count - 1 ].CsvFileName
            $NextFileNumber = $FilesInfo.Count
        }
        $CSVFileNamesArray = $WR.Links | Where-Object { ( $_.href -like "*-2020.csv" -and $_.title -gt $LastFileLoaded ) } | Select-Object -Property title | Sort-Object -Property title
        
        foreach ( $Link in $CSVFileNamesArray ) {
            if ( $true) <# New way of using $Link #> {
                $CSVRawURL = $URLs.JSU_csse_covid_19_daily_reports_PAGE_raw, $Link.title -join "/"
                $CSVPageURL = $URLs.JSU_csse_covid_19_daily_reports_PAGE, $Link.title -join "/"
                $DateLastModifiedUTC = Get-Date -Date $Link.title.Split(".")[0] -Format "yyyy-MM-ddTHH:mm:ssZ"   
                $ChangeInGitHubFiles = $true
                $WR_CSV = $null
                $WR_CSV = Invoke-WebRequest -Uri $CSVRawURL
                $WR_CSV.Content | Out-File -FilePath ($LocalFiles.LocalWorkingGitPath, $Link.title -join "")
                $CSVData = Import-Csv -Path  ($LocalFiles.LocalWorkingGitPath, $Link.title -join "")

                $PeriodEnding = $Link.title.Split(".")[0]   # This takes 02-01-2020.CSV and removes the .CSV
                $CSVData | Add-Member -MemberType NoteProperty -Name 'CSV File Name' -Value $Link.title
                $CSVData | Add-Member -MemberType NoteProperty -Name 'Date Reported' -Value $PeriodEnding
                $CSVData | Export-Csv -Path ($LocalFiles.LocalWorkingGitPath, $Link.title -join "") -NoTypeInformation

                $FileMetadata = [PSCustomObject]@{
                    CsvFileName         = $Link.Title
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
            else <# if ( $Link -like "*2020.csv" ) #>  <# old way of using $Link #> {
                # Using the data in the $Link.href string, parse out the file name to use to grab the actual csv data from the GitHub
                $CSVFileName = Split-Path -Path $Link.href -Leaf
                $CSVRawURL = $URLs.JSU_csse_covid_19_daily_reports_PAGE_raw, $CSVFileName -join ""
                $CSVPageURL = $URLs.JSU_csse_covid_19_daily_reports_PAGE, $CSVFileName -join "/"

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
            } <# END:  old way of using $Link #> 
        }

    } <# Endif not a forced download #>

    if ($null -eq $arrayNewCSVData )  <# Check to see if any data new needs processing #> {
    
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
        exit 1 
    }

    <# Process the new rows: $SortedCSVs = $arrayNewCSVData | Sort-Object -Property CsvFileName #>


    $SortedCSVs = $arrayNewCSVData | Sort-Object -Property CsvFileName 

    # Start the process of reading each of the file records and the rows within them
    if ( $UnpivotedRows.count -gt 0   ) {
        $ExpectedDateModified = ( Get-Date -Date  $UnpivotedRows[ $UnpivotedRows.count - 1 ].'Date Reported').AddDays(1)
        $ActualNextDateToLoad = ( Get-Date -Date  $SortedCSVs[ $SortedCSVs.count - 1 ].PeriodEnding)
        if ( $null -eq $ExpectedDateModified -and $null -eq $ActualNextDateToLoad ) {
            $UnpivotedRows = @()
            $FullDataRow = @()
            $LocationNameKeyIndex = @{ }
        }
        else {
            if ( $false ) {
                $Stash_UnpovitedRows = $UnpivotedRows.psobject.copy()
                $Stash_FullDataRow = $FullDataRow.PSObject.Copy()
                $Stash_LocationNameKeyIndex = $LocationNameKeyIndex.Clone()
            }
            if ($false ) {
                $UnpivotedRows = $Stash_UnpovitedRows.PSObject.Copy()
                $FullDataRow = $Stash_FullDataRow.PSObject.Copy()
                $LocationNameKeyIndex = $Stash_LocationNameKeyIndex.Clone()
            }
        }
    }
    else {
        $UnpivotedRows = @()
        $FullDataRow = @()
        $LocationNameKeyIndex = @{ }
    }


    for ( $file = 0; $file -lt $SortedCSVs.count; $file++) {
        
        # Go through array of $SortedCSVs fix up and flatten the data for Confirmed,Deaths,Recovered,Active
        
        if ( $false ) <# Resent the previous hash tables #> {
            $FilesLookupHash = @{ }
            $GroupedFileRows = @{ }
            $LocationNameKeyIndex = @{ }
            $UnpivotedRows = @()
            $FullDataRow = @()
            $SortedCSVs = $arrayNewCSVData | Sort-Object -Property CsvFileName 

            $LocationNameKeyIndex = @{ # Index of values by 'Location Name Key'
                # Value for Location Name  =  Hash Table of Type $LocationKeyClass
            }
            $SortedCSVs.Count
            $FullDataRow.Length
            $GroupedFileRows
            $UnpivotedRows.Length
            $file = 0
            $Continue = "Rip"
        }
        
        if ( $true )  <# Process the rows in each file} #> { 
            $Csv = $SortedCSVs[$file]
            $FileNumber = $Csv.FileNumber
            $DateReported = $Csv.PeriodEnding
            $dReported = Get-Date -Date $DateReported
            Write-Host ("File # = ", $file, " mapped to ", $FileNumber, " of ", ($SortedCSVs.count - 1), " CsvFileName= ", $Csv.CsvFileName , " and ModifiedDate= ", (Get-Date -date $Csv.DateLastModifiedUTC).ToUniversalTime() -join "")
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
            $ActualColumns = @()
            $ActualColumns = $CSV.CSVData[0].psobject.properties.name
            if ( $null -eq $ActualColumns ) {
                Write-Host '$null -eq $ActualColumns for file:', $file
                exit 
            }
        } <# Good code to load file number #>

        for ( $RowNumber = 0; $RowNumber -lt $Csv.CSVData.Length; $RowNumber++ )  <# Expand out the rows #> {
            if ( $true <# Load in record for the current value for $File  set $RowNumber = 0 #>) {
                $Row = $Csv.CSVData[$RowNumber]
                $Mapping = $MappingPSO.PSObject.copy()
                $AllColumns = $AllColumnsPSO.PSObject.copy()
                #Map the base columns to the new column names for the row
                for ($i = 0; $i -lt $ActualColumns.Count; $i++ ) {
                    $Key = $NewColumnsMapping.($ActualColumns[$i])
                    if ( $null -ne $Row.($ActualColumns[$i]) -or $Row.($ActualColumns[$i]).Length -gt 0 ) {
                        $AllColumns.($ActualColumns[$i]) = $Row.($ActualColumns[$i]) 
                    }
                    else {
                        $Row.($ActualColumns[$i]) = $null
                    }
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

                Write-Host ("File # = ", $FileNumber, " Processing Row# ", $RowNumber, " out of ", $Csv.CSVData.Length, " Country = ", $Mapping.'Country or Region', " and ", $Mapping.'Province or State' -Join "")

                $Mapping.'Date Reported' = $DateReported 
            } <# endif $true Load in record for the current value for $File  set $RowNumber = 0 #>

            if ( $Mapping.Combined_Key.Length -gt 0 )  <# if the Combined_Key value exists, it's the new style record - nothing to do for now #> {
                # This is is a new record, so the only thing to do is check for some exceptions before the unpivot process
                if ( "US" -eq $Mapping.'Country or Region' -and $Mapping.State_Code.Length -eq 0 -and $Mapping.'Province or State'.Length -gt 0) {
                    $Mapping.State_Code = $StateCodeFromName.($Mapping.'Province or State').State_Code
                    if ( $Mapping.State_Code.Length -eq 0 ) {
                        $Mapping.State_Code = $Mapping.'Province or State'
                        $AllColumns.'US Invalid State Name' = $Mapping.'Province or State'
                    }
                }
                if ( $Mapping.Combined_Key -like ",*" ) {
                    $AllColumns.'Combined_Key_NotFound' = $true
                }
                elseif ( $null -eq $Combined_Key.($Mapping.Combined_Key) ) {
                    $AllColumns.'Combined_Key_NotFound' = $true
                    $AllColumns.'US Invalid State Name' = $Mapping.Combined_Key
                } 
            }
            else <# Create the Location Key Name since we are dealing with the old format #> {
                $AllColumns.'Combined_Key_NotFound' = $true
                if ( $Mapping.'Province or State'.Length -gt 0)  <# The original Province/State column overloaded the value with County, State Code values #> {
                    # First look for replacement in $StateReplacements
                    if ( $Mapping.'Country or Region' -eq "US" ) {
                        if ( $Mapping.'Province or State' -like "*, *" ) {
                            # Looking at older file format. New format as the full state name
                            $County, $StateCode = ($Mapping.'Province or State').Split(", ")
                            if ($County -like "*County") { 
                                $CountyValue = $County.Split(" County")[0].Trim()
                            }
                            else { 
                                $CountyValue = $County.Trim() 
                            }

                            # Little more work needed still for cruise ships
                            $CountyStateCode, $ShipName = $StateCode.Split( ' (From' )
                            if ( $null -ne $ShipName ) {
                                $Mapping.'Ship Name' = $ShipName.Trim().split( ')' )[0]
                                $StateCode = $CountyStateCode.Trim()
                            }                          
                            if ( $StateNameFromCode.$StateCode.Province_State.Length -eq 0 ) {
                                if ( $StateCode -eq "D.C." ) {
                                    $Mapping.State_Code = "DC"
                                    $Mapping.'Province or State' = "District of Columbia"
                                    $Mapping.'USA State County' = ""
                                    $AllColumns.'Combined_Key_NotFound' = $false
                                    $FIPS = $Combined_Key.'District of Columbia, District of Columbia ,US'
                                    $Mapping.'FIPS USA State County code' = $FIPS.FIPS
                                    $AllColumns.FIPS = $FIPS.FIPS
                                    $Mapping.Population = $FIPS.Population
                                    $Mapping.Latitude = $FIPS.Lat
                                    $Mapping.Longitude = $FIPS.Long_
                                    $Mapping.'USA State County' = 'District of Columbia'
                                    $Mapping.'Location Name Key' = $FIPS.'Location Name Key'
                                    $Mapping.Combined_Key = $FIPS.Combined_Key
                                }
                                else {
                                    $AllColumns.'US Invalid State Name' = $StateCode
                                    $AllColumns.'Combined_Key_NotFound' = $true
                                    $Mapping.'Province or State' = $StateCode
                                } 
                            }
                            else {
                                $Mapping.'Province or State' = $StateNameFromCode.$StateCode.Province_State  
                            }   
                            $Mapping.State_Code = $StateCode
                            if ( $CountyValue -eq "Travis" -and $StateCode -eq "CA" ) {
                                $AllColumns.'Other Data Prov/State' = "Travis Air Force Base"
                                $CountyValue = "Solano"
                                $AllColumns.'US Invalid County Name' = $CountyValue
                            }

                            # At this point, we should feel good about the $StateCode value, but the county could something else
                            # Lets see if we can match the Combined_Key to the new reported data style.
                            $PotentialCombinedKey1 = $CountyValue, $Mapping.'Province or State', $Mapping.'Country or Region' -join ", "
                            $CountyCheck = $Combined_Key.$PotentialCombinedKey1
                            if ( $null -eq $CountyCheck ) <#  Is there a match, if not see if city can translate into county #> {
                                $AllColumns.'US Invalid County Name' = $CountyValue
                                $CityKey = $CountyValue.Trim(), $Mapping.'Province or State'.Trim() -join ", "
                                $PotentialCombinedKey2 = $CountyNameFromCity.($CityKey).county, $StateNameFromCode.$StateCode.Province_State, "US" -join ", "
                                $CountyCheck = $Combined_Key.$PotentialCombinedKey2
                            }
                            if ( $null -eq $CountyCheck ) <# If no match, fill in the exceptions and figure it out later #> {
                                $AllColumns.'US Invalid County Name' = $CountyValue
                                $Mapping.'USA State County' = $CountyValue
                            }
                            else <# There is a city->county match, so fill up #> {  
                                $AllColumns.'Combined_Key_NotFound' = $false
                                $FIPS = $Combined_Key.($CountyCheck.Combined_Key)
                                $Mapping.'FIPS USA State County code' = $FIPS.FIPS
                                $AllColumns.FIPS = $FIPS.FIPS
                                $Mapping.Population = $FIPS.Population
                                $Mapping.Latitude = $FIPS.Lat
                                $Mapping.Longitude = $FIPS.Long_
                                $Mapping.'USA State County' = $FIPS.Admin2.Trim()
                                $Mapping.'Location Name Key' = $FIPS.'Location Name Key'
                                $Mapping.Combined_Key = $FIPS.Combined_Key
                            }
                        }
                        else { 
                            $AllColumns.'Combined_Key_NotFound' = $true
                            $AllColumns.'US Invalid County Name' = $PotentialCombinedKey1
                        }
                        if ( $CountyValue.Length -gt 0 ) { $Mapping.'USA State County' = $CountyValue.Trim() }
                    }
                    else {
                        #Province Check
                        $CountryValue = $CountryReplacements.($Mapping.'Country or Region')
                        if ( $null -ne $CountryValue -and $CountryValue -ne $Mapping.'Country or Region') {
                            $Mapping.'Country or Region' = $CountryValue
                            if ( $Mapping.'Country or Region' -eq $Mapping.'Province or State') {
                                if ( $Mapping.'Country or Region' -eq "Taiwan*"  ) {
                                    $Mapping.'Province or State' = ""
                                }
                            }
                        }
                        else {
                            if ( $Mapping.'Country or Region' -eq $Mapping.'Province or State') {
                                $Mapping.'Province or State' = ""
                            }
                        }
                        if ( $Mapping.'Province or State' -like "*,*" ) {
                        
                            $OtherData, $Province = $Mapping.'Province or State'.Split(',')
                            $AllColumns.'Other Data Prov/State' = $OtherData.Trim()
                            $Mapping.'Province or State' = $Province.Trim()
                            $ProvinceCombinedKeyValue = $AllColumns.'Other Data Prov/State', $Mapping.'Province or State', $Mapping.'Country or Region' -join ", "
                        }
                        elseif ( $Mapping.'Province or State'.Length -gt 0 ) {
                            $ProvinceCombinedKeyValue = $Mapping.'Province or State', $Mapping.'Country or Region' -join ", "
                        }
                        else {
                            $ProvinceCombinedKeyValue = $Mapping.'Country or Region'
                        }
                        $ProvinceCheck = $Combined_Key.$ProvinceCombinedKeyValue
                        if ( $null -ne $ProvinceCheck) {
                            $Mapping.Latitude = $ProvinceCheck.Lat
                            $Mapping.Longitude = $ProvinceCheck.Long_
                            $Mapping.Population = $ProvinceCheck.Population
                            $Mapping.Combined_Key = $ProvinceCheck.Combined_Key
                            $Mapping.'Location Name Key' = $ProvinceCheck.'Location Name Key'
                            $AllColumns.Combined_Key_NotFound = $false
                        }
                        else {
                            $AllColumns.'US Invalid County Name' = $ProvinceCombinedKeyValue
                        }
                    }
                }
                else {
                    #Province Check
                    $CountryValue = $CountryReplacements.($Mapping.'Country or Region')
                    if ($null -ne $CountryValue -and $CountryValue -ne $Mapping.'Country or Region') {
                        $Mapping.'Country or Region' = $CountryValue
                    }
                    $ProvinceCombinedKeyValue = $Mapping.'Country or Region'
            
                    $ProvinceCheck = $Combined_Key.$ProvinceCombinedKeyValue
                    if ( $null -ne $ProvinceCheck) {
                        $Mapping.Latitude = $ProvinceCheck.Lat
                        $Mapping.Longitude = $ProvinceCheck.Long_
                        $Mapping.Population = $ProvinceCheck.Population
                        $Mapping.Combined_Key = $ProvinceCheck.Combined_Key
                        $Mapping.'Location Name Key' = $ProvinceCheck.'Location Name Key'
                        $AllColumns.Combined_Key_NotFound = $false
                    }
                    else {
                        $AllColumns.'US Invalid County Name' = $ProvinceCombinedKeyValue
                    }

                }

           
                if ( $Mapping.'Province or State' -like "*, *" ) {
                    # Looking at older file format. New format as the full state name
                    $County, $StateCode = ($Mapping.'Province or State').Split(", ")
                    if ($County -like "*County") { 
                        $CountyValue = $County.Split(" County")[0].Trim()
                    }
                    else { $CountyValue = $County }
                    $Mapping.'USA State County' = $CountyValue

                    # Little more work needed still for cruise ships
                    $CountyStateCode, $ShipName = ($Mapping.'Province or State').Split( ' (From' )
                    if ( $null -ne $ShipName ) {
                        $AllColumns.'Ship Name' = $ShipName.split( ')' )[0]
                        $Mapping.'Province or State' = $CountyStateCode
                    }
                    else {
                        $Mapping.'Province or State' = $StateCode.Trim()
                    }
                }
                elseif ( $Mapping.'Country or Region' -eq "US" -and $Mapping.'Province or State' -ne "") {
                    #Looks like an actual Province or State value, but for the US, need to use abbreviation
                    if ( $Mapping.'Province or State'.Length -eq 2 ) {
                        $Mapping.'US State Name' = $Mapping.'Province or State'
                    }                       
                    $StateCode = $StateLook.($Mapping.'Province or State')
                    if ( $null -ne $StateCode) {
                        $Mapping.'Province or State' = $StateCode.Trim()
                    }
                    else {
                        $AllColumns.'US Invalid State Name' = $Mapping.'Province or State'
                    }
                }
                
                if ($Mapping.'Country or Region' -eq "US" -and $null -ne $Mapping.'Province or State') {
                    $SN = $Mapping.'Province or State'
                    if ( $SN.Length -gt 2 -and $null -ne $StateLook.$SN  ) {
                        $Mapping.'Province or State' = $StateLook.$SN
                        $Mapping.'US State Name' = $StateLook.$SN
                    }
                    elseif ( $SN.Length -gt 2 ) {
                        $AllColumns.'US Invalid State Name' = $SN 
                    }
                }
            
            } <# end if else - Create the Location Key Name since we are dealing with the old format #>
            if ( $AllColumns.Combined_Key_NotFound -ne $false -or $Mapping.'Location Name Key'.Length -eq 0) {
                if ($Mapping.'Country or Region' -eq "US" -and $Mapping.'USA State County'.Length -gt 0 -and $Mapping.State_Code.Length -gt 0 -and $Mapping.'Ship Name'.Length -gt 0) {
                    $Mapping.'Location Name Key' = $Mapping.'Ship Name', $Mapping.'USA State County', $Mapping.State_Code, $Mapping.'Country or Region' -join ", "  
                }
                elseif ($Mapping.'Country or Region' -eq "US" -and $Mapping.'USA State County'.Length -gt 0 -and $Mapping.State_Code.Length -gt 0 ) {
                    $Mapping.'Location Name Key' = $Mapping.'USA State County', $Mapping.State_Code, $Mapping.'Country or Region' -join ", "  
                }
                elseif ("US" -eq $Mapping.'Country or Region' -and $Mapping.State_Code.Length -gt 0) {
                    $Mapping.'Location Name Key' = $Mapping.State_Code, $Mapping.'Country or Region' -join ", "  
                }
                elseif ( $Mapping.'Country or Region'.Length -gt 0 -and $Mapping.'Other Data Prov/State'.Length -gt 0 -and $Mapping.'Province or State'.Length -gt 0 ) {
                    $Mapping.'Location Name Key' = $Mapping.'Other Data Prov/State', $Mapping.'Province or State', $Mapping.'Country or Region' -join ", "  
                }
                elseif ( $Mapping.'Country or Region'.Length -gt 0 -and $Mapping.'Province or State'.Length -gt 0 ) {
                    $Mapping.'Location Name Key' = $Mapping.'Province or State', $Mapping.'Country or Region' -join ", "  
                }
                else {
                    $Mapping.'Location Name Key' = $Mapping.'Country or Region'  
                }

                if ( $AllColumns.Combined_Key_NotFound ) {
                    if ( $Mapping.'Country or Region' -eq "US" ) {
                        $Mapping.Combined_Key = $Mapping.'Province or State', "US" -join ", "
                        $AllColumns.Combined_Key_NotFound = $false
                        $AllColumns.Combined_Key = $Mapping.Combined_Key
                    }
                    elseif ( $Mapping.Combined_Key -like ",*" ) {
                        $Mapping.Combined_Key = $Mapping.'Location Name Key'
                        $AllColumns.Combined_Key_NotFound = $false
                        $AllColumns.Combined_Key = $Mapping.Combined_Key
                    }
                    else {
                        $AllColumns.Combined_Key_NotFound = $true
                        $Mapping.Combined_Key = $Mapping.'Location Name Key'
                        $AllColumns.Combined_Key = $Mapping.Combined_Key
                    } 
                }
            }
            $Mapping.'File Number' = ([int]$FileNumber).ToString( "000" )
            $Mapping.'Row Number' = ([int]$RowNumber).ToString($RowFmt)

            <#  If a county or state reports an Recovered value, it's a value that can be attributed to the recover total.
            For all other unattributed Recovered values within a Country are counted at the Country level 
            For the Recovered, Country the Active count should not be computed.
            The date of the first report is based solely on the values for events Confirmed, Deaths, Recovered, and where Active is a positive number. 
        #>
            if ( [int]$Row.Active -gt 0 ) {
                # Stash this away to check if computed total aligns.
                $AllColumns.'Active Original' = $Row.Active
            }

            if ( [int]$Row.Confirmed -gt 0) {
                $AllColumns.Active = [int]$Row.Confirmed - [int]$Row.Deaths - [int]$Row.Recovered
            }
            else {
                $AllColumns.Active = 0
            }
        
            
            foreach ( $MK in $Mapping.PSObject.Properties.Name)  <# Take Mapping values and copy to AllColumns #> {
                if ( $null -eq $AllColumns.$MK -and $null -ne $Mapping.$MK ) {
                    $AllColumns.$MK = $Mapping.$MK
                }
            }
        
            $LocKey = $AllColumns.Combined_Key
            if ( [int]$Row.Recovered -ne 0 -or [int]$Row.Confirmed -ne 0 -or [int]$Row.Deaths -ne 0   ) <#  There is data to record  #> {
                #Need to make one last check for the key. The end result is there could me multiple assignments for a day, but I doubt it.
                $KeyRep = $Combined_Key_Replacements.$LocKey
                if ( $null -ne $KeyRep ) <# There is a match! #> {
                    # Verify the new key is in fact in the $Combined_Key
                    if ( $null -ne $Combined_Key.$KeyRep ) {
                        $LocKey = $KeyRep
                        #Fix up $AllColumns and then treat as a new - keep the Province/State,Country/Region as is
                        $RepKey = $Combined_Key.$KeyRep
                        $AllColumns.Combined_Key = $RepKey.Combined_Key
                        $AllColumns.'Location Name Key' = $RepKey.Combined_Key
                        $AllColumns.Population = $RepKey.Population
                        $AllColumns.Latitude = $RepKey.Lat
                        $AllColumns.Longitude = $RepKey.'Long_'
                        $AllColumns.'Country or Region' = $RepKey.Country_Region 
                        $AllColumns.'Province or State' = $RepKey.Province_State 
                        $AllColumns.'FIPS USA State County code' = $RepKey.FIPS
                        $AllColumns.State_Code = $RepKey.State_Code
                        $AllColumns.'USA State County' = $RepKey.Admin2
                    }
                }
                if ( $null -eq $LocationNameKeyIndex.$LocKey ) {
                    # Need to create a new index key if missing
                    $LocationNameKeyIndex.Add( $LocKey, $LocationKeyClass.Clone() )
                    $LocationNameKeyIndex.$LocKey.DayZeroItems = $DayZeroItemsClass.PSObject.Copy()
                    $LocationNameKeyIndex.$LocKey.'Location Name Key' = $AllColumns.Combined_Key
                    $LocationNameKeyIndex.$LocKey.Population = $AllColumns.Population
                    $LocationNameKeyIndex.$LocKey.Latitude = $AllColumns.Latitude
                    $LocationNameKeyIndex.$LocKey.Longitude = $AllColumns.Longitude
                    $LocationNameKeyIndex.$LocKey.'Country or Region' = $AllColumns.'Country or Region'
                    $LocationNameKeyIndex.$LocKey.'Province or State' = $AllColumns.'Province or State'
                    $LocationNameKeyIndex.$LocKey.'USA State County' = $AllColumns.'USA State County'
                    $LocationNameKeyIndex.$LocKey.'FIPS USA State County code' = $AllColumns.'FIPS USA State County code' 
                    $LocationNameKeyIndex.$LocKey.Combined_Key = $AllColumns.Combined_Key
                    $LocationNameKeyIndex.$LocKey.'State' = $AllColumns.'Province or State'
                    $LocationNameKeyIndex.$LocKey.'Name' = $AllColumns.State_Code
                    if ($AllColumns.'Country or Region' -eq "US") {
                        $LocationNameKeyIndex.$LocKey.'USA or Global' = "United States"
                        if ( $AllColumns.State_Code.Length -eq 2 -and $AllColumns.'USA State County'.Length -gt 0) {
                            $LocationNameKeyIndex.$LocKey.'County State Key' = $AllColumns.'USA State County'.ToUpper() , $AllColumns.State_Code.ToUpper() -join ", "
                        }
                        elseif ( $AllColumns.State_Code.Length -eq 2 ) { $LocationNameKeyIndex.$LocKey.'County State Key' = $AllColumns.State_Code.ToUpper() }
                    }
                    else { $LocationNameKeyIndex.$LocKey.'USA or Global' = "Global" }
                }
                $AllColumns.'Location Index' = $LocationNameKeyIndex.$LocKey.'CSV Rows PSObj Array'.count
                $PriorRowIndex = $AllColumns.'Location Index' - 1
                $LocationNameKeyIndex.$LocKey.'Number of Rows' ++
                        
                if ( $AllColumns.'Location Index' -eq 0) <# This is the first row for $LocKey #> {
                    $LocationNameKeyIndex.$LocKey.DayZeroItems.'Location Name Key' = $LocKey

                    $LocationNameKeyIndex.$LocKey.DayZeroItems.'Event First CSV File Name' = $AllColumns.'CSV File Name'
                    $LocationNameKeyIndex.$LocKey.DayZeroItems.'Event First Location Name Key' = $AllColumns.Combined_Key
                    $LocationNameKeyIndex.$LocKey.DayZeroItems.'Event First Date' = $AllColumns.'Date Reported'
                    if ( [int]$AllColumns.Recovered -gt 0 -and [int]$AllColumns.Confirmed -eq 0 ) {
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Event First Value' = $AllColumns.Recovered
                    }
                    else { $LocationNameKeyIndex.$LocKey.DayZeroItems.'Event First Value' = $AllColumns.Confirmed }
                 
                    $AllColumns.'Days Since First Value' = 0
                }
                else {
                    $DateFirstEvent = Get-Date -Date $LocationNameKeyIndex.$LocKey.DayZeroItems.'Event First Date'
                    $AllColumns.'Days Since First Value' = $dReported.Subtract($DateFirstEvent).Days
                }
                if ( $false) <# Issue-1: Remove First Event Attribute from the result set #> {
                    $UnpivotedRows += [PSCustomObject]@{
                        'Location Name Key'      = $LocationNameKeyIndex.$LocKey.Combined_Key
                        'Date Reported'          = $AllColumns.'Date Reported'
                        'Attribute'              = "First Event"
                        'Cumulative Value'       = 0
                        'Change Since Prior Day' = 0
                        'Days Since First Value' = $AllColumns.'Days Since First Value'
                    }
                } <# Issue-1: Remove First Event Attribute from the result set #>
                if ( [int]$AllColumns.Active -ne 0) {
                    if ( $LocationNameKeyIndex.$LocKey.DayZeroItems.'Active First Location Name Key'.Length -eq 0 ) {
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Active First CSV File Name' = $AllColumns.'CSV File Name'
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Active First Location Name Key' = $AllColumns.Combined_Key
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Active First Date' = $AllColumns.'Date Reported'
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Active First Value' = $AllColumns.Active
                        $AllColumns.'Active Delta Value' = $AllColumns.Active
                        $AllColumns.'Days Since First Active' = 0   
                    }
                    else {
                        $DateFirstActive = Get-Date -Date $LocationNameKeyIndex.$LocKey.DayZeroItems.'Active First Date'
                        $AllColumns.'Days Since First Active' = $dReported.Subtract($DateFirstActive).Days
                        $AllColumns.'Active Delta Value' = $AllColumns.Active - $LocationNameKeyIndex.$LocKey.'CSV Rows PSObj Array'[$PriorRowIndex].Active
                    }
                    $UnpivotedRows += [PSCustomObject]@{
                        'Location Name Key'      = $LocationNameKeyIndex.$LocKey.Combined_Key
                        'Date Reported'          = $AllColumns.'Date Reported'
                        'Attribute'              = "Active"
                        'Cumulative Value'       = $AllColumns.Active
                        'Change Since Prior Day' = $AllColumns.'Active Delta Value'
                        'Days Since First Value' = $AllColumns.'Days Since First Active'
                    }
                }
                if ( [int]$AllColumns.Deaths -ne 0 ) {
                    if ( $null -eq $LocationNameKeyIndex.$LocKey.DayZeroItems.'Deaths First Location Name Key' ) {
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Deaths First CSV File Name' = $AllColumns.'CSV File Name'
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Deaths First Location Name Key' = $AllColumns.Combined_Key
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Deaths First Date' = $AllColumns.'Date Reported'
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Deaths First Value' = $AllColumns.Deaths
                        $AllColumns.'Deaths Delta Value' = $AllColumns.Deaths
                        $AllColumns.'Days Since First Death' = 0
                    }
                    else {
                        $DateFirstDeath = Get-Date -Date $LocationNameKeyIndex.$LocKey.DayZeroItems.'Deaths First Date'
                        $AllColumns.'Days Since First Death' = $dReported.Subtract($DateFirstDeath).Days
                        $AllColumns.'Deaths Delta Value' = $AllColumns.Deaths - $LocationNameKeyIndex.$LocKey.'CSV Rows PSObj Array'[$PriorRowIndex].Deaths
                    }
                    $UnpivotedRows += [PSCustomObject]@{
                        'Location Name Key'      = $AllColumns.Combined_Key
                        'Date Reported'          = $AllColumns.'Date Reported'
                        'Attribute'              = "Deaths"
                        'Cumulative Value'       = $AllColumns.Deaths
                        'Change Since Prior Day' = $AllColumns.'Deaths Delta Value'
                        'Days Since First Value' = $AllColumns.'Days Since First Death'
                    }
                }
                if ( [int]$AllColumns.Recovered -ne 0 ) {
                    if ( $null -eq $LocationNameKeyIndex.$LocKey.DayZeroItems.'Recovered First Location Name Key' ) {
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Recovered First CSV File Name' = $AllColumns.'CSV File Name'
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Recovered First Location Name Key' = $AllColumns.Combined_Key
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Recovered First Date' = $AllColumns.'Date Reported'
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Recovered First Value' = $AllColumns.Recovered
                        $AllColumns.'Recovered Delta Value' = $AllColumns.Recovered
                        $AllColumns.'Days Since First Recovered' = 0
                    }
                    else {
                        $DateFirstRecovered = Get-Date -Date $LocationNameKeyIndex.$LocKey.DayZeroItems.'Recovered First Date'
                        $AllColumns.'Days Since First Recovered' = $dReported.Subtract($DateFirstRecovered).Days
                        $AllColumns.'Recovered Delta Value' = $AllColumns.Recovered - $LocationNameKeyIndex.$LocKey.'CSV Rows PSObj Array'[$PriorRowIndex].Recovered
                    }
                    $UnpivotedRows += [PSCustomObject]@{
                        'Location Name Key'      = $AllColumns.Combined_Key
                        'Date Reported'          = $AllColumns.'Date Reported'
                        'Attribute'              = "Recovered"
                        'Cumulative Value'       = $AllColumns.Recovered
                        'Change Since Prior Day' = $AllColumns.'Recovered Delta Value'
                        'Days Since First Value' = $AllColumns.'Days Since First Recovered'
                    }

                }
                if ( $AllColumns.Confirmed -ne 0 ) {
                    if ( $null -eq $LocationNameKeyIndex.$LocKey.DayZeroItems.'Confirmed First Location Name Key' ) {
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Confirmed First CSV File Name' = $AllColumns.'CSV File Name'
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Confirmed First Location Name Key' = $AllColumns.Combined_Key
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Confirmed First Date' = $AllColumns.'Date Reported'
                        $LocationNameKeyIndex.$LocKey.DayZeroItems.'Confirmed First Value' = $AllColumns.Confirmed
                        $AllColumns.'Confirmed Delta Value' = $AllColumns.Confirmed
                        $AllColumns.'Days Since First Confirmed' = 0
                    }
                    else {
                        $DateFirstConfirmed = Get-Date -Date $LocationNameKeyIndex.$LocKey.DayZeroItems.'Confirmed First Date'
                        $AllColumns.'Days Since First Confirmed' = $dReported.Subtract($DateFirstConfirmed).Days
                        $AllColumns.'Confirmed Delta Value' = $AllColumns.Confirmed - $LocationNameKeyIndex.$LocKey.'CSV Rows PSObj Array'[$PriorRowIndex].Confirmed
                    }
                    $UnpivotedRows += [PSCustomObject]@{
                        'Location Name Key'      = $AllColumns.Combined_Key
                        'Date Reported'          = $AllColumns.'Date Reported'
                        'Attribute'              = "Confirmed"
                        'Cumulative Value'       = $AllColumns.Confirmed
                        'Change Since Prior Day' = $AllColumns.'Confirmed Delta Value'
                        'Days Since First Value' = $AllColumns.'Days Since First Confirmed'
                    }

                }
                # Add the location data to the index
                $LocationNameKeyIndex.$LocKey.'CSV Rows PSObj Array' += $AllColumns
            } <# No active cases reported for the data since CDC reports all counties now regardless of reports #>
            $FullDataRow += $AllColumns
        } # end for ( $RowNumber = 0; $RowNumber -lt $Csv.CSVData.Length; $RowNumber++ )
        $SortedCSVs[$file].NeedsUpdating = $false

    } #end for loop each set of CSV files

} <# END: Execution of the loading of data #>

if ( $true ) <#  Write results to files for GitHub #> { 

    if ( $UnpivotedRows.Count -gt 0 ) {
        $UnpivotedRows | Export-Csv -Path $LocalFiles.'DBT_JHU_Unpivoted_Data' -NoTypeInformation
    }

    $FullDataRow | Export-Csv -Path $LocalFiles.'DBT_FullDataRow_Daily_Reports' -NoTypeInformation

    if ( $false )  <# Look for bad data that didn't match $Combine_Key #> {
        Write-Host "Writing: ", ($LocationNameKeyIndex.Keys).count, " locations to ", "dimUniqueCombinedKeyValuesInCSEGISandDatas.csv"
        $Locations = @()
        foreach ( $Key in $LocationNameKeyIndex.Keys) {
            if ( $null -ne $Combined_Key.$Key ) {
                $KeyOK = "OK"
            }
            else { 
                $KeyOK = "BAD Key in file ", $LocationNameKeyIndex.$Key.'CSV Rows PSObj Array'[0].'CSV File Name', "Key = '", $Key , "'" -join ""
                Write-Host $KeyOK
            }

            $Locations += [PSCustomObject]@{
                'Location Name Key'          = $LocationNameKeyIndex.$Key.'Location Name Key'
                'Number of Rows'             = $LocationNameKeyIndex.$Key.'CSV Rows PSObj Array'.count
                'Latitude'                   = $LocationNameKeyIndex.$Key.Latitude
                'Longitude'                  = $LocationNameKeyIndex.$Key.Longitude
                'Population'                 = $LocationNameKeyIndex.$Key.Population
                'Combined_Key'               = $LocationNameKeyIndex.$Key.Combined_Key
                'Country or Region'          = $LocationNameKeyIndex.$Key.'Country or Region'
                'Province or State'          = $LocationNameKeyIndex.$Key.'Province or State'
                'State'                      = $LocationNameKeyIndex.$Key.State   # US State code
                'Name'                       = $LocationNameKeyIndex.$Key.Name # US State Name 
                'USA or Global'              = $LocationNameKeyIndex.$Key.'USA or Global'
                'USA State County'           = $LocationNameKeyIndex.$Key.'USA State County'
                'FIPS USA State County code' = $LocationNameKeyIndex.$Key.'FIPS USA State County code'
                'County State Key'           = ($LocationNameKeyIndex.$Key.'County State Key')
                'Combined_Key_Status'        = $KeyOK
                'CSV File Name 1st Found'    = $LocationNameKeyIndex.$Key.'CSV Rows PSObj Array'[0].'CSV File Name'
                'CSV File 1st Row Number '   = $LocationNameKeyIndex.$Key.'CSV Rows PSObj Array'[0].'Row Number'

            }
        }
        $UniqueLocationsPath = $GitLocalRoot, "\", $DataDir, "\", "dimUniqueCombinedKeyValuesInCSEGISandDatas.csv" -join "" 
        $Locations | Export-Csv -Path $UniqueLocationsPath -NoTypeInformation 

        $LocationsNotInCSSEGIS = $Locations | Where-Object -Property Combined_Key_Status -NE "OK"
        $LocationsNotInCSSEGIS | Export-Csv -Path ($GitLocalRoot, "\", $DataDir, "\", "dim_Bad_Combined_Keys.csv" -join "" ) -NoTypeInformation
    } <# END: Look for bad data that didn't match $Combine_Key #>

    if ( $true )  <# Write out the file list of processed files #> {
        $Columns = $FilesInfo[0].psobject.Properties.Name
        $OutColumns = @()
        for ( $c = 0; $c -lt $Columns.Count; $c++) {
            if ( $Columns[ $c ] -ne 'CSVData' ) {
                $OutColumns += $Columns[ $c ]
            }
        }
        for ( $i = 0; $i -lt $FilesInfo.Count ; $i++) {
            $FilesInfo[ $i ].CsvFileName = $FilesInfo[ $i ].PeriodEnding, ".csv" -join ""
            $FilesInfo[ $i ].FileNumber = $i
            $FilesInfo[ $i ].NeedsUpdating = $false
        }
        $FilesInfo | Select-Object -Property $OutColumns | Where-Object -Property 'PeriodEnding' -lt '04-11-2020' | Export-Csv -Path $LocalFiles.DBT_Daily_Reports_Files_Loaded -NoTypeInformation
    } <# END: Write out the file list of processed files #>

    if ( $false ) <# Clean out First Event data from our existing data #> {
        $UnpivotedRows = Import-Csv -Path $LocalFiles.'DBT_JHU_Unpivoted_Data'
        $DataWithoutFirstEvent = $UnpivotedRows | Where-Object { ( $_.Attribute -ne "First Event" ) } | Sort-Object  'Date Reported', 'Location Name Key'  
        $DataWithoutFirstEvent | Export-Csv -Path $LocalFiles.'DBT_JHU_Unpivoted_Data' -NoTypeInformation
        $UnpivotedRows = Import-Csv -Path $LocalFiles.'DBT_JHU_Unpivoted_Data'
        $FullDataRow = Import-Csv -Path $LocalFiles.'DBT_FullDataRow_Daily_Reports' 

        # Clean out data needing refresh
        $UnpivotedRows | Where-Object { ( $_.'Date Reported' -le $LastFileLoaded ) } | Sort-Object  'Date Reported', 'Location Name Key' | Export-Csv -Path $LocalFiles.'DBT_JHU_Unpivoted_Data' -NoTypeInformation
        $UnpivotedRows = Import-Csv -Path $LocalFiles.'DBT_JHU_Unpivoted_Data'
        
        $FullDataRow | Where-Object { ( $_.'Date Reported' -le $LastFileLoaded ) } | Sort-Object  'Date Reported', 'Location Name Key' | Export-Csv -Path $LocalFiles.DBT_FullDataRow_Daily_Reports -NoTypeInformation
        $FullDataRow = Import-Csv -Path $LocalFiles.'DBT_FullDataRow_Daily_Reports' 
        
        $FilesInfo | Select-Object -Property $OutColumns | Where-Object -Property 'PeriodEnding' -lt '04-11-2020' | Export-Csv -Path $LocalFiles.DBT_Daily_Reports_Files_Loaded -NoTypeInformation
        $FilesInfo = Import-Csv -Path $LocalFiles.DBT_Daily_Reports_Files_Loaded

    }

} <# END: Write results to files for GitHub #>

if ($false ) <# Get the daily_reports_US files - temp code #> {
    
    $USFiles = Get-ChildItem -Path "C:\Users\Bill\OneDrive\Bill\Documents\My GitLab\COVID-19\csse_covid_19_data\csse_covid_19_daily_reports_us"
    $First = $true
    foreach ( $CSVFileName in $USFiles) {
        if ( $CSVFileName.Extension -eq ".csv" -and $CSVFileName.BaseName -like "*-2020" ) {
            $CSVData = Import-Csv -Path $CSVFileName.FullName 
            $CSVData | Add-Member -MemberType NoteProperty -Name 'CSV File Name' -Value $CSVFileName.Name
            $CSVData | Add-Member -MemberType NoteProperty -Name 'Date Reported' -Value $CSVFileName.BaseName
            $CSVData | Add-Member -MemberType NoteProperty -Name 'Combined_Key' -Value $null
            $CSVData | Add-Member -MemberType NoteProperty -Name 'Source_Type' -Value "csse_covid_19_daily_reports_us"

            for ( $CsvRow = 0; $CsvRow -lt $CSVData.Count; $CsvRow++ ) {
                $KeyLoc = $CSVData[ $CsvRow ].Province_State, $CSVData[ $CsvRow ].Country_Region -join ", "
                $FIPSObj = $Combined_Key.$KeyLoc
                if ( $null -ne $FIPSObj ) {
                    $CSVData[ $CsvRow ].Combined_Key = $FIPSObj.Combined_Key
                    if ( $CSVData[ $CsvRow ].Province_State -eq "Recovered") {
                        $CSVData[ $CsvRow ].Lat = $Combined_Key.'US'.Lat
                        $CSVData[ $CsvRow ].'Long_' = $Combined_Key.'US'.'Long_'
                    }
                }
            }
            $CSVData | Sort-Object -Property UID | Export-Csv -Path "C:\Users\Bill\OneDrive\Bill\Documents\My GitLab\Covid-19-Power-BI\Working Files\daily_reports_us\$($CSVFileName.Name)" -NoTypeInformation
            if ($First) {
                $CSVData | Sort-Object -Property UID | Export-Csv -Path "C:\Users\Bill\OneDrive\Bill\Documents\My GitLab\Covid-19-Power-BI\Working Files\daily_reports_us\merged_daily_reports_us.csv" -NoTypeInformation
                $First = $false
            }
            else {
                $CSVData | Sort-Object -Property UID | Export-Csv -Path "C:\Users\Bill\OneDrive\Bill\Documents\My GitLab\Covid-19-Power-BI\Working Files\daily_reports_us\merged_daily_reports_us.csv" -NoTypeInformation -Append
            }
        }
    }
} <# END: Get the daily_reports_US files - temp code #>

<# TODO Write out the File#>
if ($false)    <# TODO - Finish writing data to other files #> {
    $FilesInfo[$File].NeedsUpdating = $false 
    # Write out the new or updated Daily-Files-Metadata.csv
    $LocalDataFilesMetadata | Split-Path -LeafBase
    if ( $DebugOptions.WriteFilesToTemp) {

        $OutputPath = ($DebugOptions.TempPath, "\", ($LocalDataFilesMetadata | Split-Path -LeafBase), ".json" -join "")
        $FilesInfo | ConvertTo-Json | Out-File -Path $OutputPath
    }
    if ( $DebugOptions.UpdateLocalFiles ) {
        $OutputPath = $LocalDataFilesMetadata
        $FilesInfo | Export-Csv -Path $OutputPath -NoTypeInformation 
    }

    if ( $DebugOptions.WriteFilesToTemp ) {
        $FullDataRow | Sort-Object -Property $SortList | Export-Csv -Path ( $DebugOptions.TempPath , "\", "CSSEGISandData-COVID-19-Derived-FullList.csv" -join "") -NoTypeInformation
    }

    $LocationNameKeyIndex.Count

    if ( $true )  <# Write the LocationNameKeyIndex to JSON and CSV  #> {
        $FirstTime = $true
        foreach ( $LocKey in $LocationNameKeyIndex.Keys) {
            Write-Host $LocKey, " with csv count: ", $LocationNameKeyIndex.$LocKey.'CSV Rows PSObj Array'.Count
            if ( $FirstTime ) {
                $LocationNameKeyIndex.$LocKey.'CSV Rows PSObj Array' | Export-Csv -Path ( $LocalDataGitPath , "CSSEGISandData-COVID-19-Derived-Flat-Daily-Values.csv" -join "") -NoTypeInformation
                $FirstTime = $false
            }
            else {
                $LocationNameKeyIndex.$LocKey.'CSV Rows PSObj Array' | Export-Csv -Path ( $LocalDataGitPath , "CSSEGISandData-COVID-19-Derived-Flat-Daily-Values.csv" -join "") -NoTypeInformation -Append
            }
            foreach ( $DailyCSV in $LocationNameKeyIndex.$LocKey.'CSV Rows PSObj Array' ) {
                break
            }
        }
    
        $JsonHeader = @{
            FileName                   = "CSSEGISandData-COVID-19-LocationNameKeyIndex.json"
            FileDBT_JHU_Unpivoted_Data = $URLs.DBT_JHU_Unpivoted_Data, "CSSEGISandData-COVID-19-LocationNameKeyIndex.json" -join ""
            FileDescription            = @"
    Data was derived by DB Best Technologies, LLC from the daily reports located at:
    $GitRawRoot
    
    List of 'Location Name Key' values for the revised format for reporting with Power BI and other BI tools.
    
    Data includes the number of events for each day since the first report from the Daily Files. 
    It also includes cumulative values since the first reported date for comparing trends based on a starting value.
    
    Due to column header changes during the project and irregularities in early reporting, there are several changes made as 
    documented in this structure. In addition, Latitude and Longitude values matched to the latest reports.
    
    See the following structures in this document:
    - ColumnsMappingChanges
    - ColumnHeaderChanges
    - CountryRegionReplacements
    - ProvinceStateReplacements
    - CountyAdmin2Replacements
"@
            FileGeneratedOn            = Get-Date -Date ((Get-Date).ToUniversalTime()) -Format "yyyy-MM-ddTHH:mm:ssZ"
            ColumnsMappingChanges      = $NewColumnsMapping
            ColumnHeaderChanges        = $ColumnHeaders
            CountryRegionReplacements  = $CountryReplacements
            CountyAdmin2Replacements   = $CountyReplacements
            ProvinceStateReplacements  = $StateReplacements
            Results                    = $LocationNameKeyIndex | Sort-Object -Property 'Location Name Key' 
        }
        $JsonHeader | ConvertTo-Json -Depth 100 | Out-File -Path ( $LocalDataGitPath, $JsonHeader.FileName -join "")
    
        $copyLocationNameKeyIndex = $LocationNameKeyIndex.Clone()
    
    
    }   <# Endif Write the LocationNameKeyIndex to JSON #>
    

    if ( $false ) <# There is something odd about the way this is written out, debug later if needed - data in looks good #> {
        $Continue = $null
        if ( $DebugOptions.UpdateLocalFiles) <# Write out the updated CSSEGISandData-COVID-19-Derived.csv as needed #> { 
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
                if ( $Continue -ne "Rip") { 
                    $Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
                    if ( $Continue -eq "No") { Exit 0 }
                }
                Write-Host $KeyValue
  
                if ( $FirstTime -eq $true -and $DebugOptions.UpdateLocalFiles) {
                    $GroupedFileRows.$KeyValue | Select-Object -Property $SelectColumnList | Sort-Object -Property $SortList | Export-Csv -Path ($GitLocalRoot, "\", $DataDir, "\", "CSSEGISandData-COVID-19-Derived.csv" -join "") -NoTypeInformation 
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

                $OutputPath = ($DebugOptions.TempPath, "\", ($LocalDataFilesMetadata | Split-Path -LeafBase), ".json" -join "")
                $FilesInfo | ConvertTo-Json | Out-File -Path $OutputPath
            }
            if ( $DebugOptions.UpdateLocalFiles ) {
                $OutputPath = $LocalDataFilesMetadata
                $FilesInfo | Export-Csv -Path $OutputPath -NoTypeInformation 
            }
        } # end  if ( $DebugOptions.UpdateLocalFiles) 
    } <# if false - There is something odd about the way this is written out, debug later if needed - data in looks good #> 
    
    if ( $DebugOptions.WriteFilesToTemp ) {
        $FullDataRow | Sort-Object -Property $SortList | Export-Csv -Path ( $DebugOptions.TempPath , "\", "CSSEGISandData-COVID-19-Derived-FullList.csv" -join "") -NoTypeInformation
    }


    Write-Host 'TODO if $FilesLookupHash is eempty ' , ($null -eq $FilesLookupHash )

    if ( $DebugOptions.WriteFilesToTemp ) {
        $UniqueLocationKeys = $FullDataRow | Sort-Object -Property 'Location Name Key' -Unique 
        Write-Host "Count of unique values for 'Location Name Key': ", $UniqueLocationKeys.Count
        $UniqueLocationKeys | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Unique-Location-Name-Key-Values.csv" -join "") -NoTypeInformation

        if ( $Continue -ne "Rip") { 
            $Continue = Read-Host "`nFinished writing data for UniqueLocation Keys. `nDo you want to continue? 'Yes' or 'No'"
            if ( $Continue -eq "No") { $Continue = $null; Write-Host "Exiting"; Exit 0 }
        }

        # Need to join this with the US-State-Lat-Long-Data.csv to fill in the blanks
        $UnknownOrUnassignedCounties = $FullDataRow | Where-Object { ( $_.'USA State County' -eq "Unknown" -or $_.'USA State County' -eq "Unassigned" -or $null -ne $_.'US Invalid State Name' -or $null -ne $_.'US Invalid County Name' -or $null -ne $_.'Ship Name' ) } | Sort-Object -Property @{Expression = 'Four Part Key' } -Unique 
        Write-Host "County values where values are Unknown or Unassigned: ", $UnknownOrUnassignedCounties.Count
        $UnknownOrUnassignedCounties | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Unassigned-or-Unknown-USA-County-Values.csv" -join "") -NoTypeInformation 

        # Use this as the master list for looking up 'Location Name Key' values
        $UniqueLocationKeys = $FullDataRow | Sort-Object -Property 'Location Name Key' -Unique 
        Write-Host "Count of unique values for 'Location Name Key': ", $UniqueLocationKeys.Count
        $UniqueLocationKeys | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Unique-Location-Name-Key-Values.csv" -join "") -NoTypeInformation

        # Use this for looking up missing Lat and Long values
        $UniqueLocationKeysWithLatLong = $FullDataRow | Where-Object { ( $_.Latitude -ne "0" -and $_.Latitude -ne "0.0" -and $_.Latitude -ne $null -and $_.Latitude -ne "" -and $_.Longitude -ne "0" -and $_.Longitude -ne "0.0" -and $_.Longitude -ne $null -and $_.Longitude -ne "" ) } | Sort-Object -Property 'Location Name Key' -Unique | Select-Object 'Location Name Key', Latitude, Longitude, 'Country or Region', 'Province or State', 'USA State County', 'FIPS USA State County code'
        Write-Host "Count of unique values for 'Location Name Key' with Lat and Long: ", $UniqueLocationKeysWithLatLong.Count
        $UniqueLocationKeysWithLatLong | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Unique-Location-Name-Key-With-Lat-and-Long.csv" -join "") -NoTypeInformation

    } # Write the location files for match ups


    if ( $false )  <# Write the LocationNameKeyIndex to JSON #> { 
        $JsonHeader = @{
            FileName                   = "CSSEGISandData-COVID-19-LocationNameKeyIndex.json"
            FileDBT_JHU_Unpivoted_Data = $URLs.DBT_JHU_Unpivoted_Data, "CSSEGISandData-COVID-19-LocationNameKeyIndex.json" -join ""
            FileDescription            = @"
Data was derived by DB Best Technologies, LLC from the daily reports located at:
$GitRawRoot

List of 'Location Name Key' values for the revised format for reporting with Power BI and other BI tools.

Data includes the number of events for each day since the first report from the Daily Files. 
It also includes cumulative values since the first reported date for comparing trends based on a starting value.

Due to column header changes during the project and irregularities in early reporting, there are several changes made as 
documented in this structure. In addition, Latitude and Longitude values matched to the latest reports.

See the following structures in this document:
- ColumnsMappingChanges
- ColumnHeaderChanges
- CountryRegionReplacements
- ProvinceStateReplacements
- CountyAdmin2Replacements
"@
            FileGeneratedOn            = Get-Date -Date ((Get-Date).ToUniversalTime()) -Format "yyyy-MM-ddTHH:mm:ssZ"
            ColumnsMappingChanges      = $NewColumnsMapping
            ColumnHeaderChanges        = $ColumnHeaders
            CountryRegionReplacements  = $CountryReplacements
            CountyAdmin2Replacements   = $CountyReplacements
            ProvinceStateReplacements  = $StateReplacements
            Results                    = $LocationNameKeyIndex | Sort-Object -Property 'Location Name Key' 
        }
        $JsonHeader | ConvertTo-Json -Depth 100 | Out-File -Path ( $LocalDataGitPath, $JsonHeader.FileName -join "")

        $copyLocationNameKeyIndex = $LocationNameKeyIndex.Clone()


    } <# Endif Write the LocationNameKeyIndex to JSON #>

    <# 04-08-2020 at 7am
Count of unique values for 'Location Name Key':  3791
County values where values are Unknown or Unassigned:  50
Count of unique values for 'Location Name Key':  3791
Count of unique values for 'Location Name Key' with Lat and Long:  3707
#>



    if ( $false ) <# Other housekeeping items #> {
    


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


        $UnknownOrUnassignedCounties = $FullDataRow | Where-Object { ( $_.'USA State County' -eq "Unknown" -or $_.'USA State County' -eq "Unassigned" ) } | Sort-Object -Property @{Expression = 'Location Name Key' } -Unique 
        Write-Host "County values where values are Unknown or Unassigned: ", $UnknownOrUnassignedCounties.Count
        $UnknownOrUnassignedCounties | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Unassigned-or-Unknown-USA-County-Values.csv" -join "") -NoTypeInformation 

        $UniqueLocationKeys = $PriorDataRows | Sort-Object -Property 'Location Name Key' -Unique 
        Write-Host "Count of unique values for 'Location Name Key': ", $UniqueLocationKeys.Count
        $UniqueLocationKeys | Export-Csv -Path ($GitLocalRoot, "\Working Files\", "Unique-Location-Name-Key-values.csv" -join "") -NoTypeInformation

    

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
    } # end if Other housekeeping items

} <# TODO - Finish writing data to other files #>