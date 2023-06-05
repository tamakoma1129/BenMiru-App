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
                    Label("ホーム", systemImage: "house.fill")
                }
                .environmentObject(GenreColorMap())
            RecordView()
                .tabItem{
                    Label("記録する", systemImage: "square.and.pencil")
                }
            EditView()
                .tabItem {
                    Label("追加/編集", systemImage: "pencil.circle.fill")
                }

            ChartTest()
                .tabItem {
                    Label("グラフで見る", systemImage: "chart.bar.fill")
                }
                .environmentObject(GenreColorMap())
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
