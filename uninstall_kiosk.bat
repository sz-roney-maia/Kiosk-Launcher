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

REM Verificar e remover Device Owner existente antes de desinstalar apps
echo.
echo [3/4] Verificando e removendo Device Owner existente...
REM Usar dumpsys device_policy para descobrir os owners
adb shell dumpsys device_policy > temp_owners.txt 2>nul

REM Verificar se encontrou Device Owner
REM Procurar por "Device Owner:" (com espaço e dois pontos) no output do dumpsys
findstr /C:"Device Owner:" temp_owners.txt >nul
if %ERRORLEVEL% equ 0 (
    echo Device Owner encontrado! Removendo...
    REM Para Device Owner, a melhor forma e desinstalar o app (remove automaticamente o Device Owner)
    REM Tentar remover admin apenas se nao for Device Owner (para evitar erro de seguranca)
    echo Desinstalando app para remover Device Owner...
    adb uninstall br.com.szsolucoes.kiosklauncher >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        echo App desinstalado e Device Owner removido!
        set KIOSK_REMOVED=1
    ) else (
        echo AVISO: Nao foi possivel desinstalar o app (pode nao estar instalado)
    )
) else (
    echo Nenhum Device Owner encontrado.
    REM Se nao for Device Owner, tentar remover apenas o Device Admin
    echo Verificando se existe Device Admin ativo...
    adb shell dpm remove-active-admin br.com.szsolucoes.kiosklauncher/.MyDeviceAdminReceiver >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        echo Device Admin removido!
    ) else (
        echo Nenhum Device Admin ativo encontrado.
    )
)
del temp_owners.txt 2>nul

REM Desinstalar apps (se ainda não foi desinstalado)
echo.
echo [4/4] Desinstalando apps...
if not defined KIOSK_REMOVED (
    echo Removendo Kiosk Launcher...
    adb uninstall br.com.szsolucoes.kiosklauncher
    if %ERRORLEVEL% neq 0 (
        echo AVISO: Kiosk Launcher nao estava instalado
    ) else (
        echo Kiosk Launcher removido!
    )
) else (
    echo Kiosk Launcher ja foi removido anteriormente.
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
