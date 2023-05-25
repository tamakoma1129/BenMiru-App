//
//  ContentView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/05/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        //画面したのメニュー追加
        TabView{
            MainView()
                .tabItem{
                    Label("Main", systemImage: "house.fill")
                }
            RecordView()
                .tabItem{
                    Label("Record", systemImage: "square.and.pencil")
                }
            EditView()
                .tabItem {
                    Label("Edit", systemImage: "pencil.circle.fill")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
