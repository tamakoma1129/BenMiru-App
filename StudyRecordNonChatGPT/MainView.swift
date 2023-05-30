//
//  MainView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/05/25.
//

import SwiftUI

//ブロック内部の斜線設定
struct BlockLinesShape: Shape {
    let numberOfLine: Int //塗る場所の指定をする変数。numberOfLine=0だと左上を塗る
    //実際に線を描写する為のpathの生成
    func path(in rect: CGRect) -> Path {
        var path = Path()
        //「CGFloat(numberOfLine-1) / 7」だと、max15本の線の内、どこを塗るかという選択になる。
        //numberOfLine=0で最初（左上）、numberOfLine=母数が真ん中、numberOfLine=母数*2が最後（右下）に線を生成する。上の例の場合母数は7。
        let x = rect.width * CGFloat(numberOfLine-1) / 7
        //ここら辺は線が途切れないよう微調整したから半端
        path.move(to: CGPoint(x: x + 10, y: -10))
        path.addLine(to: CGPoint(x: -10, y: x + 10))
        //path.addLine(to: CGPoint(x: -10, y: x + 10))
        
        return path
    }
}
//斜線pathの描写を上のstructを使って行う
struct BlockLinesView: View {
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                ForEach(0..<16) { _ in  //縦のブロックの数
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            ForEach(0..<10) { _ in  //横のブロックの数
                                Rectangle()
                                    .stroke(Color.gray, lineWidth: 1)
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: geometry.size.width / 12)
                            }
                        }
                        .padding(.horizontal, geometry.size.width / 12)
                    }
                    .frame(height: UIScreen.main.bounds.width / 12)
                }
            }
            Spacer()
        }
    }
}



//MainViewのストラクト
struct MainView: View {
    var body: some View {
        BlockLinesView ()
    }
}
