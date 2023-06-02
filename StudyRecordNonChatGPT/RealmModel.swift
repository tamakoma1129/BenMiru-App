//
//  RealmModel.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/05/26.
//

import RealmSwift
import SwiftUI

//Realmのモデルを設定する

//これはEditViewでジャンルを作成して保存するときのRealmデータモデル
class Genre: Object, Identifiable {
    @objc dynamic var id = UUID().uuidString    // 一意のIDらしい
    @objc dynamic var name = ""                 // ジャンル名
    @objc dynamic var colorRed: Float = 0       // 色の情報を損なわずに保存するために、RGB255と透明度Alphaを0~1に標準化して保存する
    @objc dynamic var colorGreen: Float = 0
    @objc dynamic var colorBlue: Float = 0
    @objc dynamic var colorAlpha: Float = 1
    @objc dynamic var lastUpdatedDate: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private static var realm = try! Realm()
    //Resultは常に最新のデータを保持する
    //genreAllはデータベースからすべてのgenreオブジェクトを取得する静的関数で、Results<ItemEntity>型のオブジェクトを返す
    static func genreAll() -> Results<Genre> {
        realm.objects(Genre.self)
    }
}

//勉強記録を保存するときのRealmデータモデル
class StudyRecord: Object, Identifiable {
    @objc dynamic var id = UUID().uuidString  // 一意のID
    @objc dynamic var genreId = ""  // ジャンルのIDを保存して、これと上のGenreと参照して色を求める
    @objc dynamic var date = Date()  // 記録したときの日付。これでソートする
    @objc dynamic var durationMinutes = 0  // いくら勉強したか(分)
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private static var realm = try! Realm()
    //Resultは常に最新のデータを保持する
    //studyAllはデータベースからすべてのStudyRecordオブジェクトを取得する静的関数で、Results<ItemEntity>型のオブジェクトを返す
    static func studyAll() -> Results<StudyRecord> {
        realm.objects(StudyRecord.self)
    }
}

//一回genreEntitiesにコピーしてそこに参照することで、DBを削除したときの参照エラーなどを回避する

class ViewModelGenre: ObservableObject {
    @Published var genreEntities: Results<Genre> = Genre.genreAll() //Publishedがついてる変数の値が変更すると、それを監視してるViewが自動的に実行される。
    private var notificationTokensGenre: [NotificationToken] = []
    
    init() {
        //DBに変更があったタイミングでgenreEntitiesの値を入れ直す（最新にする）
        notificationTokensGenre.append(genreEntities.observe { change in
            switch change {
            case let .initial(results):
                self.genreEntities = results
            case let .update(results, _, _, _):
                self.genreEntities = results
            case let .error(error):
                print(error.localizedDescription)
            }
        })
    }
    //deinitするとき、Tokenの購読を解除（無駄な負担をかけない為）
    deinit {
        notificationTokensGenre.forEach { $0.invalidate()}
    }
}

//ViewModelGenreのStudy版
class ViewModelStudy: ObservableObject {
    @Published var studyEntities: Results<StudyRecord> = StudyRecord.studyAll()
    @Published var studyByDayAndGenre = [Date: [String: Int]]() //グラフ描写のための辞書データを作成
    private var notificationTokensStudy: [NotificationToken] = []
    
    init() {
        notificationTokensStudy.append(studyEntities.observe { change in
            switch change {
            case let .initial(results):
                self.studyEntities = results
                self.updateStudyByDayAndGenre()
            case let .update(results, _, _, _):
                self.studyEntities = results
                self.updateStudyByDayAndGenre()
            case let .error(error):
                print(error.localizedDescription)
            }
        })
    }

    deinit {
        notificationTokensStudy.forEach { $0.invalidate()}
    }
    //全データから日付毎に勉強したジャンルIDとその日勉強した時間を記録する辞書を作る関数
    func updateStudyByDayAndGenre() {
        var newStudyByDayAndGenre = [Date: [String: Int]]()
        let calendar = Calendar.current
        
        for study in studyEntities {
            // Remove the time part of the date
            let date = calendar.startOfDay(for: study.date)
            let genreId = study.genreId
            let duration = study.durationMinutes
            
            if newStudyByDayAndGenre[date] == nil {
                newStudyByDayAndGenre[date] = [String: Int]()
            }
            
            if newStudyByDayAndGenre[date]![genreId] == nil {
                newStudyByDayAndGenre[date]![genreId] = duration
            } else {
                newStudyByDayAndGenre[date]![genreId]! += duration
            }
        }
        
        studyByDayAndGenre = newStudyByDayAndGenre
    }
}


//IDを色に変換するためのClass
class GenreColorMap: ObservableObject {
    @Published var colorMap: [String: UIColor] = [:]
    private var notificationToken: NotificationToken?
    
    init() {
        updateColorMap()
        listenForChanges()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func updateColorMap() {
        let genres = Genre.genreAll()
        colorMap = [:]
        for genre in genres {
            colorMap[genre.id] = UIColor(red: CGFloat(genre.colorRed),
                                         green: CGFloat(genre.colorGreen),
                                         blue: CGFloat(genre.colorBlue),
                                         alpha: CGFloat(genre.colorAlpha))
        }
    }
    
    func listenForChanges() {
        notificationToken = Genre.genreAll().observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial, .update:
                self?.updateColorMap()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
}
