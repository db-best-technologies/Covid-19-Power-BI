function Set-DebugOptions {
    param(
        [bool]$WriteFilesToTemp = $true
        , [string]$TempPath = "C:\Temp\Working Files"
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