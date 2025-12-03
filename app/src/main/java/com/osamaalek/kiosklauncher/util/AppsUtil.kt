package br.com.szsolucoes.kiosklauncher.util

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import br.com.szsolucoes.kiosklauncher.model.AppInfo


class AppsUtil {

    companion object {

        // Lista de apps permitidos no modo kiosk
        private val allowedApps = arrayOf(
            "br.com.szsolucoes.kiosklauncher",
            "br.com.szsolucoes.totemsaojose",
            "com.epson.epos2_printer",
            "com.sunmi.remotecontrol.pro",
            "br.com.paygo",
            "br.com.paygo.pdvs",
            "br.com.setis.clientepaygoweb.cert",
            "com.android.systemui",
            "com.android.inputmethod.latin",
            "com.google.android.inputmethod.latin"
        )

        fun getAllApps(context: Context): List<AppInfo> {
            val packageManager: PackageManager = context.packageManager
            val appsList = ArrayList<AppInfo>()
            val i = Intent(Intent.ACTION_MAIN, null)
            i.addCategory(Intent.CATEGORY_LAUNCHER)
            val allApps = packageManager.queryIntentActivities(i, 0)
            for (ri in allApps) {
                val packageName = ri.activityInfo.packageName
                // Filtrar apenas apps da whitelist
                if (allowedApps.contains(packageName)) {
                    val app = AppInfo(
                        ri.loadLabel(packageManager),
                        packageName,
                        ri.activityInfo.loadIcon(packageManager)
                    )
                    appsList.add(app)
                }
            }
            return appsList
        }

        // Função para verificar se um app está na whitelist
        fun isAppAllowed(packageName: String): Boolean {
            return allowedApps.contains(packageName)
        }

        // Função para obter o package name do app principal (São José)
        fun getMainAppPackage(): String {
            return "br.com.szsolucoes.totemsaojose"
        }

    }
}