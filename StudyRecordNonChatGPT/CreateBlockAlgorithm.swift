//
//  CreateBlockAlgorithm.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/05/30.
//

import SwiftUI
import RealmSwift



class MakeViewBlock{
    var blockStudyRecordEntities: Results<StudyRecord> = StudyRecord.studyAll().sorted(byKeyPath: "date", ascending: true)
    @Published var blockedStudyRecordEntities : [[([String], Date?)]] = []
    private var notificationTokens: [NotificationToken] = []
    init() {
        // DBに変更があったタイミングでblockStudyRecordEntitiesの変数に値を入れ直す
        //observeはDBに変更があるたびにクロージャ（{}の中の関数）を起動する
        let token = blockStudyRecordEntities.observe { [weak self] change in // 循環ループしないように[weak self] を追加
            //最新のデータベース情報がresultsに入り、それがitemEntitiesに代入
            switch change {
            case let .initial(results):
                self?.blockStudyRecordEntities = results
                self?.blockedStudyRecordEntities = makeScr(makeBlock(self?.blockStudyRecordEntities.map { ($0.date, $0.genreId, $0.durationMinutes) } ?? [], 15),16*10,15)
            case let .update(results, _, _, _):
                self?.blockStudyRecordEntities = results
                self?.blockedStudyRecordEntities = makeScr(makeBlock(self?.blockStudyRecordEntities.map { ($0.date, $0.genreId, $0.durationMinutes) } ?? [], 15),16*10,15)
            case let .error(error):
                print(error.localizedDescription,"makeViewBlock")
            }
        }
        notificationTokens.append(token)
    }
    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }
}

//setTimeの数だけIDを入れた配列を１ブロックとする
func makeBlock(_ li: [(Date, String, Int)], _ setTime: Int) -> [([String], Date?)] {
    /*
     1.未完成のブロックを埋めるフェーズ
     2.time//setTime。つまり、割り切れるだけブロックの塊を作るフェーズ
     3.time%setTime。つまり、余りのブロックを作るフェーズ。ここでは、-1などで埋めたりしない。
     */
    var blockLi: [([String], Date?)] = []
    var dateSet: Set<Date> = []

    for liData in li {
        let (date, id, time) = liData
        //blockLi.isEmpty=trueってことは初回起動。初回起動で未完成っていうのはありえないので、pass。
        if blockLi.isEmpty {
            //pass
        }
        else if blockLi[blockLi.count - 1].0.count != setTime {     //blockLi.count - 1ってことは、最後の配列の.0ってことはStringの塊の要素数がsetTimeじゃないってことは未完成
            //時間がなくなる or Stringの塊の要素数がsetTimeになるまで埋める
            var time = time
            while true {
                if time == 0 || blockLi[blockLi.count - 1].0.count == setTime {
                    break
                }
                blockLi[blockLi.count - 1].0.append(id)
                time -= 1
            }
            //ここの処理に来てる時点でtime==0 or ブロックが埋まってる（端数がなく、未完成でない）
            //現在いじった配列のdateがnil　かつ　今回追加しているジャンルの日付がまだ追加されたこと無かったら日付を追加
            if blockLi[blockLi.count - 1].1 == nil && !dateSet.contains(date) {
                blockLi[blockLi.count - 1].1 = date
                dateSet.insert(date)
            }
        }
        //timeが0なら何もせず。timeが余ってるなら未完成のブロックはないので、新しいブロックを作る
        if time != 0 {
            //2.time//setTime。つまり、割り切れるだけブロックの塊を作るフェーズ
            let timeDivSetTime = time / setTime //例えばsetTime=15でtime=40だとしたら、40//15＝2個だけブロックの塊を作る
            for _ in 0..<timeDivSetTime {
                let tempBlock = Array(repeating: id, count: setTime)    //idの塊
                if !dateSet.contains(date) {    //dateSetになかったらdateを追加
                    blockLi.append((tempBlock, date))
                    dateSet.insert(date)
                } else {    //既に追加されてたらnil
                    blockLi.append((tempBlock, nil))
                }
            }
            //3.time%setTime。つまり、余りのブロックを作るフェーズ。ここでは、-1などで埋めたりしない。
            let timeOverSetTime = time % setTime    //例えばsetTime=15でtime=40だとしたら、40%15＝10個のidが入っただけのブロックの塊を1個作る
            if timeOverSetTime != 0 {
                let tempBlock = Array(repeating: id, count: timeOverSetTime)
                if !dateSet.contains(date) {
                    blockLi.append((tempBlock, date))
                    dateSet.insert(date)
                } else {
                    blockLi.append((tempBlock, nil))
                }
            }
        }
    }
    return blockLi
}
//scrLimitの数ごとにブロックの塊を分ける
func makeScr(_ blockLiInput: [([String], Date?)], _ scrLimit: Int, _ setTime: Int) -> [[([String], Date?)]] {
    var scrLi: [[([String], Date?)]] = []
    let modelBlock: ([String], Date?) = (Array(repeating: "-1", count: setTime), nil)   //丁度scrLimitで分けれなかったら余りのブロックはこれで埋める
    var tempScr: [([String], Date?)] = []
    var blockLi = blockLiInput
    //blockLiの最後が未完成なら、-1でsetTimeまで埋める
    if blockLi.last?.0.count != setTime {
        while true {
            if blockLi.last?.0.count == setTime {
                break
            }
            blockLi[blockLi.count - 1].0.append("-1")
        }
    }
    //bolockLiをscrLimit個ずつで分ける
    //そんな量じゃないので、愚直な実装でも問題なし（たぶん）
    for i in blockLi {
        tempScr.append(i)
        if tempScr.count == scrLimit {
            scrLi.append(tempScr)
            tempScr.removeAll()
        }
    }
    //tempScr.isEmptyじゃない＝半端な状態だったmodelBlockで埋める
    if !tempScr.isEmpty {
        while true {
            if tempScr.count == scrLimit {
                break
            }
            tempScr.append(modelBlock)
        }
        scrLi.append(tempScr)
    }
    return scrLi
}
