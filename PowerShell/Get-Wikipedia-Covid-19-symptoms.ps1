<# 
Title: Get-Wikipedia-Covid-19-Symptoms
Description: Extracts Symptom's wikitable from the Wikipedia page:
https://en.wikipedia.org/wiki/2019%E2%80%9320_coronavirus_pandemic
Author: Bill Ramos, DB Best Technologies
#>
$OutputPathData = ".\Data-Files\WikiSymptoms.csv"
$OutputPathMetadata  = ".\Data-Files\WikiSymptomsMetadata.csv"

$WikiURL = "https://en.wikipedia.org/wiki/2019%E2%80%9320_coronavirus_pandemic"
$HTML = Invoke-WebRequest -URI $WikiURL
$LocalDateTime = $HTML.BaseResponse.Headers.Date.LocalDateTime
$UtcDateTime = $HTML.BaseResponse.Headers.Date.UtcDateTime


Write-Host "Page last updated PST: $LocalDateTime, UTC: $UTCDateTime"

[xml]$Body = "<body>", $HTML.Content.Split("<body")[1].Split(">", 2)[1].Split("</html>")[0] -join "" | ConvertTo-Xml 
$Tables = $Body.Objects.Object.'#text' | Select-Xml "//table" | Select-Object -ExpandProperty Node
$SymTable = $null
foreach ($T in $Tables) {
    if ($T.class -eq 'wikitable' ) {
        $SymTable = $T
        break
    }
}
if ($null -ne $SymTable) {
    $metadata = @{
        Caption  = $SymTable.caption.Trim()
        WikiRef  = $SymTable.tbody.tr.th.sup.a.href.Trim()
        WikiCite = $SymTable.tbody.tr.th.sup.a.'#text'.Trim()
        URL      = $WikiURL.Trim()
    }
}
else {
    Write-Error "Table not found" -ErrorAction Stop
    Return($null)
}
[psCustomObject]$metadata | Export-Csv -Path $OutputPathMetadata -NoTypeInformation
    
$Rows = @()
foreach ($row in $SymTable.tbody.tr) {
    if ($null -ne $row.th ) {
        # Process the headers
        $Headers = @()
        foreach ( $column_name in $row.th) {
            if ($null -ne $column_name.span) {
                $c = $column_name.span.title
            }
            elseif ( $null -ne $column_name.'#text') {
                $c = $column_name.'#text'
            }
            else {
                $c = $column_name
            }
            if ($null -ne $c) { $Headers += $c } else { $Headers += "Unknown" }
        }
    }
    elseif ($null -ne $row.td) {
        # Process cell values
        $CV = [Ordered]@{ }
        $i = 0   # Provides index for the $Headers fir each row processed
        foreach ( $cell in $row.td) {
            if ($null -ne $Cell.span ) {
                $c = $Cell.'#text'
            }
            elseif ($null -ne $Cell.a) {
                $c = $Cell.InnerText
            } 
            else {
                $c = $Cell
            }
            $CV.Add($Headers[$i], $c.Trim())
            $i++
        }
        $Rows += [PSCustomObject]$CV
    }
}
[PSCustomObject]$Rows | Export-Csv -Path $OutputPathData -NoTypeInformation
    
$CombinedResults = @{ "Metadata" = $metadata; "Data" = $Rows }
$CombinedResults | Format-List
