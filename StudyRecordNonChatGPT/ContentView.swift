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
    @State private var selectedTab = 0
    @State private var redrawTrigger = UUID()
    @AppStorage("isFirstLaunch") var isFirstLaunch = true
    
    var body: some View {
        if isFirstLaunch {
            IntroView(isShowingIntro: $isFirstLaunch)
        } else {
            TabView(selection: $selectedTab) {
                MainView()
                    .tabItem{
                        Label("ホーム", systemImage: "house.fill")
                    }
                    .environmentObject(GenreColorMap())
                    .tag(0)
                RecordView()
                    .tabItem{
                        Label("記録する", systemImage: "square.and.pencil")
                    }
                    .tag(1)
                EditView()
                    .tabItem {
                        Label("追加/編集", systemImage: "pencil.circle.fill")
                    }
                    .tag(2)
                StatsView()
                    .tabItem {
                        Label("グラフで見る", systemImage: "chart.bar.fill")
                    }
                    .environmentObject(GenreColorMap())
                    .tag(3)
                HelpView()
                    .tabItem{
                        Label("その他",systemImage: "questionmark.circle")
                    }
                    .tag(4)
            }
            
            .onAppear {
                isFirstLaunch = false
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
