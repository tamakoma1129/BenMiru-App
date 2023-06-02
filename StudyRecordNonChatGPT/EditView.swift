//
//  EditView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/05/25.
//

import SwiftUI
import RealmSwift

//EditViewのストラクト
struct EditView: View {
    //viewModelGenreのインスタンスを生成して、変更されたら再実行
    @ObservedResults(Genre.self) var genres //ObservedResultはオブジェクトのコレクションを観測、追加、削除やらできる
    @State var newGenreName = ""            //新しく追加されるジャンル名を保存する変数
    @State var newGenreColor = Color.white  //新しく追加されるジャンルカラーを保存する変数
    @State private var showDeleteAlert = false  //Alertの状態を保存
    @State private var tempIndexSet : IndexSet?
    @FocusState var keyIsActive : Bool
    var body: some View {
        GeometryReader { geometry in
            NavigationView{ //上部タイトルを追加
                VStack {
                    //ここが上の新しいジャンルを追加する画面
                    HStack {
                        TextField("学ぶテーマ名を記入", text: $newGenreName)
                            .frame(maxWidth:.infinity)  //ColorPickerギリギリまで広くする
                            .focused($keyIsActive)
                        ColorPicker("", selection: $newGenreColor)
                            .frame(width:geometry.size.width / 20)
                        
                        //ボタンを押すと新しいジャンルが追加される
                        Button(action: {
                            let genre = Genre()
                            genre.name = newGenreName
                            let uiColor = UIColor(newGenreColor)
                            if let rgba = uiColor.rgba {
                                genre.colorRed = Float(rgba.red)
                                genre.colorGreen = Float(rgba.green)
                                genre.colorBlue = Float(rgba.blue)
                                genre.colorAlpha = Float(rgba.alpha)
                            }
                            genre.lastUpdatedDate = Date() //正確な日時は必要なくて、順序だけ合ってればいいのでDate()のみ
                            $genres.append(genre)
                            //初期値に戻しておく
                            newGenreName = ""
                            newGenreColor = Color.white
                            
                        }, label: {
                            Text("追加")
                        })
                        .padding(.leading)
                    }
                    .padding()
                    // 追加されたジャンルのリストのView
                    List{
                        ForEach(genres){ genre in
                            //ジャンルにデータがあればifの処理
                            if !genre.isInvalidated {
                                VStack {
                                    HStack {
                                        //テキストを直接編集できるようにする画面部分
                                        TextField("Edit Genre", text: Binding(
                                            //新しくテキストが入力されたら
                                            get: { genre.name },
                                            //realmに書き込む
                                            set: { newValue in
                                                //realmを解凍して書き込めるようにする
                                                let thawGenre = genre.thaw()
                                                try! thawGenre?.realm!.write{
                                                    thawGenre?.name=newValue
                                                }
                                                //再凍結させる。もしかしてこの位置だと意味ない
                                                thawGenre?.freeze()
                                            }
                                        ))
                                        .focused($keyIsActive)
                                        //色を直接編集できるようにする画面部分
                                        ColorPicker("", selection: Binding(
                                            //新しく色が追加されたら
                                            get: {
                                                Color(red: Double(genre.colorRed),
                                                      green: Double(genre.colorGreen),
                                                      blue: Double(genre.colorBlue),
                                                      opacity: Double(genre.colorAlpha))
                                            },
                                            //それをrealmに書き込む
                                            set: { newValue in
                                                //解凍する
                                                let thawGenre = genre.thaw()
                                                try! thawGenre?.realm!.write{
                                                    let uiColor = UIColor(newValue)
                                                    if let rgba = uiColor.rgba {
                                                        thawGenre?.colorRed = Float(rgba.red)
                                                        thawGenre?.colorGreen = Float(rgba.green)
                                                        thawGenre?.colorBlue = Float(rgba.blue)
                                                        thawGenre?.colorAlpha = Float(rgba.alpha)
                                                    }
                                                }
                                                //再凍結させる。もしかしてこの位置だと意味ない
                                                thawGenre?.freeze()
                                            }
                                        ))
                                    }
                                }
                            }
                        }
                        //左にスワイプしたら削除。また、それに関連するStudyRecordも削除
                        .onDelete{indexSet in   //indexSetは削除するインデックスが入る（スワイプで削除なので基本1つの要素のみ）
                            tempIndexSet = indexSet
                            showDeleteAlert = true
                        }
                        
                        
                    }
                }
                //キーボードの右上に完了ボタンを追加
                .toolbar{ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完了") {
                        keyIsActive = false //  フォーカスを外す
                    }
                }
                }
                //誤スワイプで消えると困るので、警告を表示
                .alert("本当に削除しますか？", isPresented: $showDeleteAlert){
                    Button("削除する",role: .destructive){
                        do {
                            let realm = try Realm()
                            try realm.write {
                                for index in tempIndexSet! { //forで回して入るけど、通常は1回のみしか動かない。
                                    // 消そうとしたジャンルのidを取得
                                    let genreIdToDelete = genres[index].id
                                    
                                    // 削除するジャンルを検索
                                    guard let genreToDelete = realm.objects(Genre.self).filter("id == '\(genreIdToDelete)'").first else {
                                        continue
                                    }
                                    
                                    // 削除するジャンルidで登録されているStudyRecordを出力
                                    let matchingStudyRecords = realm.objects(StudyRecord.self).filter("genreId == '\(genreIdToDelete)'")
                                    
                                    // 出力したStudyRecordを削除
                                    realm.delete(matchingStudyRecords)
                                    
                                    // ジャンルを削除
                                    realm.delete(genreToDelete)
                                }
                            }
                        } catch {
                            print("Error deleting genres and their associated StudyRecords: \(error)")
                        }
                    }
                    Button("キャンセル",role: .cancel){
                        tempIndexSet = nil
                    }
                } message: {
                    Text("関連する勉強記録も削除されます")
                }
                .navigationTitle("Edit Genres")
            }
            .navigationViewStyle(.stack)
        }
    }
}
