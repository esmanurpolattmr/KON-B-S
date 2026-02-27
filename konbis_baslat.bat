@echo off
chcp 65001 >nul 2>nul
title KonBis - Baslatici

echo.
echo  ================================
echo    KONBIS - Bisiklet Kurye Uyg.
echo  ================================
echo.

:: --- SABIT YOLLAR (senin bilgisayarina gore) ---
set FLUTTER_CMD=flutter
set EMU_EXE=C:\android\Sdk\emulator\emulator.exe
set ADB_EXE=C:\android\Sdk\platform-tools\adb.exe
set PROJECT=%~dp0
if "%PROJECT:~-1%"=="\" set PROJECT=%PROJECT:~0,-1%

:: ADB'yi PATH'e ekle
set PATH=%PATH%;C:\android\Sdk\platform-tools

:: Emulator var mi?
if not exist "%EMU_EXE%" (
    echo [HATA] Emulator bulunamadi: %EMU_EXE%
    pause & exit /b 1
)

:: AVD listesinden ilki al
set AVD=
for /f "tokens=*" %%A in ('"%EMU_EXE%" -list-avds 2^>nul') do (
    set AVD=%%A
    goto :avd_ok
)
echo [HATA] AVD bulunamadi!
pause & exit /b 1

:avd_ok
echo  AVD: %AVD%

:: Emulator acik mi?
set DEV=
for /f "tokens=1" %%D in ('"%ADB_EXE%" devices 2^>nul ^| findstr /i "emulator"') do set DEV=%%D

if "%DEV%"=="" (
    echo  Emulator baslatiliyor: %AVD%
    start "" "%EMU_EXE%" -avd %AVD%
    echo  45 saniye bekleniyor...
    timeout /t 45 /nobreak >nul
    for /f "tokens=1" %%D in ('"%ADB_EXE%" devices 2^>nul ^| findstr /i "emulator"') do set DEV=%%D
) else (
    echo  Emulator calisiyor: %DEV%
)

:: Uygulamayi calistir
echo.
echo  Paketler guncelleniyor...
%FLUTTER_CMD% pub get

echo.
echo  Flutter baslatiliyor...
echo.
cd /d "%PROJECT%"

if "%DEV%"=="" (
    %FLUTTER_CMD% run -d android
) else (
    %FLUTTER_CMD% run -d %DEV%
)

echo.
pause