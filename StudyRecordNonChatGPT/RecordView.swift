//
//  RecordView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/05/25.
//

import SwiftUI
import RealmSwift

//RecordViewのストラクト
struct RecordView: View {
    //viewModelGenreのインスタンスを生成して、変更されたら再実行
    //日付降順（最新順）でソート
    @ObservedResults(Genre.self,sortDescriptor:SortDescriptor(keyPath: "lastUpdatedDate", ascending: false)) var genres
    @State private var showModal = false
    @State private var selectedGenreId = String()
    @State private var selectedGenreColor = UIColor()
    var body: some View {
        NavigationView{
            List{
                ForEach(genres){ genre in
                    if !genre.isInvalidated {
                        VStack{
                            HStack{
                                Text(genre.name)
                                //スペーサーで選択範囲を広げる
                                Spacer()
                            }
                            //contentShape(Rectangle())をつけることでセル全体を選択できる
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedGenreId = genre.name
                                showModal = true
                                selectedGenreColor = UIColor(
                                    red: CGFloat(genre.colorRed),
                                    green: CGFloat(genre.colorGreen),
                                    blue: CGFloat(genre.colorBlue),
                                    alpha: CGFloat(genre.colorAlpha)
                                )
                                
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Genre")
            .sheet(isPresented: $showModal) {
                RecordViewModal(genreId: $selectedGenreId,showModal: $showModal, uiColor:$selectedGenreColor)
            }
        }
    }
    //ジャンルを選択したときのモーダル画面
    struct RecordViewModal: View{
        @Binding var genreId: String
        @Binding var showModal: Bool
        @Binding var uiColor: UIColor
        
        @State var selectedTab = 1 //現在選択しているtabの番号を保存する変数
        var body: some View{
            NavigationView{
                VStack{
                    //自作したタブバーの表示
                    TabBarView(selectedTab: $selectedTab,uiColor: $uiColor)
                    TabView(selection: $selectedTab){
                        RecordViewManual(genreName: $genreId,uiColor: $uiColor).tag(1)
                        PageView(text: genreId).tag(2)
                        PageView(text: genreId).tag(3)
                    }
                    .tabViewStyle(.page)
                    //戻るボタンとかをNavigationbarに追加
                    .toolbar {
                        //戻るを左上に指定
                        ToolbarItemGroup(placement: .navigationBarLeading){
                            Button(action: {
                                //戻るボタンを押したらshowModal=Falseになって画面が閉じる
                                showModal.toggle()
                            }, label:{
                                Text("戻る")
                            })
                        }
                        
                    }
                }
                .navigationTitle("記録画面")
            }
            
        }
        //TabBarを自作する
        struct TabBarView : View {
            @Binding var selectedTab : Int  //どのタブを選んでいるかの変数
            @Binding var uiColor : UIColor
            var body: some View {
                HStack {
                    Spacer()
                    Text("手動入力")
                        .foregroundColor(selectedTab == 1 ? Color.white : Color.gray)   //左が選択時で右が非選択時の色
                        .padding()
                        .background(selectedTab == 1 ? Color.blue : Color.clear)
                        .cornerRadius(10)
                        .onTapGesture {
                            self.selectedTab = 1
                        }
                    Spacer()
                    Text("ストップウォッチ")
                        .foregroundColor(selectedTab == 2 ? Color.white : Color.gray)
                        .padding()
                        .background(selectedTab == 2 ? Color.blue : Color.clear)
                        .cornerRadius(10)
                        .onTapGesture {
                            self.selectedTab = 2
                        }
                    Spacer()
                    Text("タイマー")
                        .foregroundColor(selectedTab == 3 ? Color.white : Color.gray)
                        .padding()
                        .background(selectedTab == 3 ? Color.blue : Color.clear)
                        .cornerRadius(10)
                        .onTapGesture {
                            self.selectedTab = 3
                        }
                    Spacer()
                }
            }
        }
        //テスト用VIew
        struct PageView : View {
            var text = ""
            
            init(text : String) {
                self.text = text
            }
            var body: some View {
                VStack {
                    Text(text)
                        .font(.title)
                }
            }
        }
        //モーダル先の選択画面1　一番基本的な記録をする画面
        struct RecordViewManual : View{
            @Binding var genreName : String
            @Binding var uiColor : UIColor
            var body: some View {
                List{
                    HStack(spacing:20){
                        ZStack {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 80, height: 80)
                                .border(Color.black, width: 1)
                            EasyBlockModel()
                                .stroke(Color(uiColor), lineWidth: 2)
                                .frame(width: 80, height: 80)
                                .clipped()
                        }
                        .padding(0)
                        Text(genreName)
                    }
                    HStack{
                        
                    }
                }
            }
        }
    }
}

//BlockLinesView(ACLi: [Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor)])
