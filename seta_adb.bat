@echo off
setlocal ENABLEDELAYEDEXPANSION

REM =========================
REM CONFIGURAÇÕES FIXAS
REM =========================
set "SDK_PATH=C:\android\SDK"
set "ADB_PATH=%SDK_PATH%\platform-tools\adb.exe"
set "EMU_PATH=%SDK_PATH%\emulator\emulator.exe"
set "AVD_NAME=Pixel_3_API_36"

REM =========================
REM AJUSTE DAS VARIÁVEIS
REM =========================
set "ANDROID_HOME=%SDK_PATH%"
set "ANDROID_SDK_ROOT=%SDK_PATH%"
set "PATH=%SDK_PATH%\platform-tools;%SDK_PATH%\emulator;%PATH%"

echo.
echo === Verificando ferramentas ===
if not exist "%ADB_PATH%" (
  echo [ERRO] Nao encontrei adb em: %ADB_PATH%
  pause
  exit /b 1
)

if not exist "%EMU_PATH%" (
  echo [ERRO] Nao encontrei emulator.exe em: %EMU_PATH%
  pause
  exit /b 1
)

echo OK: adb localizado em %ADB_PATH%
echo OK: emulator localizado em %EMU_PATH%

REM =========================
REM CHECAR DISPOSITIVOS
REM =========================
echo.
echo === Checando dispositivos conectados ===
for /f "skip=1 tokens=1,2" %%A in ('adb devices') do (
  if "%%B"=="device" set "DEVICE_FOUND=1"
)

if not defined DEVICE_FOUND (
  echo Nenhum dispositivo ativo. Iniciando emulador: %AVD_NAME%
  start "" emulator -avd "%AVD_NAME%" -netdelay none -netspeed full
) else (
  echo Dispositivo/emulador ja detectado.
)

REM =========================
REM AGUARDAR BOOT
REM =========================
echo.
echo === Aguardando boot completo do emulador ===
:wait_for_device
adb wait-for-device 1>nul 2>nul

set "BOOT="
for /f "delims=" %%G in ('adb -e shell getprop sys.boot_completed 2^>nul') do set "BOOT=%%G"
if not "%BOOT%"=="1" (
  echo Aguardando boot...
  timeout /t 3 >nul
  goto :wait_for_device
)

echo Emulador %AVD_NAME% pronto!

REM =========================
REM INICIAR EXPO
REM =========================
echo.
echo === Iniciando Expo no Android ===
npx expo start --android

endlocal
