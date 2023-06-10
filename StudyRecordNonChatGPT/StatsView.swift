//
//  StatsView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/05/25.
//

import SwiftUI
//StatsViewのストラクト

struct StatsView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            TabBarView(selectedTab: $selectedTab)
            TabView(selection: $selectedTab) {
                StackedBarChartView()
                    .tag(0)
                PieChartView()
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
}

struct TabBarView : View {
    @Binding var selectedTab : Int  //どのタブを選んでいるかの変数

    var body: some View {
        HStack {
            Spacer()
            Text("積み上げ棒グラフ")
                .foregroundColor(selectedTab == 0 ? Color.white : Color.gray)
                .padding()
                .background(selectedTab == 0 ? Color.blue : Color.clear)
                .cornerRadius(10)
                .onTapGesture {
                    self.selectedTab = 0
                }
            Spacer()
            Text("円グラフ")
                .foregroundColor(selectedTab == 1 ? Color.white : Color.gray)
                .padding()
                .background(selectedTab == 1 ? Color.blue : Color.clear)
                .cornerRadius(10)
                .onTapGesture {
                    self.selectedTab = 1
                }
            Spacer()
        }
    }
}


