[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$mainScriptUrl = "https://github.com/AntonDevia/Disable-Essential-Space/releases/download/main/essential-space.ps1"
$tempScriptPath = Join-Path $env:TEMP "essential-space.ps1"

$wc = New-Object System.Net.WebClient
$bytes = $wc.DownloadData($mainScriptUrl)
$text = [System.Text.Encoding]::UTF8.GetString($bytes).TrimStart([char]0xFEFF)

[System.IO.File]::WriteAllText($tempScriptPath, $text, [System.Text.UTF8Encoding]::new($true))
powershell -NoProfile -ExecutionPolicy Bypass -File $tempScriptPath