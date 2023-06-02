//
//  GraphAlgorithm.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/06/02.
//

import Foundation
import RealmSwift

func graph(){
    // Realmから全ての勉強記録を取得
    let allRecords = StudyRecord.studyAll()

    // 日付ごとに勉強記録をグループ化
    var recordsByDate: [Date: [StudyRecord]] = [:]
    for record in allRecords {
        let date = Calendar.current.startOfDay(for: record.date) // 日付の時間部分を無視
        if recordsByDate[date] == nil {
            recordsByDate[date] = []
        }
        recordsByDate[date]?.append(record)
    }

    // 各日付の各ジャンルの勉強時間を計算
    var studyTimeByDateAndGenre: [Date: [String: Int]] = [:]
    for (date, records) in recordsByDate {
        var studyTimeByGenre: [String: Int] = [:]
        for record in records {
            if studyTimeByGenre[record.genreId] == nil {
                studyTimeByGenre[record.genreId] = 0
            }
            studyTimeByGenre[record.genreId]? += record.durationMinutes
        }
        studyTimeByDateAndGenre[date] = studyTimeByGenre
    }

    // Realmから全ての勉強記録とジャンルを取得
    let studyRecords = StudyRecord.studyAll()
    let genres = Genre.genreAll()
    
    // 日付ごとにジャンル別の勉強時間を計算
    for record in studyRecords {
        let date = Calendar.current.startOfDay(for: record.date)  // 日付の時間部分を無視
        let genreName = genres.first(where: { $0.id == record.genreId })?.name ?? "Unknown"
        
        if studyTimeByDateAndGenre[date] == nil {
            studyTimeByDateAndGenre[date] = [genreName: record.durationMinutes]
        } else {
            studyTimeByDateAndGenre[date]![genreName, default: 0] += record.durationMinutes
        }
    }
    
}
