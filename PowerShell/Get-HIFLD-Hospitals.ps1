<# 
Title: Get-HIFLD-Hospitals.ps2
Description: Extracts Hospitals from Homeland Infrastructure Foundation-Level Data (HIFLD) Hospitals
at https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals. There is a URL do download all the hospitals as CSV
listed in the code.
Author: Bill Ramos, DB Best Technologies
#>

$OutputPathData = ".\Data-Files\HIFLDHospitals.csv"
$OutputPathMetadata = ".\Data-Files\HIFLDHospitalsMetadata.json"
$HIFLDHospitalsURL = "https://opendata.arcgis.com/datasets/6ac5e325468c4cb9b905f1728d6fbf0f_0.csv?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D"

# Get the latest CSV file and write it out to Data-Files folder to check into GitHib
$HisRow = @()
$Hospitals = @()
$HTML = Invoke-WebRequest -URI $HIFLDHospitalsURL
$HTML.Content | Out-File -FilePath $OutputPathData
$HosRows = Import-Csv -Path $OutputPathData 

$Hospitals = $HosRows | Sort-Object -Property State 
$Hospitals | Add-Member -MemberType NoteProperty -Name 'Combined_Key' -Value $null
$Hospitals | Add-Member -MemberType NoteProperty -Name 'State Name' -Value $null
$Hospitals | Add-Member -MemberType NoteProperty -Name 'KeyOK' -Value $null
$Hospitals | Export-Csv -Path $OutputPathData -NoTypeInformation

$LoadStateIndexes = $False
if ( $LoadStateIndexes ) <# Using dimUSPSStateCodeWithLatLong.csv to create  $StateCodeFromName and $StateNameFromCode #> {
    # Example:  $StateCodeFromName.'CA'          -> "California"
    #           $StateCodeFromName.'California'  -> "CA" 
    $USStateCSV = Import-Csv -Path ($GitLocalRoot, $DataDir, "dimUSPSStateCodeWithLatLong.csv" -join "\")
    Write-Host "Creating indexes for dimUSPSStateCodeWithLatLong.csv"
    $StateCodeFromName = @{ }
    $StateNameFromCode = @{ }
    $USStateCSV | Add-Member -MemberType NoteProperty -Name "Combined_Key" -Value $null
    foreach ( $State  in $USStateCSV ) {
        $StateCode = $State.State_Code
        $StateName = $State.Province_State
        $StateCodeFromName.Add( $StateName, $State)
        if ( "US" -eq $State.'State_Code') {
            $StateCodeFromName.$StateName.Province_State = $null
            $StateCodeFromName.$StateName.Combined_Key = $State.'State_Code'
            $StateCodeFromName.$StateName."Location Name Key" = $State.'State_Code'
        }
        else {
            $StateCodeFromName.$StateName.Combined_Key = $StateName , ", US" -join ""
            $StateCodeFromName.$StateName.'Location Name Key' = $State.State_Code, ", US" -join ""
        }
        $StateNameFromCode.Add( $StateCode, $StateCodeFromName.$StateName )
    } 
}<# END: Using dimUSPSStateCodeWithLatLong.csv to create  $StateCodeFromName and $StateNameFromCode #>

$Load_Combined_Key = $false
if ($Load_Combined_Key ) <# Load of $Combined_Key index from dimUID_ISO_FIPS_LookUp_Table.csv #> {
    # UID: 84070005; Combined_Key: "Federal Correctional Institution (FCI), Michigan, US" 42.094563, -83.669482
    # UID: 84070004 ; Combined_Key: "Michigan Department of Corrections (MDOC),Michigan,US" 42.733158, -84.550168
    $FIPS_WR = Invoke-WebRequest -Uri $URLs.GetRawLocations
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
        $FIPSFilePath = ($GitLocalRoot, $DataDir, "dimUID_ISO_FIPS_LookUp_Table.csv" -join "\")
        $FIPS_WR.Content | Out-File -FilePath  $FIPSFilePath
        $UID_ISO_FIPS_LookupCSV = Import-Csv -Path $FIPSFilePath | Sort-Object  Country_Region, Province_State
        $UID_ISO_FIPS_LookupCSV | Add-Member -MemberType NoteProperty -Name 'State_Code' -Value $null
        $UID_ISO_FIPS_LookupCSV | Add-Member -MemberType NoteProperty -Name 'Location Name Key' -Value $null
        $UID_ISO_FIPS_LookupCSV | Add-Member -MemberType NoteProperty -Name 'US State County Key' -Value $null
        $UID_ISO_FIPS_LookupCSV | Export-Csv -path $FIPSFilePath 

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
            # Create the location code based on the parts of Combined_Key
            if ( "US" -eq $UID.Country_Region -and $UID.Province_State.Length -ge 0 ) {
                $UID.State_Code = $StateCodeFromName.($UID.Province_State).State_Code
                if ( $UID.State_Code.Length -eq 0 ) { 
                    $UID.State_Code = $UID.Province_State
                }
                if ( $UID.Admin2.Length -gt 0 ) {
                    $UID.'Location Name Key' = $UID.Admin2, $UID.State_Code, "US" -join ", " 
                    $UID.'US State County Key' = $UID.Combined_Key
                }
                elseif ( $UID.State_Code.Length -gt 0) {
                    $UID.'Location Name Key' = $UID.State_Code, "US" -join ", "
                }
                else {
                    $UID.'Location Name Key' = "US"
                }
            }
            else {
                $UID.'Location Name Key' = $UID.Combined_Key
            }
            # Make corrections based on $UID.UID
            if ( $UID.UID -eq "84070005" ) {
                $UID.Lat = "42.094563"
                $UID.Long_ = "-83.669482"
            } elseif ( $UID.UID -eq "84070004" ) {
                $UID.Lat = "42.733158"
                $UID.Long_ = "-83.550168"
            }
            $Combined_Key.Add( $UID.Combined_Key, $UID )
            $ProgressValueKey = $UID.Province_State, $UID.Country_Region
            if ( $ProgressValue -ne  $ProgressValueKey ) {
                Write-Host "Progress: ", $ProgressValueKey
                $ProgressValue = $ProgressValueKey
            }
        }
        $UID_ISO_FIPS_LookupCSV | Export-Csv -Path $FIPSFilePath -NoTypeInformation
    }
} <# END: Load of $Combined_Key index from dimUID_ISO_FIPS_LookUp_Table.csv #>


$Load_Zip_City_State_Key = $false
if ( $Load_Zip_City_State_Key ) <# Using dimUS_zip_codes_states.csv to create $CountyNameFromZip and $CountyNameFromCity #> { 
    # Load Data-Files/dimUS_zip_codes_states.csv 
    # Usage examples: $CountyNameFromZip.'89027'.county             -> "Clark"
    # Usage examples: $CountyNameFromCity.'Mesquite, Nevada'.county -> "Clark"

    $CITY_WR = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/Data-Files/dimUS_zip_codes_states.csv"
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
        $FileName = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/Data-Files/dimUS_zip_codes_states.csv" | Split-Path -Leaf 
        $ZipFilePath = ($GitLocalRoot, $DataDir, $FileName -join "\")
        $CITY_WR.Content | Out-File -FilePath  $ZipFilePath
        $CITY_CSV = Import-Csv -Path $ZipFilePath | Sort-Object  state, city
        $CITY_CSV | Add-Member -MemberType NoteProperty -Name 'City_State_Key' -Value $null
        $CITY_CSV | Add-Member -MemberType NoteProperty -Name 'Combined_Key' -Value $null
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
                } else {
                    $PossibleKey = Get-BuildCombinedKey $Zip.county, $StateNameFromCode.($Zip.state).Province_State, "US"  
                    if ( $null -ne $Combined_Key.($PossibleKey) ) {
                        
                    } else {
                        $Zip.Combined_Key = $Combined_Key.($Zip.county, $StateNameFromCode.($Zip.state).Province_State, "US" -join ", ").Combined_Key
                    }
                }
                $CountyNameFromZip.Add( $Zip.zip_code, $Zip  )
                
            }
            if ( $Zip.county.Length -eq 0 ) { continue }
            if ( $Zip.city.Length -eq 0 ) { continue }
            if ( $Zip.state.Length -eq 0 ) { continue }

            $KeyValue = $Zip.city, $StateNameFromCode.($Zip.state).Province_State -join ", "
            if ( $null -eq $CountyNameFromCity.$KeyValue ) {
                $Zip.City_State_Key = $KeyValue
                $CountyNameFromCity.Add( $KeyValue, $Zip  )
            }
            if ($CurrentState -ne $Zip.state) {
                $CurrentState = $Zip.state
                Write-host "Indexing : ", $StateNameFromCode.($Zip.state).Province_State
            }
        
        }
        $CITY_CSV | Export-Csv -path $ZipFilePath -NoTypeInformation
    }
} <# END: Using dimUS_zip_codes_states.csv to create $CountyNameFromZip and $CountyNameFromCity #>


$TextInfo = (Get-Culture).TextInfo
$Columns = $hospitals[0].psobject.properties.Name | Sort-Object

if ($false) <# Generate code for column mapping #> {
    Write-Host
    # Write-Host '$ColMap = [PSCustomObject]@{'
    Write-Host '$HospitalClass = [PSCustomObject]@{'
    # Write-Host 'Combined_Key = $null'
    for ($Col = 0; $Col -lt $Columns.Count; $Col++) {
        $Old = $Columns[$Col]
        if ( "X" -eq $Columns[$Col] ) { 
            $New = "Latitude"
        }
        elseif ("Y" -eq $Columns[$Col] ) {
            $New = "Longitude"
        }
        elseif ( $Columns[$Col] -like "*FIPS*") {
            $New = $Columns[$Col]
        }
        elseif ($Columns[$Col] -like "NAICS*") {
            $New = $Columns[$Col]
        }
        else {
            $New = $TextInfo.ToTitleCase( $Columns[$Col].ToLower() )
        }
        #      Write-Host ($Old, ' = "', $New, '"' -join "" )
        Write-Host ($New, ' = $null' -join "" )
    }
    Write-Host '} <# End: $ColMap -  #>'
    Write-Host 


}

$ColMap = [PSCustomObject]@{
    ADDRESS    = "Address"
    ALT_NAME   = "Alt_Name"
    BEDS       = "Beds"
    CITY       = "City"
    COUNTRY    = "Country"
    COUNTY     = "County"
    COUNTYFIPS = "COUNTYFIPS"
    HELIPAD    = "Helipad"
    ID         = "Id"
    LATITUDE   = "Latitude"
    LONGITUDE  = "Longitude"
    NAICS_CODE = "NAICS_CODE"
    NAICS_DESC = "NAICS_DESC"
    NAME       = "Name"
    OBJECTID   = "Objectid"
    OWNER      = "Owner"
    POPULATION = "Population"
    SOURCE     = "Source"
    SOURCEDATE = "Sourcedate"
    ST_FIPS    = "ST_FIPS"
    STATE      = "State"
    STATE_ID   = "State_Id"
    STATUS     = "Status"
    TELEPHONE  = "Telephone"
    TRAUMA     = "Trauma"
    TTL_STAFF  = "Ttl_Staff"
    TYPE       = "Type"
    VAL_DATE   = "Val_Date"
    VAL_METHOD = "Val_Method"
    WEBSITE    = "Website"
    X          = "Latitude"
    Y          = "Longitude"
    ZIP        = "Zip"
    ZIP4       = "Zip4"
} <# End: $ColMap -  #>

$HospitalClass = [PSCustomObject]@{
    Combined_Key = $null
    KeyOk        = $null
    Address      = $null
    Alt_Name     = $null
    Beds         = $null
    City         = $null
    Country      = $null
    County       = $null
    COUNTYFIPS   = $null
    Helipad      = $null
    Id           = $null
    Latitude     = $null
    Longitude    = $null
    NAICS_CODE   = $null
    NAICS_DESC   = $null
    Name         = $null
    Objectid     = $null
    Owner        = $null
    Population   = $null
    Source       = $null
    Sourcedate   = $null
    ST_FIPS      = $null
    State        = $null
    'State Name' = $null   #### 
    State_Id     = $null
    Status       = $null
    Telephone    = $null
    Trauma       = $null
    Ttl_Staff    = $null
    Type         = $null
    Val_Date     = $null
    Val_Method   = $null
    Website      = $null
    Zip          = $null
    Zip4         = $null
} <# End: $ColMap -  #>

$NewHospitals = @()   # Array of PSObjects with row data remapped to the new $HospitalClass items
$StateShow = $null

for ( $Row = 0; $Row -lt $Hospitals.Count; $Row++ ) {
    $NewRow = $HospitalClass.psobject.Copy()
    $Combined_Key_Obj = @{ }  # Used for results of the Combined_Key for matched records
    # First try to build a key based on the County, State, Country as US
    $Combined_Key_Obj = $Combined_Key.( $Hospitals[$Row].COUNTY, $StateNameFromCode.($Hospitals[$Row].STATE).Province_State, "US" -join ", ")
    if ( $null -eq $Combined_Key_Obj )  <# No Combined_Key found, so check for the non-USA values in COUNTRY #> {
        if ( ",PRI,VIR,GUM,MNP,PLW,ASM," -like "*,$($Hospitals[$Row].COUNTRY),*" ) <# Match!, use the known keys to Map#> {
            switch ( $Hospitals[$Row].COUNTRY ) {
                "PRI" {  $Combined_Key_Obj = $Combined_Key.'Puerto Rico, US' }
                "VIR" {  $Combined_Key_Obj = $Combined_Key.'Virgin Islands, US' }
                "GUM" { $Combined_Key_Obj = $Combined_Key.'Guam, US'}
                "MNP" { $Combined_Key_Obj = $Combined_Key.'Northern Mariana Islands, US'}
                "PLW" { $Combined_Key_Obj = $Combined_Key.'American Samoa, US'}
                "ASM" { $Combined_Key_Obj = $Combined_Key.'American Samoa, US'}
            }
        } elseif ( $null -eq $Combined_Key_Obj -and ",NEW YORK,SAINT CROIX,DISTRICT OF COLUMBIA,LA SALLE,BEDFORD CITY,WRANGELL-PETERSBURG,SHANNON,ST JOSEPH," -like "*,$($Hospitals[$Row].COUNTY),*" ){
            switch ( $Hospitals[$Row].COUNTY ) {
                "SAINT CROIX" {  if ( $Hospitals[$Row].STATE -eq "WI" ) { $Combined_Key_Obj = $Combined_Key.'St. Croix, Wisconsin, US' } }
                "BEDFORD CITY" {  if ( $Hospitals[$Row].STATE -eq "VA" ) { $Combined_Key_Obj = $Combined_Key.'Bedford, Virginia, US' } }
                "NEW YORK" {  if ( $Hospitals[$Row].STATE -eq "NY" ) { $Combined_Key_Obj = $Combined_Key.'New York City, New York, US' } }
                "DISTRICT OF COLUMBIA" {  if ( $Hospitals[$Row].STATE -eq "DC" ) { $Combined_Key_Obj = $Combined_Key.'District of Columbia, US'} }
                "LA SALLE" {  if ( $Hospitals[$Row].STATE -eq "IL" ) { $Combined_Key_Obj = $Combined_Key.'LaSalle, Illinois, US' } }
                "LA SALLE" {  if ( $Hospitals[$Row].STATE -eq "LA" ) { $Combined_Key_Obj = $Combined_Key.'LaSalle, Louisiana, US' } }
                "SHANNON" {  if ( $Hospitals[$Row].STATE -eq "SD" ) { $Combined_Key_Obj = $Combined_Key.'Oglala Lakota, South Dakota, US' } }
                "ST JOSEPH" {  if ( $Hospitals[$Row].STATE -eq "IN" ) { $Combined_Key_Obj = $Combined_Key.'St. Joseph, Indiana, US' } }
                "WRANGELL-PETERSBURG" {  if ( $Hospitals[$Row].STATE -eq "AK" ) { $Combined_Key_Obj = $Combined_Key.'Petersburg, Alaska, US' } }
            }
        } elseif (  $null -eq $Combined_Key_Obj -and  $null -ne $Combined_Key.( $CountyNameFromZip.($Hospitals[$Row].ZIP).county, $StateNameFromCode.($Hospitals[$Row].STATE).Province_State, "US" -join ", " ) )   <#  No Match, so try and use the ZIP code value to look for match in #> {
            $Combined_Key_Obj = $Combined_Key.( $CountyNameFromZip.($Hospitals[$Row].ZIP).county, $StateNameFromCode.($Hospitals[$Row].STATE).Province_State, "US" -join ", " )
        } elseif ( $null -eq $Combined_Key_Obj ) {
                $Combined_Key_Obj = $Combined_Key.( $Hospitals[$Row].COUNTY, $StateNameFromCode.($Hospitals[$Row].STATE).Province_State, "US" -join ", " )
        }
    }
    if ( $null -ne $Combined_Key_Obj ) {
        $NewRow.Combined_Key = $Combined_Key_Obj.Combined_Key
        $NewRow.County = $Combined_Key_Obj.Admin2
        $NewRow.'Name' = $Combined_Key_Obj.Province_State
        $NewRow.'State Name' = $Combined_Key_Obj.Province_State
    }
    else {
        $NewRow.Combined_Key = $Hospitals[$Row].COUNTY, $Hospitals[$Row].STATE, $Hospitals[$Row].COUNTRY -join ", " 
        $NewRow.KeyOk = "Row: ", $Row, $Hospitals[$Row].NAME, " ObjectID = ", $Hospitals[$Row].OBJECTID -join ", "
        $NewRow.'State Name' =  $StateNameFromCode.($Hospitals[$Row].STATE).Province_State
    }

    for ( $c = 0; $c -lt $Columns.Length ; $c++ ) {
        $Value = $Hospitals[$Row].($Columns[$c])
        $Key = ($ColMap.($Columns[$c]))
        if ( $null -eq $key ) {
            $key = $Columns[$c]
        }
        if ( $Value -eq "NOT AVAILABLE" -or $Value -eq "-999" ) {
            $Value = $null
        }
        elseif ( "NAME, ADDRESS, CITY, , NAICS_DESC, OWNER" -like "*$($Columns[$c])*" ) {
            $Value = $TextInfo.ToTitleCase( $Value.ToLower() )
        } 
        if ( ($NewRow.($Key)).Length -eq 0 -and $Value.Length -gt 0 ) {
            $NewRow.($Key) = $Value
        }
    }
    if ( $NewRow.'State Name' -ne $StateShow ) {
        $StateShow = $NewRow.'State Name'
        Write-Host $StateShow
    }
    $NewHospitals += $NewRow
}
$NewHospitals | Export-Csv -Path $OutputPathData -NoTypeInformation

<# 
# Data source uses -999 as null value, so replace the string of ,-999 with ,
((Get-Content -path $OutputPathData -Raw) -replace ',-999', ',') | Set-Content -Path $OutputPathData
# Data source also uses ,NOT AVAILABLE, as null string as well
((Get-Content -path $OutputPathData -Raw) -replace ',NOT AVAILABLE', ',') | Set-Content -Path $OutputPathData
#>

# Gather the meta-data for the data source
$Metadata = [ordered] @{
    "Data File DB Best Git Relative Path" = $OutputPathData
    "Data File DB Best Git Raw File URL"  = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/Data-Files/HIFLDHospitals.csv"
    "Metadata DB Best Git Raw File URL"   = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/Data-Files/HIFLDHospitals.json"
    "Source Web Site"                     = "https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals"
    "Source Data URL"                     = $HTML.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
    "Source Authority"                    = $HTML.BaseResponse.RequestMessage.RequestUri.Authority
    "Source Summary"                      = "This feature class/shapefile contains locations of Hospitals for 50 US states, Washington D.C., US territories of Puerto Rico, Guam, American Samoa, Northern Mariana Islands, Palau, and Virgin Islands. The dataset only includes hospital facilities based on data acquired from various state departments or federal sources which has been referenced in the SOURCE field."
    "Source Metadata Info"                = "https://services1.arcgis.com/Hp6G80Pky0om7QvQ/arcgis/rest/services/Hospitals_1/FeatureServer/0"
    "Retrieved On UTC"                    = $HTML.BaseResponse.Headers.Date.UtcDateTime
    "Retrieved On PST"                    = $HTML.BaseResponse.Headers.Date.LocalDateTime
}
# Write the Metadata out as a Json file
$Metadata | ConvertTo-Json | Out-File -FilePath $OutputPathMetadata

