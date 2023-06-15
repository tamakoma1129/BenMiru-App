//
//  HelpView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/06/14.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack{
            List{
                Section(header: Text("わからない時")){
                    NavigationLink(destination: Text("よくある質問の詳細")) {
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
                        Link(destination: URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSe2bfx-TgZF1T1-wbjACPL51zJX454wsuvCLD-8Oogh8mJauQ/viewform?usp=sf_link")!) {
                            HStack {
                                Text("機能リクエスト・ご意見")
                                Spacer()
                                Image(systemName: "safari")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    HStack{
                        Link(destination: URL(string: "https://tamakoma.com/%e5%8b%89%e5%bc%b7%e6%99%82%e9%96%93%e8%a8%98%e9%8c%b2%e3%82%a2%e3%83%97%e3%83%aa%e3%80%8c%e3%81%b9%e3%82%93%e3%83%9f%e3%83%ab%e3%80%8d%e3%82%92%e4%bd%9c%e3%82%8a%e3%81%be%e3%81%97%e3%81%9f/")!) {
                            HStack {
                                Text("お問い合わせ")
                                Spacer()
                                Image(systemName: "safari")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    NavigationLink(destination: Text("プライバシーポリシーの詳細")) {
                        HStack {
                            Text("プライバシーポリシー")
                            Spacer()
                        }
                    }
                }
                
            }
        }

        .navigationTitle("ヘルプ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}

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
