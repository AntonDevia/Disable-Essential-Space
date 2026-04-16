[CmdletBinding()]
param()

try {
    chcp 65001 > $null
    [Console]::InputEncoding  = [System.Text.UTF8Encoding]::new($false)
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    $OutputEncoding           = [System.Text.UTF8Encoding]::new($false)
} catch {}

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Write-Title {
    param([string]$Text)
    Clear-Host
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor DarkCyan
    Write-Host ("  " + $Text) -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor DarkCyan
    Write-Host ""
}

function Wait-Space {
    param([string]$Prompt)
    Write-Host $Prompt -ForegroundColor Yellow
    while ($true) {
        $key = [Console]::ReadKey($true)
        if ($key.Key -eq [ConsoleKey]::Spacebar) { break }
    }
}

function Show-ArrowMenu {
    param(
        [string]$Title,
        [string[]]$Options
    )

    $index = 0
    while ($true) {
        Write-Title $Title
        Write-Host "Use Up/Down and Enter" -ForegroundColor DarkGray
        Write-Host ""

        for ($i = 0; $i -lt $Options.Count; $i++) {
            if ($i -eq $index) {
                Write-Host ("  -> " + $Options[$i]) -ForegroundColor Green
            } else {
                Write-Host ("     " + $Options[$i]) -ForegroundColor Gray
            }
        }

        $key = [Console]::ReadKey($true)
        switch ($key.Key) {
            "UpArrow" { $index = ($index - 1 + $Options.Count) % $Options.Count }
            "DownArrow" { $index = ($index + 1) % $Options.Count }
            "Enter" { return $index }
        }
    }
}

function Download-FileWithProgress {
    param(
        [Parameter(Mandatory=$true)][string]$Url,
        [Parameter(Mandatory=$true)][string]$Destination,
        [Parameter(Mandatory=$true)][string]$Activity
    )

    $webClient = New-Object System.Net.WebClient
    $progressHandler = $null
    try {
        $progressHandler = [System.Net.DownloadProgressChangedEventHandler]{
            param($sender, $e)
            $status = "$($e.ProgressPercentage)% ($($e.BytesReceived) / $($e.TotalBytesToReceive) bytes)"
            Write-Progress -Activity $Activity -Status $status -PercentComplete $e.ProgressPercentage
        }
        $webClient.add_DownloadProgressChanged($progressHandler)
        $webClient.DownloadFile($Url, $Destination)
        Write-Progress -Activity $Activity -Completed
    } finally {
        if ($progressHandler) {
            $webClient.remove_DownloadProgressChanged($progressHandler)
        }
        $webClient.Dispose()
    }
}

function Run-AdbQuiet {
    param(
        [Parameter(Mandatory=$true)][string[]]$CmdArgs,
        [Parameter(Mandatory=$true)][string]$ErrorLabel
    )

    $stderr = New-TemporaryFile
    try {
        $null = & $script:AdbPath @CmdArgs 1>$null 2>$stderr
        if ($LASTEXITCODE -ne 0) {
            $message = (Get-Content -LiteralPath $stderr -Raw).Trim()
            if (-not $message) { $message = "Unknown error" }
            throw "$ErrorLabel`n$message"
        }
    } finally {
        Remove-Item -LiteralPath $stderr -Force -ErrorAction SilentlyContinue
    }
}

$langIndex = Show-ArrowMenu -Title "Choose Language / Выберите язык" -Options @("Русский", "English")
$isRu = $langIndex -eq 0

$TXT = if ($isRu) {
    @{
        AppName        = "Essential Space Tool"
        ActionTitle    = "Выберите действие"
        ActionDisable  = "Отключить Essential Space"
        ActionEnable   = "Включить Essential Space"
        Warn           = "Скрипт скачает ADB (platform-tools) с официального сайта Google."
        ContinueSpace  = "Для продолжения нажмите Space..."
        Downloading    = "Скачивание ADB..."
        Preparing      = "Подготовка ADB..."
        Searching      = "Поиск Android-устройства через ADB..."
        NotFoundTitle  = "Устройство не найдено"
        Steps          = @(
            "1) На телефоне откройте: Настройки -> О телефоне.",
            "2) Нажмите 7 раз по пункту 'Номер сборки', чтобы включить режим разработчика.",
            "3) Откройте: Настройки -> Для разработчиков -> Отладка по USB.",
            "4) Подключите телефон по USB и подтвердите доступ к отладке на экране телефона."
        )
        RetrySpace     = "Если включили отладку, нажмите Space для повторной проверки..."
        WorkingDisable = "Отключаем Essential Space..."
        WorkingEnable  = "Включаем Essential Space..."
        SuccessDisable = "Готово. Essential Space на телефоне отключен."
        SuccessEnable  = "Готово. Essential Space на телефоне включен."
        SuccessContinue = "Для продолжения нажмите Space..."
        CleanupTitle   = "Очистка после выполнения"
        CleanupKeep    = "Оставить скрипт и ADB"
        CleanupDelete  = "Удалить скрипт и ADB"
        CleanupDone    = "Файлы удалены. Скрипт завершится через секунду."
        CleanupSkip    = "Файлы оставлены на компьютере."
        CleanupError   = "Не удалось удалить некоторые файлы."
        ExitSpace      = "Для выхода нажмите Space..."
        ErrorTitle     = "Ошибка"
    }
} else {
    @{
        AppName        = "Essential Space Tool"
        ActionTitle    = "Choose Action"
        ActionDisable  = "Disable Essential Space"
        ActionEnable   = "Enable Essential Space"
        Warn           = "This script will download ADB (platform-tools) from the official Google website."
        ContinueSpace  = "Press Space to continue..."
        Downloading    = "Downloading ADB..."
        Preparing      = "Preparing ADB..."
        Searching      = "Searching for Android device via ADB..."
        NotFoundTitle  = "Device Not Found"
        Steps          = @(
            "1) On your phone open: Settings -> About phone.",
            "2) Tap 'Build number' 7 times to enable Developer options.",
            "3) Open: Settings -> Developer options -> USB debugging.",
            "4) Connect phone via USB and allow the debugging prompt on the phone screen."
        )
        RetrySpace     = "If USB debugging is enabled, press Space to retry..."
        WorkingDisable = "Disabling Essential Space..."
        WorkingEnable  = "Enabling Essential Space..."
        SuccessDisable = "Done. Essential Space is disabled on your phone."
        SuccessEnable  = "Done. Essential Space is enabled on your phone."
        SuccessContinue = "Press Space to continue..."
        CleanupTitle   = "Cleanup After Run"
        CleanupKeep    = "Keep script and ADB"
        CleanupDelete  = "Delete script and ADB"
        CleanupDone    = "Files removed. Script will close in one second."
        CleanupSkip    = "Files were kept on this computer."
        CleanupError   = "Could not remove some files."
        ExitSpace      = "Press Space to exit..."
        ErrorTitle     = "Error"
    }
}

$actionIndex = Show-ArrowMenu -Title $TXT.ActionTitle -Options @($TXT.ActionDisable, $TXT.ActionEnable)
$isDisable = $actionIndex -eq 0

Write-Title $TXT.AppName
Write-Host $TXT.Warn -ForegroundColor Yellow
Write-Host ""
Wait-Space $TXT.ContinueSpace

try {
    $baseDir = Join-Path $PSScriptRoot ".adb"
    $platformToolsDir = Join-Path $baseDir "platform-tools"
    $zipPath = Join-Path $baseDir "platform-tools-latest-windows.zip"
    $adbExe = Join-Path $platformToolsDir "adb.exe"

    if (-not (Test-Path -LiteralPath $adbExe)) {
        New-Item -ItemType Directory -Path $baseDir -Force | Out-Null
        Write-Title $TXT.Downloading
        Download-FileWithProgress -Url "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" -Destination $zipPath -Activity $TXT.Downloading

        Write-Title $TXT.Preparing
        if (Test-Path -LiteralPath $platformToolsDir) {
            Remove-Item -LiteralPath $platformToolsDir -Recurse -Force
        }
        Expand-Archive -LiteralPath $zipPath -DestinationPath $baseDir -Force
    }

    if (Test-Path -LiteralPath $zipPath) {
        Remove-Item -LiteralPath $zipPath -Force -ErrorAction SilentlyContinue
    }

    $script:AdbPath = $adbExe

    while ($true) {
        Write-Title $TXT.Searching
        $devicesOutput = & $script:AdbPath devices 2>$null
        $hasDevice = $false
        foreach ($line in $devicesOutput) {
            if ($line -match "^\S+\s+device$") {
                $hasDevice = $true
                break
            }
        }

        if ($hasDevice) { break }

        Write-Title $TXT.NotFoundTitle
        foreach ($step in $TXT.Steps) {
            Write-Host $step -ForegroundColor Yellow
        }
        Write-Host ""
        Wait-Space $TXT.RetrySpace
    }

    if ($isDisable) {
        Write-Title $TXT.WorkingDisable
        Run-AdbQuiet -CmdArgs @("shell", "settings", "put", "secure", "nt_block_essential_key", "1") -ErrorLabel "adb shell settings put secure nt_block_essential_key 1"
        Run-AdbQuiet -CmdArgs @("shell", "pm", "disable-user", "--user", "0", "com.nothing.ntessentialspace") -ErrorLabel "adb shell pm disable-user --user 0 com.nothing.ntessentialspace"
        Run-AdbQuiet -CmdArgs @("shell", "pm", "disable-user", "--user", "0", "com.nothing.ntessentialrecorder") -ErrorLabel "adb shell pm disable-user --user 0 com.nothing.ntessentialrecorder"
    } else {
        Write-Title $TXT.WorkingEnable
        Run-AdbQuiet -CmdArgs @("shell", "settings", "put", "secure", "nt_block_essential_key", "0") -ErrorLabel "adb shell settings put secure nt_block_essential_key 0"
        Run-AdbQuiet -CmdArgs @("shell", "pm", "enable", "--user", "0", "com.nothing.ntessentialspace") -ErrorLabel "adb shell pm enable --user 0 com.nothing.ntessentialspace"
        Run-AdbQuiet -CmdArgs @("shell", "pm", "enable", "--user", "0", "com.nothing.ntessentialrecorder") -ErrorLabel "adb shell pm enable --user 0 com.nothing.ntessentialrecorder"
    }

    Write-Title $TXT.AppName
    if ($isDisable) {
        Write-Host $TXT.SuccessDisable -ForegroundColor Green
    } else {
        Write-Host $TXT.SuccessEnable -ForegroundColor Green
    }
    Write-Host ""
    Wait-Space $TXT.SuccessContinue

    $cleanupChoice = Show-ArrowMenu -Title $TXT.CleanupTitle -Options @($TXT.CleanupKeep, $TXT.CleanupDelete)
    if ($cleanupChoice -eq 1) {
        $cleanupFailed = $false
        try {
            if (Test-Path -LiteralPath $baseDir) {
                Remove-Item -LiteralPath $baseDir -Recurse -Force -ErrorAction Stop
            }
        } catch {
            $cleanupFailed = $true
        }

        $selfPath = $PSCommandPath
        if ($selfPath -and (Test-Path -LiteralPath $selfPath)) {
            $escapedPath = $selfPath.Replace("'", "''")
            Start-Process -FilePath "powershell.exe" -WindowStyle Hidden -ArgumentList @(
                "-NoProfile",
                "-ExecutionPolicy", "Bypass",
                "-Command", "Start-Sleep -Seconds 1; Remove-Item -LiteralPath '$escapedPath' -Force -ErrorAction SilentlyContinue"
            ) | Out-Null
        } else {
            $cleanupFailed = $true
        }

        Write-Host ""
        if ($cleanupFailed) {
            Write-Host $TXT.CleanupError -ForegroundColor Yellow
            Wait-Space $TXT.ExitSpace
        } else {
            Write-Host $TXT.CleanupDone -ForegroundColor Green
            Start-Sleep -Seconds 1
        }
    } else {
        Write-Host $TXT.CleanupSkip -ForegroundColor DarkGray
        Write-Host ""
        Wait-Space $TXT.ExitSpace
    }
} catch {
    Write-Title $TXT.ErrorTitle
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Wait-Space $TXT.ExitSpace
}
