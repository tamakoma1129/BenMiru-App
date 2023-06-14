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
        let x = rect.width * CGFloat(numberOfLine) / 7
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
    @ObservedObject private var viewBlock = MakeViewBlock() //常に最新のScrブロックリストを作成するClass
    @EnvironmentObject var genreColorMap: GenreColorMap //genreIdと色、名前の変換を辞書で行えるClass
    @State private var pages: [AnyView] = []    //ページを表示するリスト。someViewのsomeは値は隠蔽するけど、型は合ってると保証するもの？　っぽいので具体的な値を求める配列には使えない。
    @State private var selectedPage: Int = 0    //現在ページの変数
    @State private var isLoading = false    // ローディング画面表示フラグを追加
    
    // 中身のコードが複雑なのは、こうしないと型推論などで時間超過のコンパイルエラーが発生するから
    func createSubBlockView(index: Int, lineNumber: Int, scrIndex: Int) -> some View {
        // indicesでViewがnilでない場合だけ表示するようにする
        if viewBlock.blockedStudyRecordEntities.indices.contains(scrIndex) {
            let nowScr = viewBlock.blockedStudyRecordEntities[scrIndex]
            //  lineNumber == -1だったら日付変更の関数へ（これクラスとかで分けるべきでは？）
            if lineNumber == -1 && index < nowScr.count{
                let selectDate:Date? = nowScr[index].1    //日付を代入 Optional(2023-05-31 01:23:33 +0000)
                if selectDate != nil{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "M/d"
                    let dateString = dateFormatter.string(from: selectDate!)
                    
                    return AnyView(
                        Text(dateString)
                    )
                }
            }else if index < nowScr.count {  //違ったら線引く関数へ
                let subBlock:[String] = nowScr[index].0
                if lineNumber < subBlock.count {
                    let selectId: String = subBlock[lineNumber]
                    if let selectedColor:UIColor = genreColorMap.colorMap[selectId] {
                        let color = Color(selectedColor)
                        let shape = BlockLinesShape(numberOfLine:lineNumber)
                        return AnyView(shape.stroke(color, lineWidth: 1.5)  //斜線の太さ
                            .background(RoundedRectangle(cornerRadius: 0)
                                .foregroundColor(.clear)))
                    }
                }
            }
            return AnyView(EmptyView())
        } else {
            return AnyView(EmptyView())
        }
    }
    
    func createPageView(scrIndex: Int) -> some View {
        GeometryReader { geometry in
            VStack {
                if (geometry.size.height > 600){    //iPhoneXなどの画面縦幅が長い場合はSpacerで整える
                    Spacer()
                }
                VStack(spacing: 0) {
                    ForEach(0..<16) { i in  //縦のブロックの数
                        HStack(spacing: 0) {
                            ForEach(0..<10) { j in  //横のブロックの数
                                ZStack{
                                    Rectangle()
                                        .stroke(Color.gray, lineWidth: 1)
                                        .aspectRatio(1, contentMode: .fill)
                                        .frame(width: geometry.size.width / 12)
                                    ForEach(0..<15) { k in
                                        createSubBlockView(index: i * 10 + j, lineNumber: k, scrIndex: scrIndex)    //線の追加
                                            .clipped()
                                    }
                                    GeometryReader { geometryBlock in
                                        createSubBlockView(index: i * 10 + j, lineNumber: -1, scrIndex: scrIndex)   //日付の追加
                                            .foregroundColor(Color(UIColor(named:"Border")!))
                                            .font(.system(size: geometry.size.width/36, weight: .medium, design: .default))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                            .background(Color(UIColor(named:"Background")!))
                                            .cornerRadius(geometryBlock.size.width / 12)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, geometry.size.width / 12)
                        .frame(height: UIScreen.main.bounds.width / 12)
                    }
                }
                Spacer()
            }
        }
    }

    func allPage(){
        DispatchQueue.global().async {  //非同期処理の実行
            self.isLoading = true   //ローディング中をTrue

            var newPages: [AnyView] = []
            for scrIndex in 0..<self.viewBlock.blockedStudyRecordEntities.count{
                let hoge = AnyView(self.createPageView(scrIndex: scrIndex))
                newPages.append(hoge)
            }

            DispatchQueue.main.async {  //UIを更新する為にメインに戻る
                self.pages = newPages
                self.selectedPage = self.viewBlock.blockedStudyRecordEntities.count-1
                self.isLoading = false
            }
        }
    }
    var body: some View {
            NavigationView(){
                VStack{
                    if isLoading { // ローディング中は ProgressView を表示
                        ProgressView()
                    } else {
                        TabView(selection: $selectedPage) {
                            ForEach(pages.indices, id: \.self) { index in
                                pages[index].tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .onAppear(){
                            allPage()
                            selectedPage=viewBlock.blockedStudyRecordEntities.count-1
                        }
                        .onChange(of: viewBlock.blockedStudyRecordEntities.count){ _ in
                            allPage()
                            selectedPage=viewBlock.blockedStudyRecordEntities.count-1
                        }
                    }
                }
                .navigationTitle("\(selectedPage+1)/\(viewBlock.blockedStudyRecordEntities.count)ページ目")
                .navigationBarItems(trailing:   //SettingViewへの遷移ボタン
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape")
                            }
                                    )
                .navigationBarItems(trailing:   //SettingViewへの遷移ボタン
                            NavigationLink(destination: HelpView()) {
                                Image(systemName: "questionmark.circle")
                            }
                        )
            }
            .navigationViewStyle(.stack)
        }
}

