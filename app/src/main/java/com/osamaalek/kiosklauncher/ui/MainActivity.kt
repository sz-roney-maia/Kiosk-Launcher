package br.com.szsolucoes.kiosklauncher.ui

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import br.com.szsolucoes.kiosklauncher.R
import br.com.szsolucoes.kiosklauncher.util.AppsUtil
import br.com.szsolucoes.kiosklauncher.util.KioskUtil

class MainActivity : AppCompatActivity() {

    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Configurar modo imersivo no próprio app
        enableImmersiveMode()

        // Aguardar um pouco para garantir que o kiosk mode esteja ativo antes de abrir o app
        // handler.postDelayed({
        //     openMainApp()
        // }, 1000) // 1 segundo de delay
    }

    override fun onResume() {
        super.onResume()
        KioskUtil.startKioskMode(this)
        
        // Reaplicar modo imersivo sempre que a activity voltar ao foco
        enableImmersiveMode()

        // Verificar se o app principal está rodando, se não estiver, abri-lo
        // handler.postDelayed({
        //     ensureMainAppIsRunning()
        // }, 2000)
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            enableImmersiveMode()
        }
    }

    private fun enableImmersiveMode() {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        val windowInsetsController = WindowCompat.getInsetsController(window, window.decorView)
        windowInsetsController?.let { controller ->
            controller.hide(WindowInsetsCompat.Type.systemBars())
            controller.systemBarsBehavior = 
                WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        }
    }

    private fun openMainApp() {
        try {
            val mainAppPackage = AppsUtil.getMainAppPackage()
            val launchIntent = packageManager.getLaunchIntentForPackage(mainAppPackage)
            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                startActivity(launchIntent)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun ensureMainAppIsRunning() {
        // Esta função pode ser expandida para verificar se o app principal está rodando
        // e reiniciá-lo se necessário
        openMainApp()
    }

    override fun onBackPressed() {
        if (supportFragmentManager.findFragmentById(R.id.fragmentContainerView) is AppsListFragment) {
            supportFragmentManager.beginTransaction()
                .replace(R.id.fragmentContainerView, HomeFragment()).commit()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacksAndMessages(null)
    }

    private fun requestAccessibilityPermission() {
        val intent = Intent(android.provider.Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }
}