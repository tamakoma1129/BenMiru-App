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
        VStack {
            //ここが上の新しいジャンルを追加する画面
            HStack {
                TextField("New Genre", text: $newGenreName)
                ColorPicker("", selection: $newGenreColor)
                //ボタンを押すと関数が発動
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
                    $genres.append(genre)
                    
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
                                        genre.name=newValue
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

                                        let uiColor = UIColor(newValue)
                                        if let rgba = uiColor.rgba {
                                            genre.colorRed = Float(rgba.red)
                                            genre.colorGreen = Float(rgba.green)
                                            genre.colorBlue = Float(rgba.blue)
                                            genre.colorAlpha = Float(rgba.alpha)
                                        }
                                    }
                                ))
                            }
                        }
                    }
                }
                //左にスワイプして削除したらdeleteGenreという関数を実行
                .onDelete(perform: $genres.remove)
            }
        }
        .navigationTitle("Edit Genres")
    }
    /*
    //新しいジャンルを作るときの処理関数
    private func createNewGenre() {
        let newGenre = Genre()
        let uiColor = UIColor(newGenreColor)
        newGenre.name = newGenreName
        //RGBAを0~1にして保存
        if let rgba = uiColor.rgba {
            newGenre.colorRed = Float(rgba.red)
            newGenre.colorGreen = Float(rgba.green)
            newGenre.colorBlue = Float(rgba.blue)
            newGenre.colorAlpha = Float(rgba.alpha)
        }

        do {
            let realm = try Realm()
            try realm.write {
                realm.add(newGenre)
            }
        } catch {
            print("Failed to create a new genre: \(error)")
        }

        //初期値に戻しておく
        newGenreName = ""
        newGenreColor = Color.white
        
    }
    
    private func deleteGenre(at offsets: IndexSet) { ///onDelete(perform:)で渡された削除する項目のIndexをIndexSetという形で渡している
        do {
            let realm = try Realm()
            //Indexの大きい順に消すことで、Indexがずれない
            for index in offsets.sorted(by: >) {
                try? realm.write {
                    realm.delete(viewModelGenre.genreEntities[index])
                }
            }
        } catch {
            print("Failed to delete genre: \(error)")
        }
    }*/
}
