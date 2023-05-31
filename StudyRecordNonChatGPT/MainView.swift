//
//  MainView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/05/25.
//

import SwiftUI
import RealmSwift

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


//MainViewのストラクト
struct MainView: View {
    private var cntIJ:Int = 0
    @ObservedObject private var viewBlock = MakeViewBlock()
    @EnvironmentObject var genreColorMap: GenreColorMap
    // 複雑なのは、こうしないと型推論などで時間超過のコンパイルエラーが発生するから
    func createSubBlockView(index: Int, lineNumber: Int) -> some View {
        // 型をOptionalにし、後でViewがnilでない場合だけ表示するようにする
        guard let lastBlock = viewBlock.blockedStudyRecordEntities.last else {
            return AnyView(EmptyView())
        }
        //  lineNumber == -1だったら日付変更
        if lineNumber == -1 && index < lastBlock.count{
            
            let selectDate:Date? = lastBlock[index].1    //日付を代入 Optional(2023-05-31 01:23:33 +0000)
            if selectDate != nil{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "M/d"
                let dateString = dateFormatter.string(from: selectDate!)
                
                return AnyView(
                    Text(dateString)
                )
            }
        }else if index < lastBlock.count {  //違ったら線引く
            let subBlock:[String] = lastBlock[index].0
            if lineNumber < subBlock.count {
                let selectId: String = subBlock[lineNumber]
                if let selectedColor:UIColor = genreColorMap.colorMap[selectId] {
                    let color = Color(selectedColor)
                    let shape = BlockLinesShape(numberOfLine:lineNumber)
                    return AnyView(shape.stroke(color, lineWidth: 1.5)
                        .background(RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(.clear)))
                }
            }
        }
        return AnyView(EmptyView())
    }
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                ForEach(0..<16) { i in  //縦のブロックの数
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            ForEach(0..<10) { j in  //横のブロックの数
                                ZStack{
                                    Rectangle()
                                        .stroke(Color.gray, lineWidth: 1)
                                        .aspectRatio(1, contentMode: .fill)
                                        .frame(width: geometry.size.width / 12)
                                    ForEach(0..<15) { k in
                                        createSubBlockView(index: i * 10 + j, lineNumber: k)
                                            .clipped()
                                    }
                                    GeometryReader { geometryBlock in
                                        createSubBlockView(index: i * 10 + j, lineNumber: -1)
                                            .foregroundColor(.black)
                                            .font(.system(size: geometry.size.width/30, weight: .bold, design: .default))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                            .background(.white)
                                    }
                                }
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

