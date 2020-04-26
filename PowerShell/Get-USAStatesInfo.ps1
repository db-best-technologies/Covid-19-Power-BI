<#
Title: Get-USAStatesInfo.ps2 
Description: Download the state code abbreviations from USPS official site  https://pe.usps.com/text/pub28/28apb.htm
Author: Bill Ramos, DB Best Technologies
#>

$OutputPathData = ".\Working Files\USPS__pe.usps.com__28apb.csv"
$OutputPathMetadata = ".\Working Files\USPS__pe.usps.com__28apb.json"

# Grab the Wikipedia page and load it into memory
$URL = "https://pe.usps.com/text/pub28/28apb.htm"
$HTML = Invoke-WebRequest -URI $URL

$Metadata = [ordered] @{
    "Data File DB Best Git Relative Path" = $OutputPathData
    "Data File DB Best Git Raw File URL"  = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/dev/Working Files/USPS__pe.usps.com__28apb.csv"
    "Metadata DB Best Git Raw File URL"   = "https://raw.githubusercontent.com/db-best-technologies/Covid-19-Power-BI/dev/Working Files/USPS__pe.usps.com__28apb.json"
    "Source Web Site"                     = $HTML.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
    "Source Data URL"                     = $HTML.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
    "Source Authority"                    = $HTML.BaseResponse.RequestMessage.RequestUri.Authority
    "Source Summary"                      = "USPS Publication 28 - Postal Addressing Standards - Appendix B - Two–Letter State and Possession Abbreviations"
    "Source Metadata Info"                = $HTML.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
    "Retrieved On UTC"                    = $HTML.BaseResponse.Headers.Date.UtcDateTime
    "Retrieved On PST"                    = $HTML.BaseResponse.Headers.Date.LocalDateTime
}
# Write the Metadata out as a Json file
$Metadata | ConvertTo-Json | Out-File -FilePath $OutputPathMetadata

$States = @()                                   # Create the array of state pair objects
[bool]$TableStart = $false                      # Counter for the state pairs to start at Alabama
                              
foreach ( $Link in $HTML.Links){                # Loop through the links looking for Alabama to start

    if ($Link.outerHTML -like "*Alabama</a>"){  # Found the first state in the list
        $TableStart = $true                     # Set the $TableStart to value to start adding pairs
        $CellCount = 0                          # Restart the counter so even values starts for modulo 2
    }
    if ($TableStart){
        if ( $CellCount % 2 -eq 0) {            # Get the state name for even values
            $pair = [PSCustomObject] @{"State or Possession" = $Link.outerHTML.Split(">")[1].Split("<")[0]  }
        }
        else {                                  # Get the abbreviation for odd values
            $pair | Add-Member -MemberType NoteProperty -Name "Abbreviation" -Value $Link.outerHTML.Split(">")[1].Split("<")[0]
            $States += $pair                    # Pairing complete, it to the $States array
        }
        $CellCount++                            # Increment the $CellCount value for the next loop
    }
    if ($Link.outerHTML -like "*WY</a>"){       # WY is the last state in the table, so exit the loop
        break
    }
}

$States | Export-Csv -Path $OutputPathData  -NoTypeInformation
