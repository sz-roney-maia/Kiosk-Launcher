@echo off
echo ============================================
echo     SZ SOLUCOES - KIOSK LAUNCHER INSTALLER
echo ============================================
echo.

REM Verificar se ADB está instalado
echo [1/8] Verificando ADB...
adb version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERRO: ADB nao encontrado!
    echo Instale o Android SDK Platform Tools:
    echo https://developer.android.com/studio/releases/platform-tools
    pause
    exit /b 1
)
echo ADB encontrado!

REM Verificar conexão com dispositivo
echo.
echo [2/8] Verificando conexao com dispositivo...
adb devices > temp_devices.txt
findstr /C:"device" temp_devices.txt >nul
if %ERRORLEVEL% neq 0 (
    echo ERRO: Nenhum dispositivo conectado!
    echo - Certifique-se de que o USB Debugging esta habilitado
    echo - Aceite a autorizacao de depuracao no dispositivo
    del temp_devices.txt
    pause
    exit /b 1
)
echo Dispositivo conectado!
del temp_devices.txt

REM Compilar APK
echo.
echo [3/8] Compilando Kiosk Launcher...
call gradlew assembleDebug
if %ERRORLEVEL% neq 0 (
    echo ERRO: Falha na compilacao!
    pause
    exit /b 1
)
echo Compilacao concluida!

REM Instalar Kiosk Launcher
echo.
echo [4/8] Instalando Kiosk Launcher...
adb install -r app\build\outputs\apk\debug\app-debug.apk
if %ERRORLEVEL% neq 0 (
    echo ERRO: Falha na instalacao do Kiosk Launcher!
    pause
    exit /b 1
)
echo Kiosk Launcher instalado!

REM Verificar se APK do totem existe
echo.
echo [5/8] Procurando APK do totem...
if not exist "totem-sao-jose.apk" (
    echo AVISO: APK do totem nao encontrado (totem-sao-jose.apk)
    echo O script continuara sem instalar o app do totem.
    echo Instale manualmente depois: adb install -r totem-sao-jose.apk
    set SKIP_TOTEM=1
) else (
    set SKIP_TOTEM=0
)

if %SKIP_TOTEM%==0 (
    echo Instalando app do totem...
    adb install -r totem-sao-jose.apk
    if %ERRORLEVEL% neq 0 (
        echo ERRO: Falha na instalacao do app do totem!
        pause
        exit /b 1
    )
    echo App do totem instalado!
)

REM Criar arquivo device_owner.xml
echo.
echo [6/8] Criando arquivo de configuracao...
echo ^<?xml version='1.0' encoding='utf-8' standalone='yes' ?^>> device_owner.xml
echo ^<device-owner package="br.com.szsolucoes.kiosklauncher" /^>> device_owner.xml

REM Enviar arquivo para dispositivo
echo Enviando configuracao para dispositivo...
adb push device_owner.xml /data/local/tmp/
if %ERRORLEVEL% neq 0 (
    echo ERRO: Falha ao enviar arquivo de configuracao!
    del device_owner.xml
    pause
    exit /b 1
)

REM Verificar versão do Android
echo Verificando versao do Android...
adb shell getprop ro.build.version.release > temp_version.txt
set /p ANDROID_VERSION=<temp_version.txt
del temp_version.txt
echo Versao detectada: %ANDROID_VERSION%

REM Verificar contas Google (problema especifico do Android)
echo.
echo [6.5/8] Verificando contas configuradas...
adb shell dumpsys account | findstr "google" > temp_accounts.txt
findstr /C:"@" temp_accounts.txt >nul
if %ERRORLEVEL% equ 0 (
    echo AVISO: Conta(s) Google encontrada(s)!
    echo Isso impede a configuracao do Device Owner.
    echo.
    echo CONTAS ENCONTRADAS:
    type temp_accounts.txt
    echo.
    echo SOLUCOES:
    echo 1. Remova as contas Google via Configuracoes
    echo 2. Ou faca Factory Reset do dispositivo
    echo.
    echo Deseja continuar mesmo assim? (pode falhar)
    pause
)
del temp_accounts.txt

REM Verificar Device Owner existente (compatível com múltiplas versões)
echo.
echo [7/8] Verificando Device Owner existente...
REM Tentar comando moderno primeiro
adb shell dpm list-owners 2>nul > temp_owners.txt
if %ERRORLEVEL% neq 0 (
    REM Android 7.x ou inferior - usar método alternativo
    adb shell settings get secure device_owner_package 2>nul > temp_owners.txt
)

REM Verificar se encontrou Device Owner
findstr /C:"br.com.szsolucoes.kiosklauncher" temp_owners.txt >nul
if %ERRORLEVEL% equ 0 (
    echo AVISO: Este app ja e Device Owner!
    goto :skip_owner_setup
)

findstr /C:"device-owner" temp_owners.txt >nul
if %ERRORLEVEL% equ 0 (
    echo AVISO: Outro Device Owner encontrado!
    echo Tentando remover...
    REM Tentar remover owner atual (se existir)
    adb shell dpm remove-active-admin br.com.szsolucoes.kiosklauncher/.MyDeviceAdminReceiver 2>nul
)

REM Limpar dados do app (se existir)
echo Limpando dados do app anterior...
adb shell pm clear br.com.szsolucoes.kiosklauncher >nul 2>&1

REM Configurar como Device Owner
echo Configurando como Device Owner...
adb shell dpm set-device-owner br.com.szsolucoes.kiosklauncher/.MyDeviceAdminReceiver
if %ERRORLEVEL% neq 0 (
    echo ERRO: Falha ao configurar Device Owner!
    echo.
    echo POSSIVEIS CAUSAS:
    echo 1. Contas Google configuradas (mais comum)
    echo 2. Outro Device Owner ativo
    echo 3. Usuario nao-administrador
    echo.
    echo SOLUCOES RECOMENDADAS:
    echo 1. REMOVA TODAS AS CONTAS GOOGLE do dispositivo
    echo 2. Va em: Configuracoes > Contas > Google > REMOVER CONTA
    echo 3. Ou faca: Configuracoes > Backup e reset > Redefinir dados
    echo.
    echo Comandos para verificar:
    echo adb shell dumpsys account ^| findstr google
    echo adb shell settings get secure device_owner_package
    echo.
    del device_owner.xml temp_owners.txt 2>nul
    pause
    exit /b 1
)

:skip_owner_setup
echo Device Owner configurado!
echo Device Owner configurado!

REM Limpar arquivo temporario
del device_owner.xml

REM Reinicializar dispositivo
echo.
echo [8/8] Reinicializando dispositivo...
echo O dispositivo sera reinicializado.
echo Aguarde alguns segundos apos a reinicializacao...
adb reboot

echo.
echo ============================================
echo         INSTALACAO CONCLUIDA!
echo ============================================
echo.
echo O que aconteceu:
echo - Kiosk Launcher foi instalado e configurado
if %SKIP_TOTEM%==0 (
    echo - App do totem foi instalado
) else (
    echo - AVISO: App do totem NAO foi instalado (arquivo nao encontrado)
)
echo - Dispositivo foi configurado como Device Owner
echo - Sistema reinicializado
echo.
echo Proximos passos:
echo 1. Aguarde o dispositivo reinicializar completamente
echo 2. O Kiosk Launcher deve abrir automaticamente
if %SKIP_TOTEM%==0 (
    echo 3. O app do totem deve abrir em seguida
) else (
    echo 3. Instale o APK do totem manualmente
)
echo 4. Teste as restricoes do kiosk mode
echo.
echo Para sair do modo kiosk:
echo - Toque no botao vermelho (canto superior direito)
echo - Digite a senha: sz221124zs
echo.
pause
