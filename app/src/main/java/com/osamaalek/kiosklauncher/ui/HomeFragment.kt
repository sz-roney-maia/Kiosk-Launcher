package br.com.szsolucoes.kiosklauncher.ui

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageButton
import androidx.fragment.app.Fragment
import com.google.android.material.floatingactionbutton.FloatingActionButton
import br.com.szsolucoes.kiosklauncher.R
import br.com.szsolucoes.kiosklauncher.util.AppsUtil
import br.com.szsolucoes.kiosklauncher.util.KioskUtil

class HomeFragment : Fragment() {

    private lateinit var fabApps: FloatingActionButton
    private lateinit var imageButtonExit: ImageButton

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View? {
        // Inflate the layout for this fragment
        val v = inflater.inflate(R.layout.fragment_home, container, false)

        fabApps = v.findViewById(R.id.floatingActionButton)
        imageButtonExit = v.findViewById(R.id.imageButton_exit)

        // Botão agora abre diretamente o app da São José
        fabApps.setOnClickListener {
            openMainApp()
        }

        imageButtonExit.setOnClickListener {
            KioskUtil.stopKioskMode(requireActivity())
        }

        return v
    }

    private fun openMainApp() {
        try {
            val mainAppPackage = AppsUtil.getMainAppPackage()
            val launchIntent = requireContext().packageManager.getLaunchIntentForPackage(mainAppPackage)
            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                startActivity(launchIntent)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

}