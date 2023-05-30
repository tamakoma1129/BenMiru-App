//
//  ContentView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/05/25.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    let realm = try! Realm()
    let hoge = print(Realm.Configuration.defaultConfiguration.fileURL!)
    var body: some View {
        //画面したのメニュー追加
        TabView{
            
            MainView()
                .tabItem{
                    Label("Main", systemImage: "house.fill")
                }
                .environmentObject(GenreColorMap())
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
