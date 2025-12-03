package br.com.szsolucoes.kiosklauncher.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.RecyclerView.VERTICAL
import br.com.szsolucoes.kiosklauncher.R
import br.com.szsolucoes.kiosklauncher.adapter.AppsAdapter
import br.com.szsolucoes.kiosklauncher.util.AppsUtil

class AppsListFragment : Fragment() {

    private lateinit var recyclerView: RecyclerView

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        val view = inflater.inflate(R.layout.fragment_apps_list, container, false)
        recyclerView = view.findViewById(R.id.recyclerView_apps)
        recyclerView.layoutManager = GridLayoutManager(requireContext(), 4, VERTICAL, false)
        recyclerView.setHasFixedSize(true)
        recyclerView.adapter = AppsAdapter(AppsUtil.getAllApps(requireContext()), requireContext())

        return view
    }

}