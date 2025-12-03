# SZ Soluções - Kiosk Launcher

Kiosk Launcher personalizado para totens PayGo. Transforma dispositivos Android em quiosques dedicados que abrem automaticamente o app da São José e impedem acesso a outras funcionalidades.

## 🚀 Funcionalidades

- **Auto-início automático**: Abre o app da São José assim que o dispositivo liga
- **Modo kiosk completo**: Remove barras de sistema e bloqueia navegação
- **Whitelist restritiva**: Apenas o launcher e o app da São José podem executar
- **Controle de saída**: Senha específica para sair do modo kiosk
- **Compatibilidade**: Android 5.0+ (API 21+)
- **Segurança reforçada**: Bloqueia reset, safe boot e outras funções críticas

## 📦 Instalação

### Pré-requisitos:
- Dispositivo Android com modo desenvolvedor habilitado
- USB Debugging ativado
- ADB (Android Debug Bridge) instalado
- APK do app da São José (`totem-sao-jose.apk`) na raiz do projeto
- **IMPORTANTE:** Remova todas as contas Google antes da instalação

### ⚠️ Problema Conhecido - Contas Google

**Se aparecer o erro "Not allowed to set the device owner because there are already some accounts on the device":**

1. **Remova todas as contas Google:**
   - Vá em: `Configurações > Contas > Google`
   - Toque no menu (⋮) > `Remover conta`
   - Confirme a remoção

2. **Ou faça Factory Reset:**
   - `Configurações > Backup e reset > Redefinir dados`
   - ⚠️ **Isso apaga todos os dados do dispositivo**

### Diagnóstico (Antes da Instalação):
1. Execute: `fix_device.bat`
2. O script identificará problemas automaticamente
3. Siga as orientações para corrigir

### Instalação Automática:
1. Conecte o totem ao computador via USB
2. Execute: `install_kiosk.bat`
3. O script detectará automaticamente o problema e orientará a solução

### Instalação Manual:
```bash
# 1. Verificar contas Google (IMPORTANTE!)
adb shell dumpsys account | findstr google

# 2. Se houver contas, remova-as via interface ou faça reset

# 3. Compilar o projeto
gradlew assembleDebug

# 4. Instalar APKs
adb install -r app\build\outputs\apk\debug\app-debug.apk
adb install -r totem-sao-jose.apk

# 5. Configurar Device Owner
adb shell dpm set-device-owner br.com.szsolucoes.kiosklauncher/.MyDeviceAdminReceiver

# 6. Reinicializar
adb reboot
```

### 📱 Compatibilidade por Versão Android:

- **Android 5.0-7.x:** Use comandos alternativos (settings get secure)
- **Android 8.0+:** Comando `dpm list-owners` disponível
- **Android 10+:** Restrições adicionais de segurança

## 🔧 Como Usar

### Após a instalação:
- O dispositivo reinicializará automaticamente
- O Kiosk Launcher abrirá primeiro
- O app da São José abrirá automaticamente em 1-2 segundos
- As barras do sistema estarão ocultas

### Saindo do modo kiosk:
1. Toque no **botão vermelho** (canto superior direito)
2. Digite a senha: `sz221124zs`
3. Toque em "Confirmar"

### Removendo o kiosk:
Execute: `uninstall_kiosk.bat`

## ⚙️ Configuração

### Apps permitidos:
- `br.com.szsolucoes.kiosklauncher` (este launcher)
- `br.com.szsolucoes.totemsaojose` (app principal)

### Personalização:
Para alterar a senha ou apps permitidos, edite:
- `util/KioskUtil.kt` - Senha de saída
- `util/AppsUtil.kt` - Lista de apps permitidos

## Article

If you want to learn more about the technical details and the design process of this project, you can read my article on Medium:

https://medium.com/@osamaalek/how-to-build-a-kiosk-launcher-for-android-part-1-beb54476da56
https://medium.com/@osamaalek/how-to-build-a-kiosk-launcher-for-android-part-2-9a529f503c11

## License

Kiosk Launcher is licensed under the Apache License 2.0. See [LICENSE](https://github.com/osamaalek/Kiosk-Launcher/blob/master/LICENSE) for more details.

## Contact

If you have any questions, feedback, or suggestions, feel free to contact me at osamaalek@gmail.com or open an issue on GitHub.
