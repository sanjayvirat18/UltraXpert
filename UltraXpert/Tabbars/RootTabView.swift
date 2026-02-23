//
//  RootTabView.swift
//  UltraXpert
//
//  Created by sanjaysadha on 27/01/26.
//


import SwiftUI

struct RootTabView: View {

    var body: some View {
        TabView {

            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }

            NavigationStack {
                HelpLineView()
            }
            .tabItem {
                Image(systemName: "phone.fill")
                Text("HelpLine")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Image(systemName: "clock")
                Text("History")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
        }
        .accentColor(.blue)
    }
}
