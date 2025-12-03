package br.com.szsolucoes.kiosklauncher.util

import android.app.Activity
import android.app.AlertDialog
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.UserManager
import android.text.InputType
import android.text.method.PasswordTransformationMethod
import android.widget.EditText
import android.widget.Toast
import br.com.szsolucoes.kiosklauncher.MyDeviceAdminReceiver
import br.com.szsolucoes.kiosklauncher.ui.MainActivity

class KioskUtil {
    companion object {
        fun startKioskMode(context: Activity) {
            val devicePolicyManager =
                context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
            val myDeviceAdmin = ComponentName(context, MyDeviceAdminReceiver::class.java)

            if (devicePolicyManager.isAdminActive(myDeviceAdmin)) {
                context.startLockTask()
            } else {
                context.startActivity(
                    Intent().setComponent(
                        ComponentName(
                            "com.android.settings", "com.android.settings.DeviceAdminSettings"
                        )
                    )
                )
            }
            if (devicePolicyManager.isDeviceOwnerApp(context.packageName)) {
                val filter = IntentFilter(Intent.ACTION_MAIN)
                filter.addCategory(Intent.CATEGORY_HOME)
                filter.addCategory(Intent.CATEGORY_DEFAULT)
                val activity = ComponentName(context, MainActivity::class.java)
                devicePolicyManager.addPersistentPreferredActivity(myDeviceAdmin, filter, activity)

                //
                val appsWhiteList = arrayOf(
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

                devicePolicyManager.setLockTaskPackages(myDeviceAdmin, appsWhiteList)

                // Restrições adicionais para maior segurança
                devicePolicyManager.addUserRestriction(
                    myDeviceAdmin, UserManager.DISALLOW_SAFE_BOOT
                )
                devicePolicyManager.addUserRestriction(
                    myDeviceAdmin, UserManager.DISALLOW_FACTORY_RESET
                )
                devicePolicyManager.addUserRestriction(
                    myDeviceAdmin, UserManager.DISALLOW_ADD_USER
                )
                devicePolicyManager.addUserRestriction(
                    myDeviceAdmin, UserManager.DISALLOW_MOUNT_PHYSICAL_MEDIA
                )

                devicePolicyManager.addUserRestriction(
                    myDeviceAdmin, UserManager.DISALLOW_UNINSTALL_APPS
                )

                // Desabilitar barra de navegação globalmente via policy_control
                disableNavigationBarGlobally(context)

            } else {
                Toast.makeText(
                    context, "This app is not an owner device", Toast.LENGTH_SHORT
                ).show()
            }
        }

        fun stopKioskMode(context: Activity) {
            val alertDialog = AlertDialog.Builder(context).create()
            alertDialog.setTitle("Digite a senha")

            val input = EditText(context).apply {
                hint = "Senha"
                transformationMethod = PasswordTransformationMethod.getInstance()
                inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_PASSWORD
            }

            alertDialog.setView(input)
            alertDialog.setCanceledOnTouchOutside(true)

            alertDialog.setButton(AlertDialog.BUTTON_POSITIVE, "Confirmar") { _, _ ->
                val password = input.text.toString()
                if (password == "sz221124zs") {

                    val devicePolicyManager =
                    context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                    val myDeviceAdmin = ComponentName(context, MyDeviceAdminReceiver::class.java)
                    if (devicePolicyManager.isAdminActive(myDeviceAdmin)) {
                        context.stopLockTask()
                    }
                    if (devicePolicyManager.isDeviceOwnerApp(context.packageName)) {
                        devicePolicyManager.clearUserRestriction(
                            myDeviceAdmin, UserManager.DISALLOW_UNINSTALL_APPS
                        )
                    }

                }
            }

            alertDialog.setButton(AlertDialog.BUTTON_NEGATIVE, "Cancelar") { _, _ ->
                // Código a ser executado ao rejeitar
            }

            alertDialog.setOnCancelListener {
                // Código a ser executado ao cancelar
            }

            alertDialog.show()
        }

        /**
         * Desabilita a barra de navegação globalmente usando policy_control
         * Isso funciona apenas se o app for Device Owner
         */
        private fun disableNavigationBarGlobally(context: Context) {
            try {
                // Executar comando para desabilitar barra de navegação em todos os apps
                val process = Runtime.getRuntime().exec("settings put global policy_control immersive.navigation=*")
                process.waitFor()
            } catch (e: Exception) {
                e.printStackTrace()
                // Se falhar, tentar método alternativo
                try {
                    Runtime.getRuntime().exec("su -c 'settings put global policy_control immersive.navigation=*'")
                } catch (e2: Exception) {
                    e2.printStackTrace()
                }
            }
        }
    }
}