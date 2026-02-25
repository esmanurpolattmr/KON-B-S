@echo off
chcp 65001 >nul
title KonBis 2 - Bisiklet Kurye Uygulamasi
color 0A

echo.
echo  ========================================
echo    KONBIS 2 - Bisiklet Kurye Uygulamasi
echo         Tek Tikla Calistirici
echo  ========================================
echo.

:: Proje yolu = bu bat dosyasinin bulundugu klasor (herkes icin otomatik)
set PROJECT_PATH=%~dp0
:: Sondaki \ isaretini kaldir
set PROJECT_PATH=%PROJECT_PATH:~0,-1%

:: ===== FLUTTER YOLUNU OTOMATIK BUL =====
echo  [*] Flutter araniyor...
where flutter >nul 2>nul
if %errorlevel%==0 (
    echo        Flutter PATH'te bulundu!
    set FLUTTER_CMD=flutter
    goto :flutter_found
)

:: Yaygin Flutter konumlari
set FLUTTER_CMD=
for %%P in (
    "%USERPROFILE%\Downloads\flutter\bin\flutter.bat"
    "%USERPROFILE%\flutter\bin\flutter.bat"
    "C:\flutter\bin\flutter.bat"
    "C:\src\flutter\bin\flutter.bat"
    "%LOCALAPPDATA%\flutter\bin\flutter.bat"
    "%USERPROFILE%\Documents\flutter\bin\flutter.bat"
    "%USERPROFILE%\Desktop\flutter\bin\flutter.bat"
) do (
    if exist %%P (
        set FLUTTER_CMD=%%~P
        echo        Flutter bulundu: %%~P
        goto :flutter_found
    )
)

if "%FLUTTER_CMD%"=="" (
    echo.
    echo  [HATA] Flutter bulunamadi!
    echo  Flutter'i PATH'e ekleyin veya yaygin bir konuma kurun.
    echo  (Ornek: C:\flutter veya %USERPROFILE%\flutter)
    echo.
    pause
    exit /b 1
)

:flutter_found

:: ===== EMULATOR YOLUNU OTOMATIK BUL =====
echo  [*] Android Emulator araniyor...
set EMULATOR_CMD=
:: Oncelikle ANDROID_HOME veya ANDROID_SDK_ROOT ortam degiskenlerini kontrol et
if defined ANDROID_HOME (
    if exist "%ANDROID_HOME%\emulator\emulator.exe" (
        set EMULATOR_CMD=%ANDROID_HOME%\emulator\emulator.exe
        echo        Emulator bulundu (ANDROID_HOME): %ANDROID_HOME%\emulator\emulator.exe
        goto :emulator_found
    )
)
if defined ANDROID_SDK_ROOT (
    if exist "%ANDROID_SDK_ROOT%\emulator\emulator.exe" (
        set EMULATOR_CMD=%ANDROID_SDK_ROOT%\emulator\emulator.exe
        echo        Emulator bulundu (ANDROID_SDK_ROOT)
        goto :emulator_found
    )
)

:: Yaygin SDK konumlari
for %%P in (
    "%LOCALAPPDATA%\Android\sdk\emulator\emulator.exe"
    "%USERPROFILE%\AppData\Local\Android\sdk\emulator\emulator.exe"
    "C:\Android\sdk\emulator\emulator.exe"
    "%PROGRAMFILES%\Android\sdk\emulator\emulator.exe"
) do (
    if exist %%P (
        set EMULATOR_CMD=%%~P
        echo        Emulator bulundu: %%~P
        goto :emulator_found
    )
)

if "%EMULATOR_CMD%"=="" (
    echo.
    echo  [HATA] Android Emulator bulunamadi!
    echo  Android SDK'yi kurun veya ANDROID_HOME degiskenini ayarlayin.
    echo.
    pause
    exit /b 1
)

:emulator_found

:: ===== AVD (SANAL CIHAZ) OTOMATIK BUL =====
echo  [*] Sanal cihaz (AVD) araniyor...
:: Ilk mevcut AVD'yi bul
for /f "tokens=*" %%A in ('"%EMULATOR_CMD%" -list-avds 2^>nul') do (
    set AVD_NAME=%%A
    goto :avd_found
)

echo  [HATA] Hic sanal cihaz (AVD) bulunamadi!
echo  Android Studio'dan bir emulator olusturun.
pause
exit /b 1

:avd_found
echo        AVD bulundu: %AVD_NAME%
echo.

:: ===== EMULATOR KONTROL VE BASLATMA =====
echo  [1/3] Emulator kontrol ediliyor...
adb devices 2>nul | findstr "emulator" >nul
if %errorlevel%==0 (
    echo        Emulator zaten calisiyor!
    goto :run_app
)

echo  [2/3] Emulator baslatiliyor: %AVD_NAME%
start "" "%EMULATOR_CMD%" -avd %AVD_NAME%

echo  [3/3] Emulator hazir olana kadar bekleniyor...
echo        (Bu islem 30-60 saniye surebilir)

:wait_loop
timeout /t 5 /nobreak >nul
adb shell getprop sys.boot_completed 2>nul | findstr "1" >nul
if %errorlevel% neq 0 (
    echo        ... hala bekleniyor
    goto :wait_loop
)
echo        Emulator hazir!

:: ===== UYGULAMAYI CALISTIR =====
:run_app
echo.
echo  ========================================
echo    Uygulama baslatiliyor...
echo  ========================================
echo.

cd /d "%PROJECT_PATH%"
call %FLUTTER_CMD% run

echo.
echo  ========================================
echo  Uygulama kapandi. Tekrar baslatmak icin
echo  herhangi bir tusa basin...
echo  ========================================
pause
