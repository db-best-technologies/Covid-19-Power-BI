<# 
Title: Get-HIFLD-Hospitals.ps2
Description: Extracts Hospitals from Homeland Infrastructure Foundation-Level Data (HIFLD) Hospitals
at https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals. There is a URL do download all the hospitals as CSV
listed in the code.
Author: Bill Ramos, DB Best Technologies
#>

$OutputPathData = ".\Data-Files\HIFLDHospitals.csv"
$OutputPathMetadata = ".\Data-Files\HIFLDHospitalsMetadata.csv"
$HIFLDHospitalsURL = "https://opendata.arcgis.com/datasets/6ac5e325468c4cb9b905f1728d6fbf0f_0.csv?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D"


$HTML = Invoke-WebRequest -URI $HIFLDHospitalsURL
$HTML.Content | Out-File -FilePath $OutputPathData
$HTML.BaseResponse
$HTML.BaseResponse.Headers
