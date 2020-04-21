if ($false) <# Random code chunks as clipboard #> {
    $Line.What_Changed = $Line.What_Changed, ': Duplicate Province_State = $null' -join " "
    $CSVData | Add-Member -MemberType NoteProperty -Name 'Combined_Key' -Value $null
}
function Set-DebugOptions {
    param(
        [bool]$WriteFilesToTemp = $true
        , [string]$TempPath = "C:\Temp\Covid-Temp-Files"
        , [bool]$DeleteTempFilesAtStart = $true
        , [bool]$UpdateLocalFiles = $true
        , [bool]$AppendDebugData = $false
        , [bool]$Workaround = $false
    )
    
    $DebugOptions = @{
        WriteFilesToTemp       = $WriteFilesToTemp
        TempPath               = $TempPath
        DeleteTempFilesAtStart = $DeleteTempFilesAtStart
        UpdateLocalFiles       = $UpdateLocalFiles
        LastRun                = Get-Date
        AppendDebugData        = $AppendDebugData
        Workaround             = $Workaround
    }
    # Check to see if the temp folder exists and created it if it doesn't exist
    if (-not (Test-Path -Path $TempPath ) ) {
        $Root = ( Split-Path -Path $TempPath ), "\" -join ""
        $Leaf = Split-Path -Path $TempPath -Leaf
        if ( -not (Test-Path -Path $Root) ) {
            $Root = $env:Temp, "\" -join ""
            $TempPath = $Root, $Leaf -Join ""
            $DebugOptions.TempPath = $TempPath
            $DirObj = $null
            $DirObj = New-Item -Path $Root -Name $Leaf -ItemType "directory"
            if ($null -eq $DirObj -and $WriteFilesToTemp ) {
                Write-Host "Unable to create directory: ", $TempPath, " Switching WriteFilesToTemp as false"
                Start-Sleep 1
                $Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
                if ( $Continue -ne "Yes") { Exit 0 }
            }
        }
    }
    if ( $DebugOptions.DeleteTempFilesAtStart -eq $true ) {
        $Files = Get-ChildItem $DebugOptions.TempPath -Recurse
        $Files | Remove-Item
        if ($DebugOptions.WriteFilesToTemp) {
            $Files | Add-Member -MemberType NoteProperty -Name DebugOptions -Value $DebugOptions
            $hashParams = @{
                LiteralPath = ($DebugOptions.TempPath, "\Removed-Files.json" -join "")
                Append      = $DebugOptions.AppendDebugData
            }
            $Files | ConvertTo-Json | Out-File @hashParams
            $hashParams.LiteralPath = ($DebugOptions.TempPath, "\Last-Debug-Options.yaml" -join "")
            $DebugOptions | ConvertTo-Yaml | Out-File @hashParams
            Remove-Variable 'Files'
            Remove-Variable 'hashParams'
        }
    }
    return $DebugOptions
}

# Example code
if ( $true -eq $false) {
    if ( $DebugOptions.WriteFilesToTemp) {
        if ( $DebugOptions.WriteFilesToTemp) {
            $OutputPath = ($DebugOptions.TempPath, "\", "filename.csv" -join "")
            $objVariable | Export-Csv -Path $OutputPath -NoTypeInformation -UseQuotes AsNeeded
        }
        if ( $DebugOptions.UpdateLocalFiles ) {
            $OutputPath = ($GitLocalRoot, "\Working Files\", "Zeros-For-Lat-Long-Records.csv" -join "")
            $objVariable | Export-Csv -Path $OutputPath -NoTypeInformation -UseQuotes AsNeeded
        }
    }
}


function ConvertTo-PsCustomObjectFromHashtable {
    param (
        [Parameter( 
            Position = 0,  
            Mandatory = $true,  
            ValueFromPipeline = $true, 
            ValueFromPipelineByPropertyName = $true 
        )] [object[]]$hashtable
    );
   
    begin { $i = 0; }
   
    process {
        foreach ($myHashtable in $hashtable) {
            if ($myHashtable.GetType().Name -eq 'hashtable') {
                $output = New-Object -TypeName PsObject;
                Add-Member -InputObject $output -MemberType ScriptMethod -Name AddNote -Value { 
                    Add-Member -InputObject $this -MemberType NoteProperty -Name $args[0] -Value $args[1];
                };
                $myHashtable.Keys | Sort-Object | % { 
                    $output.AddNote($_, $myHashtable.$_); 
                }
                $output;
            }
            else {
                Write-Warning "Index $i is not of type [hashtable] - its really $($myHashtable.GetType().Name)";
            }
            $i += 1; 
        }
    }
}

function ConvertTo-HashtableFromPsCustomObject {
    param (
        [Parameter( 
            Position = 0,  
            Mandatory = $true,  
            ValueFromPipeline = $true, 
            ValueFromPipelineByPropertyName = $true 
        )] [object[]]$psCustomObject
    );
   
    process {
        foreach ($myPsObject in $psObject) {
            $output = @{ };
            $myPsObject | Get-Member -MemberType *Property | % {
                $output.($_.name) = $myPsObject.($_.name);
            }
            $output;
        }
    }
}

if (1 -eq 2 ) { 
    $WebRequest = $null
    $WebRequest = Invoke-WebRequest -Uri $URLs.GitRawDataFilesMetadata
    if ( $null -eq $WebRequest.Content ) {
        $Errorlog += $WebRequest.Headers
        $WebRequest.Headers | ft
        Start-Sleep -Seconds 1
        $Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
        if ( $Continue -ne "Yes") { Exit 0 }
    }
}

if (1 -eq 2) {
    $FilesInfoYaml = Get-Content -LiteralPath "C:\Users\Bill\OneDrive\Bill\Documents\My GitLab\Covid-19-Power-BI\Working Files\CSSEGISandData-COVID-19-Derived-FileInfo.yaml" 
    $FilesInfoYamlArray = $FilesInfoYaml | ConvertFrom-Yaml
    $FilesInfo = @()
    $FilesEmptyPSObject = [PSCustomObject]@{
        CsvFileName         = ""
        DateLastModifiedUTC = ""
        PeriodEnding        = ""
        NeedsUpdating       = ""
        CSVRawURL           = ""
        CSVPageURL          = ""
        FileNumber          = ""
    }

    for ( $YR = 0; $YR -lt $FilesInfoYamlArray.Count; $YR++) {
        $AV = $FilesInfoYamlArray[ $YR ]
        if (  "" -eq $AV.Values ) {
            Write-Host "Processing : $($AV.Keys[0])"
            if ( $YR -gt 0 ) {
                Write-Host "Completed processing for: ", $FileObj.CsvFileName
                $FileObj
                <#            Start-Sleep 1
            $Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
            if ( $Continue -ne "Yes") { Exit 0 }
#>
                $FilesInfo += $FileObj
                $FileObj = $FilesEmptyPSObject.PSObject.copy()
            }
            else {
                $FileObj = $FilesEmptyPSObject.PSObject.copy()
            }
        }
        else {
            if ( "" -ne $AV.Keys -and "" -ne $AV.Values ) {
                $FileObj.($AV.Keys) = [String]$AV.Values
            }
            else { 
                Write-Host "There is a blank item in FilesInfoYamlArray for item: ", $YR
            }
        }
    }
    $FilesInfo
}


$a = @()
foreach ( $H in $ColumnHeaders.Values ) {
    foreach ( $e in $H ) {
        $a += $e
    }

}
$More = @(
"FIPS USA State County code",
"USA State County",
"Province or State",
"Country or Region",
"Last Updated UTC",
"Last Updated UTC",
"Latitude",
"Longitude",
"Confirmed",
"Deaths",
"Recovered",
"Active",
"Location Name Key",
"Province or State",
"Country or Region",
"Latitude",
"Longitude",
'CSV File Name'
)
foreach ($M in $More) {
    $a += $M
}
$s = $a | sort -Unique
$AllCols = @()
$AllCols += '$AllColumns = [PSCustomObject]@{' -join ""
foreach ( $p in $s ) {
    $AllCols += ("'", $p, "'", ' = $null' -join "" )
}
$AllCols += "}"
$AllCols | Set-Clipboard


$NH = $AllColumns.PSObject.copy()
$NH.FIPS = 99
$NH


$a = @()
foreach ( $H in $Mapping.Keys ) {
    foreach ( $e in $H ) {
        $a += $e
    }

}

$s = $a | sort -Unique
$AllCols = @()
$AllCols += '$AllColumns = [PSCustomObject]@{' -join ""
foreach ( $p in $s ) {
    $AllCols += ("'", $p, "'", ' = $null' -join "" )
}
$AllCols += "}"
$AllCols | Set-Clipboard

$FullDataRow = @()
$AllColumns.PSObject.Properties


Compare-Object -ReferenceObject $AllColumnsPSO.PSObject.Properties.Name -DifferenceObject $MappingPSO.PSObject.Properties.Name | Sort-Object -Property InputObject

Compare-Object -ReferenceObject $AllColumns.PSObject.Properties.Name -DifferenceObject $Mapping.PSObject.Properties.Name

Compare-Object -ReferenceObject $AllColumns.PSObject.Properties -DifferenceObject $Mapping.PSObject.Properties | ft
$'Days Since First Value'     = $null
$'Days Since First Death'     = $null
$'Days Since First Confirmed' = $null
$'Days Since First Active'    = $null
$'Days Since First Recovered' = $null

$TextInfo = (Get-Culture).TextInfo
$TextInfo.ToTitleCase(( "BOLD, BD, FoobR" ) )
