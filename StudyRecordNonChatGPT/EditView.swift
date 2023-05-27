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
    @ObservedResults(Genre.self) var genres
    @State var newGenreName = ""            //新しく追加されるジャンル名を保存する変数
    @State var newGenreColor = Color.white  //新しく追加されるジャンルカラーを保存する変数
    var body: some View {
        NavigationView{ //上部タイトルを追加
            VStack {
                //ここが上の新しいジャンルを追加する画面
                HStack {
                    TextField("New Genre", text: $newGenreName)
                    ColorPicker("", selection: $newGenreColor)
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
                        Text("add")
                    })
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
                    //左にスワイプしたら削除
                    .onDelete(perform: $genres.remove)
                }
            }
            .navigationTitle("Edit Genres")
        }
    }
}
