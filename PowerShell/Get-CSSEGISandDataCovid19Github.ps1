<# 
Title: Get-HIFLD-Hospitals.ps2
Description: Downloads latest TimeLine file 
Author: Bill Ramos, DB Best Technologies
#>
$OutputPathRoot = ".\Data-Files\"
$OutputUnionPath = $OutputPathRoot,"Time_Series_19-Covid-Union.csv" -join ""
$OutputUnionMetadataPath =  $OutputPathRoot,"Time_Series_19-Covid-Union.json" -join ""

$TimeSeries = @{
    Confirmed = "https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv"
    Deaths    = "https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv"
    Recovered = "https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv"
}
# Create and empty array for adding each of the three files as they are processed
$CsvData = @()
foreach ( $key in $TimeSeries.Keys) {
    # Define the output csv and json files based on the name of the source file
    $OutputPathData = $OutputPathRoot, (Split-Path -Path $TimeSeries[$key] -Leaf) -join ""
    $OutputPathMetadata = $OutputPathRoot, (Split-Path -Path $TimeSeries[$key]  -LeafBase), ".json" -join ""

    # Get the latest CSV file and write it out to Data-Files folder to check into GitHib for the CSSEGISandData/COVID-19 repository
    $HTML = Invoke-WebRequest -URI $TimeSeries[$Key] -ContentType 'text/plain'
    $Csv = $HTML.Content                                                        # $Csv is now a long string with the Csv file content, not and object

    $Csv | Out-File -FilePath $OutputPathData                                   # Writing out the file as a CSV file
    $CsvPS = Import-Csv -Path $OutputPathData -Delimiter ","                    # Using Import-Csv creates an array of [PSCustomObjects] for each row
    $CsvPS | Add-Member -MemberType NoteProperty -Name "Case_Type" -Value $Key  # Magic - Add-Member adds a new "column" for all the rows in the CSV!
    $CsvPS | Export-Csv -Path $OutputPathData -NoTypeInformation                # The CSV file now contains a Case_Type column using Key value from $TimeSeries hash table
    $CsvData += $CsvPS                                                          # Appends the in-memory Csv data to the $CsvData array
    
    # Gather the meta-data for the data source
    $Metadata = [ordered] @{
        "Data File DB Best Git Relative Path" = $OutputPathData
        "Data File DB Best Git Raw File URL"  = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/Data-Files/", (Split-Path -Path $TimeSeries[$key] -Leaf) -join ""
        "Metadata DB Best Git Raw File URL"   = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/Data-Files/",(Split-Path -Path $TimeSeries[$key]  -LeafBase), ".json" -join ""
        "Source Web Site"                     = "https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data"
        "Source Data URL"                     = $HTML.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
        "Source Authority"                    = $HTML.BaseResponse.RequestMessage.RequestUri.Authority
        "Source Summary"                      = "This is the data repository for the 2019 Novel Coronavirus Visual Dashboard operated by the Johns Hopkins University Center for Systems Science and Engineering (JHU CSSE). Also, Supported by ESRI Living Atlas Team and the Johns Hopkins University Applied Physics Lab (JHU APL)."
        "Source Metadata Info"                = "https://github.com/CSSEGISandData/COVID-19"
        "Retrieved On UTC"                    = $HTML.BaseResponse.Headers.Date.UtcDateTime
        "Retrieved On PST"                    = $HTML.BaseResponse.Headers.Date.LocalDateTime
    }
    # Write the Metadata out as a Json file
    $Metadata | ConvertTo-Json | Out-File -FilePath $OutputPathMetadata

}
# Take the Unioned set of three files and output them to the new Time_Series_19-Covid-Union.csv file.
$CsvData | Export-Csv -Path $OutputUnionPath  -NoTypeInformation 

# Create the meta-data file for the new Union file
$Metadata.'Data File DB Best Git Relative Path' = $OutputUnionPath
$Metadata.'Data File DB Best Git Raw File URL' = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/Data-Files/", (Split-Path -Path $OutputUnionPath -Leaf) -join ""
$Metadata.'Metadata DB Best Git Raw File URL' = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/master/Data-Files/", (Split-Path -Path $OutputUnionMetadataPath -Leaf) -join ""
$Metadata.'Source Summary' = "Combines the three time series files for Confirmed, Deaths, and Recovered into a single Csv file. Uses is the data repository for the 2019 Novel Coronavirus Visual Dashboard operated by the Johns Hopkins University Center for Systems Science and Engineering (JHU CSSE). Also, Supported by ESRI Living Atlas Team and the Johns Hopkins University Applied Physics Lab (JHU APL)"
$Metadata.'Source Data URL' = $TimeSeries
$Metadata | ConvertTo-Json | Out-File -FilePath $OutputUnionMetadataPath

# $CsvData | Add=-MemberType -MemberType NoteProperty -Name "Case_Type" -Value $_.'Pro'