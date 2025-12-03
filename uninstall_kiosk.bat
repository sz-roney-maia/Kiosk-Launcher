@echo off
echo ============================================
echo     SZ SOLUCOES - KIOSK LAUNCHER REMOVER
echo ============================================
echo.
echo ATENCAO: Este script remove o Kiosk Launcher
echo e todas as restricoes de Device Owner.
echo.

REM Verificar se ADB está instalado
echo [1/4] Verificando ADB...
adb version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERRO: ADB nao encontrado!
    pause
    exit /b 1
)
echo ADB encontrado!

REM Verificar conexão com dispositivo
echo.
echo [2/4] Verificando conexao com dispositivo...
adb devices > temp_devices.txt
findstr /C:"device" temp_devices.txt >nul
if %ERRORLEVEL% neq 0 (
    echo ERRO: Nenhum dispositivo conectado!
    del temp_devices.txt
    pause
    exit /b 1
)
echo Dispositivo conectado!
del temp_devices.txt

REM Remover Device Owner
echo.
echo [3/4] Removendo Device Owner...
adb shell dpm remove-active-admin br.com.szsolucoes.kiosklauncher/.MyDeviceAdminReceiver
if %ERRORLEVEL% neq 0 (
    echo AVISO: Nao foi possivel remover Device Owner
    echo (pode ja ter sido removido)
) else (
    echo Device Owner removido!
)

REM Desinstalar apps
echo.
echo [4/4] Desinstalando apps...
echo Removendo Kiosk Launcher...
adb uninstall br.com.szsolucoes.kiosklauncher
if %ERRORLEVEL% neq 0 (
    echo AVISO: Kiosk Launcher nao estava instalado
) else (
    echo Kiosk Launcher removido!
)

echo Removendo app do totem...
adb uninstall br.com.szsolucoes.totemsaojose
if %ERRORLEVEL% neq 0 (
    echo AVISO: App do totem nao estava instalado
) else (
    echo App do totem removido!
)

REM Limpar arquivos temporários
if exist "device_owner.xml" del device_owner.xml

echo.
echo ============================================
echo         REMOCAO CONCLUIDA!
echo ============================================
echo.
echo O que foi feito:
echo - Device Owner removido
echo - Kiosk Launcher desinstalado
echo - App do totem desinstalado
echo.
echo O dispositivo voltou ao estado normal.
echo.
pause
