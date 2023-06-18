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
    var body: some View {
        ZStack {
            TabView {
                ForEach(0..<8) { index in
                    // ここで画像を表示します。適切な画像名に置き換えてください。
                    Image("S\(index)")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // バツボタンが押されたときのアクション
                        isShowingIntro = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.largeTitle)
                            .padding()
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            }
        }
    }
}
