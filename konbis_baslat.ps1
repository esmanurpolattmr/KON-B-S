# KonBis Baslatici - PowerShell Scripti
# Calistirmak icin: PowerShell'de sag tiklayip "PowerShell ile Calistir" sec
# Veya: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

$Host.UI.RawUI.WindowTitle = "KonBis - Baslatici"
Write-Host ""
Write-Host "  ========================================" -ForegroundColor Green
Write-Host "    KONBIS - Bisiklet Kurye Uygulamasi" -ForegroundColor Green
Write-Host "  ========================================" -ForegroundColor Green
Write-Host ""

$ProjectPath = $PSScriptRoot

# Flutter bul
$FlutterCmd = "flutter"
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    $candidates = @(
        "C:\src\flutter\bin\flutter.bat",
        "$env:USERPROFILE\flutter\bin\flutter.bat",
        "C:\flutter\bin\flutter.bat",
        "$env:LOCALAPPDATA\flutter\bin\flutter.bat"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { $FlutterCmd = $c; break }
    }
}
Write-Host "  [OK] Flutter: $FlutterCmd" -ForegroundColor Cyan

# ADB PATH'e ekle
$adbPaths = @(
    "C:\android\Sdk\platform-tools",
    "$env:LOCALAPPDATA\Android\Sdk\platform-tools",
    "$env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools"
)
foreach ($p in $adbPaths) {
    if (Test-Path $p) {
        $env:PATH += ";$p"
        break
    }
}

# Emulator bul
$EmuCmd = $null
$emuCandidates = @(
    "C:\android\Sdk\emulator\emulator.exe",
    "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe",
    "$env:USERPROFILE\AppData\Local\Android\Sdk\emulator\emulator.exe"
)
if ($env:ANDROID_HOME) { $emuCandidates += "$env:ANDROID_HOME\emulator\emulator.exe" }
foreach ($c in $emuCandidates) {
    if (Test-Path $c) { $EmuCmd = $c; break }
}
if (-not $EmuCmd) {
    Write-Host "[HATA] Android Emulator bulunamadi!" -ForegroundColor Red
    Read-Host "Devam etmek icin Enter'a basin"
    exit 1
}
Write-Host "  [OK] Emulator bulundu" -ForegroundColor Cyan

# AVD bul
$AvdName = & $EmuCmd -list-avds 2>$null | Select-Object -First 1
if (-not $AvdName) {
    Write-Host "[HATA] AVD bulunamadi! Android Studio'dan bir emulator olusturun." -ForegroundColor Red
    Read-Host "Enter'a basin"
    exit 1
}
Write-Host "  [OK] AVD: $AvdName" -ForegroundColor Cyan
Write-Host ""

# Emulator acik mi?
$DeviceId = adb devices 2>$null | Select-String "emulator" | ForEach-Object { ($_ -split "\t")[0] } | Select-Object -First 1

if (-not $DeviceId) {
    Write-Host "  Emulator baslatiliyor: $AvdName ..." -ForegroundColor Yellow
    Start-Process -FilePath $EmuCmd -ArgumentList "-avd", $AvdName

    Write-Host "  Emulator acilmasi bekleniyor..." -ForegroundColor Yellow
    $waited = 0
    while ($waited -lt 90) {
        Start-Sleep -Seconds 5
        $waited += 5
        $DeviceId = adb devices 2>$null | Select-String "emulator" | ForEach-Object { ($_ -split "\t")[0] } | Select-Object -First 1
        if ($DeviceId) {
            # Boot tamamlandi mi?
            $bootDone = adb -s $DeviceId shell getprop sys.boot_completed 2>$null
            if ($bootDone -eq "1") { break }
        }
        Write-Host "  ... $waited saniye gecti" -ForegroundColor DarkGray
    }
}
else {
    Write-Host "  Emulator zaten calisiyor: $DeviceId" -ForegroundColor Green
}

# Uygulamayi calistir
Write-Host ""
Write-Host "  ========================================" -ForegroundColor Green
Write-Host "    Uygulama baslatiliyor..." -ForegroundColor Green
Write-Host "  ========================================" -ForegroundColor Green
Write-Host ""

Set-Location $ProjectPath

if ($DeviceId) {
    & $FlutterCmd run -d $DeviceId
}
else {
    & $FlutterCmd run -d android
}

Write-Host ""
Write-Host "  Uygulama kapandi." -ForegroundColor Yellow
Read-Host "Devam etmek icin Enter'a basin"
