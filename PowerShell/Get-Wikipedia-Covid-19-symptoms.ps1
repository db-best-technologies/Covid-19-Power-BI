<# 
Title: Get-Wikipedia-Covid-19-Symptoms
Description: Extracts Symptom's wikitable from the Wikipedia page:
https://en.wikipedia.org/wiki/2019%E2%80%9320_coronavirus_pandemic
Author: Bill Ramos, DB Best Technologies
#>
$OutputPathData = ".\Data-Files\WikiSymptoms.csv"
$OutputPathMetadata = ".\Data-Files\WikiSymptomsMetadata.csv"

# Grab the Wikipedia page and load it into memory
$WikiURL = "https://en.wikipedia.org/wiki/2019%E2%80%9320_coronavirus_pandemic"
$HTML = Invoke-WebRequest -URI $WikiURL

# Parse the <Body> of the page out and then cast it as an XML object
[xml]$Body = "<body>", $HTML.Content.Split("<body")[1].Split(">", 2)[1].Split("</html>")[0] -join "" | ConvertTo-Xml 

# Use XPath query to get all of the tables on the page
$Tables = $Body.Objects.Object.'#text' | Select-Xml "//table" | Select-Object -ExpandProperty Node

# Look through the tables to look for the one that has just the class name of wikitable. This is the Symptom's table.
$SymTable = $null
foreach ($T in $Tables) {
    if ($T.class -eq 'wikitable' ) {
        $SymTable = $T
        break
    }
}

# If there was a match for the table, grab the metadata for the page and table to output as a CSV file
if ($null -ne $SymTable) {
    $metadata = @{
        Caption            = $SymTable.caption.Trim()
        WikiRef            = $SymTable.tbody.tr.th.sup.a.href.Trim()
        WikiCite           = $SymTable.tbody.tr.th.sup.a.'#text'.Trim()
        "Page URL"         = $WikiURL.Trim()
        "Page Updated PST" = $HTML.BaseResponse.Headers.Date.LocalDateTime
        "Page Updated UTC" = $HTML.BaseResponse.Headers.Date.UtcDateTime
    }
    # Export the hash table as a Csv file. Need to cast the hash table as a [psCustomObject] to format the CSV file correctly
    [psCustomObject]$metadata | Export-Csv -Path $OutputPathMetadata -NoTypeInformation
    
    # Look through all of the rows to get the column names with the <th> tag and the data rows with the <td> tag
    $Rows = @()
    foreach ($row in $SymTable.tbody.tr) {
        if ($null -ne $row.th ) {
            # We found the <th> table header tag, so process the headers
            $Headers = @()                                  # Each header will get added to this array
            $HID = 0                                        # Used to create Unknown-$HID column if one is missing
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
                if ($null -ne $c) { 
                    $Headers += $c                          # Add the column name for the table to the $headers array
                } else { 
                    $Headers += "Unknown", $HID -join "-" 
                }
                $HID++
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
}
else {
    Write-Error "Table not found" -ErrorAction Stop
}