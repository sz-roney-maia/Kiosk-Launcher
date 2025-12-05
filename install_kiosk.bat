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
call gradlew assembleRelease
if %ERRORLEVEL% neq 0 (
    echo ERRO: Falha na compilacao!
    pause
    exit /b 1
)
echo Compilacao concluida!

REM Instalar Kiosk Launcher
echo.
echo [4/8] Instalando Kiosk Launcher...
REM Verificar se existe APK assinado (release assinado)
if exist "app\build\outputs\apk\release\app-release.apk" (
    adb install -t -r app\build\outputs\apk\release\app-release.apk
) else (
    REM Se não existir, tentar o unsigned (pode falhar)
    echo AVISO: APK assinado nao encontrado, tentando unsigned...
    adb install -t -r app\build\outputs\apk\release\app-release-unsigned.apk
)
if %ERRORLEVEL% neq 0 (
    echo ERRO: Falha na instalacao do Kiosk Launcher!
    pause
    exit /b 1
)
echo Kiosk Launcher instalado!

REM Verificar e remover Device Owner existente antes de instalar app do totem
echo.
echo [4.5/8] Verificando e removendo Device Owner existente...
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

echo.
echo [5/8] Instalando app do totem...
echo Removendo app do totem...
adb uninstall br.com.szsolucoes.totemsaojose
if %ERRORLEVEL% neq 0 (
    echo ERRO: Falha na remocao do app do totem!
    pause
    exit /b 1
)
echo App do totem removido!

echo Instalando app do totem...
adb install -r apk\app.apk
if %ERRORLEVEL% neq 0 (
    echo ERRO: Falha na instalacao do app do totem!
    pause
    exit /b 1
)
echo App do totem instalado!

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

REM Configurar como Device Owner
echo.
echo [7/8] Configurando Device Owner...
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
    del device_owner.xml 2>nul
    pause
    exit /b 1
)

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
