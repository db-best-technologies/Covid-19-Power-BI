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
$HTML = Invoke-WebRequest -URI $HIFLDHospitalsURL
$HTML.Content | Out-File -FilePath $OutputPathData

# Data source uses -999 as null value, so replace the string of ,-999 with ,
((Get-Content -path $OutputPathData -Raw) -replace ',-999',',') | Set-Content -Path $OutputPathData
# Data source also uses ,NOT AVAILABLE, as null string as well
((Get-Content -path $OutputPathData -Raw) -replace ',NOT AVAILABLE',',') | Set-Content -Path $OutputPathData

# Gather the meta-data for the data source
$Metadata = [ordered] @{
    "Data File DB Best Git Relative Path" = $OutputPathData
    "Data File DB Best Git Raw File URL" = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/Data-Files/HIFLDHospitals.csv"
    "Metadata DB Best Git Raw File URL" = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/Data-Files/HIFLDHospitals.json"
    "Source Web Site" = "https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals"
    "Source Data URL" = $HTML.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
    "Source Authority" = $HTML.BaseResponse.RequestMessage.RequestUri.Authority
    "Source Summary" = "This feature class/shapefile contains locations of Hospitals for 50 US states, Washington D.C., US territories of Puerto Rico, Guam, American Samoa, Northern Mariana Islands, Palau, and Virgin Islands. The dataset only includes hospital facilities based on data acquired from various state departments or federal sources which has been referenced in the SOURCE field."
    "Source Metadata Info" = "https://services1.arcgis.com/Hp6G80Pky0om7QvQ/arcgis/rest/services/Hospitals_1/FeatureServer/0"
    "Retrieved On UTC" = $HTML.BaseResponse.Headers.Date.UtcDateTime
    "Retrieved On PST" = $HTML.BaseResponse.Headers.Date.LocalDateTime
}
# Write the Metadata out as a Json file
$Metadata | ConvertTo-Json | Out-File -FilePath $OutputPathMetadata

