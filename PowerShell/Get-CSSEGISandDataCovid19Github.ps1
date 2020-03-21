<# 
Title: Get-HIFLD-Hospitals.ps2
Description: Downloads latest TimeLine file 
Author: Bill Ramos, DB Best Technologies
#>
$OutputPathRoot = ".\Data-Files\"
$OutputUnionPath = $OutputPathRoot,"Time_Series_19-Covid-Union.csv" -join ""

$TimeSeries = @{
    Confirmed = "https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv"
    Deaths    = "https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv"
    Recovered = "https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv"
}

$CsvData = @()
foreach ( $key in $TimeSeries.Keys) {

    $OutputPathData = $OutputPathRoot, (Split-Path -Path $TimeSeries[$key] -Leaf) -join ""
    $OutputPathMetadata = $OutputPathRoot, (Split-Path -Path $TimeSeries[$key]  -LeafBase), ".json" -join ""
    Write-Host $OutputPathData
    Write-Host $OutputPathMetadata

    # Get the latest CSV file and write it out to Data-Files folder to check into GitHib
    $HTML = Invoke-WebRequest -URI $TimeSeries[$Key] -ContentType 'text/plain'
    $Csv = $HTML.Content

    # Add Key value to each row in the CSV file
    $Csv | Out-File -FilePath $OutputPathData 
    $CsvPS = Import-Csv -Path $OutputPathData -Delimiter "," 
    $CsvPS | Add-Member -MemberType NoteProperty -Name "Case_Type" -Value $Key
    $CsvPS | Export-Csv -Path $OutputPathData -NoTypeInformation
    $CsvData += $CsvPS
    
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
$CsvData | Export-Csv -Path $OutputUnionPath  -NoTypeInformation

