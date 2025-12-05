package br.com.szsolucoes.kiosklauncher

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootCompletedReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            // Iniciar o launcher automaticamente após o boot
            // val launchIntent = Intent(context, br.com.szsolucoes.kiosklauncher.ui.MainActivity::class.java)
            // launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            // context.startActivity(launchIntent)
        }
    }
}
