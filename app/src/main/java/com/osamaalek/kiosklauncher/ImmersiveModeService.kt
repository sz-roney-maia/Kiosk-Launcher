package br.com.szsolucoes.kiosklauncher

import android.accessibilityservice.AccessibilityService
import android.app.Activity
import android.os.Build
import android.view.accessibility.AccessibilityEvent
import android.view.WindowManager
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat

class ImmersiveModeService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Monitorar mudanças de janela
        if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            applyImmersiveModeToCurrentWindow()
        }
    }

    override fun onInterrupt() {}

    private fun applyImmersiveModeToCurrentWindow() {
        try {
            // Usar reflection para obter a Activity atual através do WindowManager
            val windowManager = getSystemService(WINDOW_SERVICE) as? WindowManager ?: return
            
            // Tentar aplicar modo imersivo através de comandos do sistema
            // Para Android 11+ (API 30+), podemos usar policy_control via Device Owner
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                // Usar WindowManager para aplicar em todas as janelas
                applyImmersiveModeViaSystem()
            } else {
                // Para versões anteriores, usar systemUiVisibility via reflection
                applyImmersiveModeViaReflection()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun applyImmersiveModeViaSystem() {
        try {
            // Tentar aplicar via Device Policy Manager se disponível
            val devicePolicyManager = getSystemService(android.app.admin.DevicePolicyManager::class.java)
            if (devicePolicyManager != null && devicePolicyManager.isDeviceOwnerApp(packageName)) {
                // Executar comando para desabilitar barra de navegação globalmente
                Runtime.getRuntime().exec("settings put global policy_control immersive.navigation=*")
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun applyImmersiveModeViaReflection() {
        try {
            // Tentar aplicar via reflection nas janelas ativas
            val windowManager = getSystemService(WINDOW_SERVICE) as? WindowManager ?: return
            
            // Obter todas as janelas abertas (requer permissão SYSTEM_ALERT_WINDOW)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val windows = windowManager.javaClass.getMethod("getWindows").invoke(windowManager) as? List<*>
                windows?.forEach { window ->
                    try {
                        window?.let { win ->
                            val decorView = win.javaClass.getMethod("getDecorView").invoke(win) as? android.view.View
                            decorView?.let { view ->
                                view.post {
                                    @Suppress("DEPRECATION")
                                    view.systemUiVisibility = (
                                        android.view.View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                                        or android.view.View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                                        or android.view.View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                                        or android.view.View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                                        or android.view.View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                                        or android.view.View.SYSTEM_UI_FLAG_FULLSCREEN
                                    )
                                }
                            }
                        }
                    } catch (e: Exception) {
                        // Ignorar erros de reflection
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
