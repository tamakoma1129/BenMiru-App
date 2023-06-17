//
//  HelpView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/06/14.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        NavigationView{
            VStack{
                List{
                    Section(header: Text("わからない時")){
                        NavigationLink(destination: FnQView()) {
                            HStack {
                                Text("よくある質問")
                                Spacer()
                            }
                        }
                        NavigationLink(destination: Text("使い方の詳細")) {
                            HStack {
                                Text("使い方")
                                Spacer()
                            }
                        }
                        NavigationLink(destination: Text("使い方（動画）の詳細")) {
                            HStack {
                                Text("使い方（動画）")
                                Spacer()
                            }
                        }
                    }
                    Section(header:Text("その他")){
                        HStack{
                            Text("レビューする")
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    reviewApp()
                                }
                            Spacer()
                            Image(systemName: "star.fill")
                                .foregroundColor(.gray)
                        }
                        HStack{
                            makeLinkView(text: "機能リクエスト・ご意見", url: "https://docs.google.com/forms/d/e/1FAIpQLSe2bfx-TgZF1T1-wbjACPL51zJX454wsuvCLD-8Oogh8mJauQ/viewform?usp=sf_link")
                        }
                        
                        HStack{
                            makeLinkView(text: "お問い合わせ", url: "https://tamakoma.com/%e5%8b%89%e5%bc%b7%e6%99%82%e9%96%93%e8%a8%98%e9%8c%b2%e3%82%a2%e3%83%97%e3%83%aa%e3%80%8c%e3%81%b9%e3%82%93%e3%83%9f%e3%83%ab%e3%80%8d%e3%82%92%e4%bd%9c%e3%82%8a%e3%81%be%e3%81%97%e3%81%9f/#toc3")
                        }
                        
                        makeLinkView(text: "プライバシーポリシー", url: "https://tamakoma.com/%e3%81%b9%e3%82%93%e3%83%9f%e3%83%ab-%e3%83%97%e3%83%a9%e3%82%a4%e3%83%90%e3%82%b7%e3%83%bc%e3%83%9d%e3%83%aa%e3%82%b7%e3%83%bc/")
                    }
                    
                }
            }
            .navigationTitle("ヘルプ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

//よくある質問View
struct FnQView: View {
    //モーダル表示内容
    @State private var modalContent: ModalContent?
    //モーダルの中身の定義
    struct ModalContent: Identifiable {
        let id = UUID()
        let label: String
        let text: String
    }
    //モーダルViewを表示する
    struct ModalView: View {
        let content: ModalContent

        var body: some View {
            NavigationView {
                VStack{
                    Divider()
                        .padding()
                    Text(content.text)
                        .padding()
                    Spacer()
                        
                }
                .navigationTitle(content.label)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    // NavigationLinkを作る関数
    func makeNavigationLink(label: String, text: String) -> some View {
        Button(action: {
            modalContent = ModalContent(label: label, text: text)
        }) {
            HStack {
                Text(label)
                    .foregroundColor(Color(UIColor(named:"Border")!))
                Spacer()
            }
        }
        .sheet(item: $modalContent) { content in
            ModalView(content: content)
        }
    }

    var body: some View {
        VStack{
            List{
                makeNavigationLink(label: "登録した科目を削除したい", text: "「追加/編集」画面から該当の科目を左にスワイプすることで消すことができます。")
                makeNavigationLink(label: "勉強記録を一部削除", text: "勉強記録を一部削除")
                makeNavigationLink(label: "全データを削除したい", text: "できないので、再インストール")
                makeNavigationLink(label: "機種変更などのデータ引き継ぎ", text: "サンプルテキスト")
                makeNavigationLink(label: "データはどこに保存されてる？", text: "サンプルテキスト")
                makeNavigationLink(label: "勉強科目の名前を変更したい", text: "サンプルテキスト")
                makeNavigationLink(label: "勉強科目の色を変更したい", text: "サンプルテキスト")
                makeNavigationLink(label: "○○のような機能はないの？", text: "サンプルテキスト")
                makeNavigationLink(label: "○○の部分バグってない？", text: "サンプルテキスト")
            }
        }
        .navigationTitle("よくある質問")
    }
}
//レビュー画面への遷移
func reviewApp(){
    let productURL:URL = URL(string: "https://apps.apple.com/us/app/%E3%81%B9%E3%82%93%E3%83%9F%E3%83%AB-%E5%8B%89%E5%BC%B7%E8%A8%98%E9%8C%B2%E3%82%92%E8%A6%8B%E3%81%88%E3%82%8B%E5%8C%96%E3%81%99%E3%82%8B/id6449942689")!
    
    var components = URLComponents(url: productURL, resolvingAgainstBaseURL: false) //URLを分解
    
    components?.queryItems = [
        URLQueryItem(name: "action", value: "write-review") //write-reviewを入れる事でレビュー画面に遷移
    ]
    
    guard let writeReviewURL = components?.url else {
        return
    }
    
    UIApplication.shared.open(writeReviewURL)
}
//指定したURLへの遷移
func makeLinkView(text: String, url: String) -> some View {
    guard let url = URL(string: url) else {
        return AnyView(Text(text))
    }
    return AnyView(
        Link(destination: url) {
            HStack {
                Text(text)
                Spacer()
                Image(systemName: "safari")
                    .foregroundColor(.gray)
            }
        }
    )
}

