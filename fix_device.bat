@echo off
echo ============================================
echo      SZ SOLUCOES - DEVICE FIXER
echo ============================================
echo.
echo Este script diagnostica e corrige problemas
echo comuns na configuracao do Kiosk Launcher.
echo.

REM Verificar ADB e dispositivo
adb devices > temp_devices.txt 2>nul
findstr /C:"device" temp_devices.txt >nul
if %ERRORLEVEL% neq 0 (
    echo ERRO: Nenhum dispositivo conectado!
    del temp_devices.txt 2>nul
    pause
    exit /b 1
)
del temp_devices.txt

echo [1/4] DIAGNOSTICO DO DISPOSITIVO
echo ================================
echo.

echo Versao do Android:
adb shell getprop ro.build.version.release
echo.

echo Usuarios configurados:
adb shell pm list users
echo.

echo Device Owner atual:
adb shell settings get secure device_owner_package 2>nul
if %ERRORLEVEL% neq 0 (
    echo Comando nao disponivel nesta versao
)
echo.

echo [2/4] VERIFICANDO CONTAS GOOGLE
echo ===============================
echo.

adb shell dumpsys account | findstr "google" > temp_accounts.txt
findstr /C:"@" temp_accounts.txt >nul
if %ERRORLEVEL% equ 0 (
    echo ❌ CONTAS GOOGLE ENCONTRADAS!
    echo Isso impede a configuracao do Device Owner.
    echo.
    type temp_accounts.txt
    echo.
    echo 🔧 SOLUCAO: Remova as contas via interface
    echo Configuracoes > Contas > Google > Remover conta
) else (
    echo ✅ Nenhuma conta Google encontrada.
)
del temp_accounts.txt
echo.

echo [3/4] VERIFICANDO APPS SZ
echo ========================
echo.

echo Apps SZ instalados:
adb shell pm list packages | findstr "szsolucoes"
echo.

echo [4/4] ACOES RECOMENDADAS
echo =======================
echo.

REM Verificar se há problemas
set HAS_ISSUES=0

adb shell dumpsys account | findstr "@" >nul 2>nul
if %ERRORLEVEL% equ 0 set HAS_ISSUES=1

adb shell settings get secure device_owner_package | findstr "szsolucoes" >nul 2>nul
if %ERRORLEVEL% neq 0 set HAS_ISSUES=1

if %HAS_ISSUES%==1 (
    echo ❌ PROBLEMAS DETECTADOS!
    echo.
    echo Para corrigir automaticamente, execute:
    echo 1. Remova contas Google manualmente
    echo 2. Execute: install_kiosk.bat
    echo.
    echo Ou para limpeza completa:
    echo uninstall_kiosk.bat
    echo.
) else (
    echo ✅ DISPOSITIVO PRONTO!
    echo Pode executar: install_kiosk.bat
)

echo.
echo ============================================
pause
