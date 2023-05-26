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
        //ここら辺は線が途切れないよう微調整しただけ
        path.move(to: CGPoint(x: x + 10, y: -10))
        path.addLine(to: CGPoint(x: -10, y: x + 10))
        path.addLine(to: CGPoint(x: -10, y: x + 10))
        
        return path
    }
}
//斜線pathの描写を上のstructを使って行う
struct BlockLinesView: View {
    let ACLi:[Color?]

    var body: some View {
        //ZStackじゃなくてもいい気はする。
        ZStack {
            //15本描写したければ(0..<15)
            ForEach(0..<15){ i in
                BlockLinesShape(numberOfLine: i) // 線を渡す
                //ACLiに色の情報を詰め込んで、それをいちいち描写する感じ。もし、nilなら透明で描写。
                    .stroke(ACLi[i] ?? Color.clear, lineWidth: 1.5)//斜線の太さ
                RoundedRectangle(cornerRadius: 0)
                    .foregroundColor(.clear)
                //ブロックの枠の太さと色
                    .border(Color.gray, width: 0.151)
            }
        }
    }
}


//MainViewのストラクト
struct MainView: View {
    var body: some View {
        Text("MainView")
    }
}
