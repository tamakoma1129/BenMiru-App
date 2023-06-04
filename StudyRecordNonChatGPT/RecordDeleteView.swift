//
//  RecordDeleteView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/06/04.
//

//記録した勉強記録のデータを消すView
import SwiftUI
import RealmSwift

struct RecordDeleteView: View {
    @EnvironmentObject var genreColorMap: GenreColorMap //genreIdと色、名前の変換を辞書で行えるClass
    @ObservedResults(StudyRecord.self,sortDescriptor:SortDescriptor(keyPath: "date", ascending: false)) var studyRecords
    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                List {
                    ForEach(studyRecords) { record in
                        if !record.isInvalidated {
                            HStack{
                                VStack{
                                    Text("\(dateToJapaneseString(date:record.date))")
                                        .font(.subheadline)
                                    Rectangle()
                                        .fill(Color(genreColorMap.colorMap[record.genreId]!))
                                        .frame(height:1)
                                    Spacer()
                                    HStack {
                                        Text(genreColorMap.nameMap[record.genreId]!)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.3)
                                            .font(.title3)
                                        Spacer()
                                        Text("\(record.durationMinutes)分")
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.3)
                                            .font(.title3)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                    .onDelete(perform: $studyRecords.remove)
                }
            }
        }
        .navigationTitle("記録一覧")
    }
}

//Date変換関数
func dateToJapaneseString(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy年M月d日 H時m分s秒"
    formatter.locale = Locale(identifier: "ja_JP")
    formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
    return formatter.string(from: date)
}
