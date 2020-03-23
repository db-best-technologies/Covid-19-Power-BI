<#
Title: Get-USCensusStatePopulationData.ps2 
Description: Download US Census State Population Totals and Components of Change: 2010-2019 from http://www2.census.gov/programs-surveys/popest/datasets/2010-2019/national/totals/nst-est2019-alldata.csv
Author: Bill Ramos, DB Best Technologies
#>

$OutputPathData = ".\Data-Files\USCensusPopulationData2019.csv"
$OutputPathMetadata = ".\Data-Files\USCensusPopulationData2019Metadata.json"

# Grab the Wikipedia page and load it into memory
$URL = "http://www2.census.gov/programs-surveys/popest/datasets/2010-2019/national/totals/nst-est2019-alldata.csv"
$HTML = Invoke-WebRequest -URI $URL

$Metadata = [ordered] @{
    "Data File DB Best Git Relative Path" = $OutputPathData
    "Data File DB Best Git Raw File URL"  = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/Data-Files/USCensusPopulationData2019.csv"
    "Metadata DB Best Git Raw File URL"   = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/Data-Files/USCensusPopulationData2019Metadata.json"
    "Source Web Site"                     = "https://www.census.gov/data/tables/time-series/demo/popest/2010s-state-total.html"
    "Source Data URL"                     = $HTML.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
    "Source Authority"                    = $HTML.BaseResponse.RequestMessage.RequestUri.Authority
    "Source Summary"                      = "State Population Totals and Components of Change: 2010-2019 - Nation, States, and Puerto Rico Population- Data files to download for analysis in spreadsheet, statistical, or geographic information systems software."
    "Source Metadata Info"                = "https://www2.census.gov/programs-surveys/popest/technical-documentation/file-layouts/2010-2019/nst-est2019-popchg2010-2019.pdf"
    "Retrieved On UTC"                    = $HTML.BaseResponse.Headers.Date.UtcDateTime
    "Retrieved On PST"                    = $HTML.BaseResponse.Headers.Date.LocalDateTime
}
# Write the Metadata out as a Json file
$Metadata | ConvertTo-Json | Out-File -FilePath $OutputPathMetadata

$Csv = $HTML.Content                                        # $Csv is now a long string with the Csv file content, not and object

$Csv | Out-File -FilePath $OutputPathData                   # Writing out the file as a CSV file

