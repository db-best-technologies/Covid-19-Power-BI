# Support files for processing Covid-19 data
$GLOBAL:PROMPT_COUNT = 0
$GLOBAL:TIMER = [Diagnostics.Stopwatch]::StartNew()
$GLOBAL:TIMER_LAST_SEC = $GLOBAL:TIMER.Elapsed.Seconds
 
function prompt {
    ${GLOBAL:PROMPT_COUNT}++
    $GLOBAL:TIMER_LAST_SEC = $GLOBAL:TIMER.Elapsed.Seconds
    $null = $GLOBAL:TIMER.Restart()
    $RootDir = Get-location | Split-Path -Leaf
    Write-Host ( "$($RootDir) (" + $("000000000${GLOBAL:PROMPT_COUNT}>").tostring().substring($("000000000${GLOBAL:PROMPT_COUNT}").length-4 , 4) + " $($GLOBAL:TIMER_LAST_SEC)s) > ") -foregroundcolor white -nonewline
    
return " "
}


$COVID_19_Project_Path = "C:\Users\Bill\OneDrive\Bill\Documents\My GitLab\Covid-19-Power-BI"
Set-Location $COVID_19_Project_Path
$RootDir = Split-Path $COVID_19_Project_Path -Leaf

function Set-DebugOptions {
    param(
        [bool]$WriteFilesToTemp = $true
        , [string]$TempPath = "C:\Temp\Covid-Temp-Files"
        , [bool]$DeleteTempFilesAtStart = $true
        , [bool]$UpdateLocalFiles = $true
        , [bool]$AppendDebugData = $false
        , [bool]$Workaround = $false
        , [bool]$ForceDownload = $true
        , [bool]$LoadFromWorkingFiles = $false
        , [bool]$LoadNewUSFiles = $true
        , [bool]$LoadKeyFiles = $true
    )
    
    $DebugOptions = @{
        WriteFilesToTemp       = $WriteFilesToTemp
        TempPath               = $TempPath
        DeleteTempFilesAtStart = $DeleteTempFilesAtStart
        UpdateLocalFiles       = $UpdateLocalFiles
        LastRun                = Get-Date
        AppendDebugData        = $AppendDebugData
        Workaround             = $Workaround
        ForceDownload          = $ForceDownload
        LoadFromWorkingFiles   = $LoadFromWorkingFiles
        LoadNewUSFiles         = $LoadNewUSFiles
        LoadKeyFiles           = $LoadKeyFiles
    }
    $COVID_19_Project_Path = "C:\Users\Bill\OneDrive\Bill\Documents\My GitLab\Covid-19-Power-BI" 
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
                $DebugOptions.WriteFilesToTemp = $false
                Start-Sleep 1
                $Continue = Read-Host "Do you want to continue? 'Yes' or 'No'"
                if ( $Continue -ne "Yes") { Exit 0 }
            }
        }
    }
    if ( $DebugOptions.ForceDownload) {
        $files = Get-ChildItem -Path ($COVID_19_Project_Path, "Working Files" -join "\")
    }
    if ( $false <# -or $DebugOptions.DeleteTempFilesAtStart #> ) {
        $Files = Get-ChildItem $DebugOptions.TempPath -Recurse
        $Files | Remove-Item
        if ($DebugOptions.WriteFilesToTemp) {
            $Files | Add-Member -MemberType NoteProperty -Name DebugOptions -Value $DebugOptions
            $hashParams = @{
                LiteralPath = ($DebugOptions.TempPath, "\Removed-Files.json" -join "")
                Append      = $DebugOptions.AppendDebugData
            }
            $Files | ConvertTo-Json | Out-File @hashParams
            $hashParams.LiteralPath = ($DebugOptions.TempPath, "\Last-Debug-Options.json" -join "")
            $DebugOptions | ConvertTo-Json | Out-File @hashParams
        }
    }
    return $DebugOptions
}

function Get-WeekNumber([datetime]$DateTime = (Get-Date)) {
    $cultureInfo = [System.Globalization.CultureInfo]::CurrentCulture
    $cultureInfo.Calendar.GetWeekOfYear($DateTime,$cultureInfo.DateTimeFormat.CalendarWeekRule,$cultureInfo.DateTimeFormat.FirstDayOfWeek)
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

function Get-BuildCombinedKey {
    [OutputType([string])]
    param (
        [Parameter(Mandatory=$false,
        ValueFromPipeline=$true)]
        [String[]]
        $BuildCombinedKey
    )
    [string]$ReturnString = ""
    foreach ($Value in $BuildCombinedKey) {
        if ( $Value.Length -gt 0 ) {
            if ( $ReturnString.Length -gt 0 ) {
                $ReturnString = $ReturnString , ", ", $Value -join ""
            } else {
                $ReturnString = $Value
            }
        }
    }
    $ReturnString
    
}

Write-Host "Profile loaded", (Get-date)
