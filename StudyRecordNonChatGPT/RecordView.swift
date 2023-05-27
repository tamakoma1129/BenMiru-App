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
    @State private var selectedGenreName = ""
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
                                selectedGenreName = genre.name
                                showModal = true
                        }
                        }
                    }
                }
            }
            .navigationTitle("Select Genre")
            .sheet(isPresented: $showModal) {
                RecordViewModal(genreName: $selectedGenreName,showModal: $showModal)
            }
        }
    }
    //ジャンルを選択したときのモーダル画面
    struct RecordViewModal: View{
        @Binding var genreName: String
        @Binding var showModal: Bool
        var body: some View{
            NavigationView{
                VStack{
                    Text(genreName)
                }
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
        }
    }
}
