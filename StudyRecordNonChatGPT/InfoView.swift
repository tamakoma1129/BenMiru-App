//
//  InfoView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/06/18.
//

import SwiftUI

//右上の情報ボタンの遷移先を作るView

struct IntroView: View {
    @Binding var isShowingIntro: Bool
    @State private var selectedTab = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                TabView(selection: $selectedTab) {
                    ForEach(0..<9) { index in
                        // ここで画像を表示します。適切な画像名に置き換えてください。
                        Image("S\(index)")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .animation(.easeInOut, value: selectedTab)
                VStack{
                    Spacer()
                    if selectedTab < 8 {
                        Button(action: {
                            // "次へ"ボタンが押されたときのアクション
                            if selectedTab < 8 {
                                selectedTab += 1
                            }
                        }) {
                            Text("次へ")
                                .frame(width:geometry.size.width/2)
                                .padding()
                                .foregroundColor(.blue) // <--- 文字色を青色に変更
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 2) // <--- 枠線を追加
                                )
                        }
                        .padding(.bottom,geometry.size.height/15)
                        .alignmentGuide(.bottom, computeValue: { d in d[.bottom] })
                    } else {
                        Button(action: {
                            // "はじめる"ボタンが押されたときのアクション
                            isShowingIntro = false
                        }) {
                            Text("はじめる")
                                .frame(width:geometry.size.width/2)
                                .padding()
                                .foregroundColor(.blue) 
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                                .padding(.bottom,geometry.size.height/15)
                        }
                    }
                }
            }
        }
    }
}
