@echo off
echo ============================================
echo       SZ SOLUCOES - KIOSK CONFIG
echo ============================================
echo.
echo Configuracoes atuais do Kiosk Launcher:
echo.

REM Verificar se ADB está instalado e dispositivo conectado
adb devices > temp_devices.txt 2>nul
findstr /C:"device" temp_devices.txt >nul
if %ERRORLEVEL% neq 0 (
    echo ERRO: Nenhum dispositivo conectado ou ADB nao encontrado!
    del temp_devices.txt 2>nul
    pause
    exit /b 1
)
del temp_devices.txt

echo [INFO] Verificando Device Owner...
echo Testando comando moderno...
adb shell dpm list-owners 2>nul
if %ERRORLEVEL% neq 0 (
    echo Comando 'list-owners' nao disponivel. Testando metodos alternativos...
    echo.
    echo [INFO] Verificando via settings...
    adb shell settings get secure device_owner_package 2>nul
    echo.
    echo [INFO] Verificando via dumpsys...
    adb shell dumpsys device_policy | findstr /C:"DeviceOwner" 2>nul
)

echo.
echo [INFO] Verificando apps instalados...
adb shell pm list packages | findstr "szsolucoes"

echo.
echo [INFO] Verificando restricoes ativas...
echo User Restrictions:
adb shell pm get-max-users
adb shell settings get secure lockscreen.disabled
adb shell settings get global package_verifier_enable

echo.
echo [INFO] Verificando servicos em execucao...
adb shell ps | findstr "kiosklauncher"

echo.
echo ============================================
echo Para alterar configuracoes, edite:
echo - util/KioskUtil.kt (senha, restricoes)
echo - util/AppsUtil.kt (apps permitidos)
echo - AndroidManifest.xml (permissoes)
echo ============================================
echo.
pause
