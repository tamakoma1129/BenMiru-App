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
    @ObservedResults(StudyRecord.self,sortDescriptor:SortDescriptor(keyPath: "date", ascending: false)) var studyRecords
    var body: some View {
        GeometryReader { geometry in
            List {
                ForEach(studyRecords) { record in
                    if !record.isInvalidated {
                        HStack {
                            Text(record.genreId)
                            Text("\(record.durationMinutes) minutes")
                            Text("\(record.date)")
                        }
                    }
                }
                .onDelete(perform: $studyRecords.remove)
            }
        }
    }
}
