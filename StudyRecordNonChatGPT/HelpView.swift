//
//  HelpView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/06/14.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        List{
            Text("使い方")
            Text("使い方（動画）")
            Link("お問い合わせ", destination: URL(string: "https://tamakoma.com/%e5%8b%89%e5%bc%b7%e6%99%82%e9%96%93%e8%a8%98%e9%8c%b2%e3%82%a2%e3%83%97%e3%83%aa%e3%80%8c%e3%81%b9%e3%82%93%e3%83%9f%e3%83%ab%e3%80%8d%e3%82%92%e4%bd%9c%e3%82%8a%e3%81%be%e3%81%97%e3%81%9f/")!)
            Link("機能リクエスト・ご意見", destination: URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSe2bfx-TgZF1T1-wbjACPL51zJX454wsuvCLD-8Oogh8mJauQ/viewform?usp=sf_link")!)
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
