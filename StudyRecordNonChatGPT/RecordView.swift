//
//  RecordView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/05/25.
//

import SwiftUI
import RealmSwift

//RecordViewのストラクト
struct RecordView: View {
    //viewModelGenreのインスタンスを生成して、変更されたら再実行
    //日付降順（最新順）でソート
    @ObservedResults(Genre.self,sortDescriptor:SortDescriptor(keyPath: "lastUpdatedDate", ascending: false)) var genres
    @State private var showModal = false
    @State var selectedGenreName = String()
    @State var selectedGenreColor = UIColor()
    @State var selectedGenreId : String = "" //UUID.uuidStringで保存しているので、String
    var body: some View {
        GeometryReader { geometry in
            NavigationView{
                List{
                    ForEach(genres){ genre in
                        if !genre.isInvalidated {
                            VStack{
                                HStack{
                                    Rectangle()
                                        .fill(Color(UIColor(
                                            red: CGFloat(genre.colorRed),
                                            green: CGFloat(genre.colorGreen),
                                            blue: CGFloat(genre.colorBlue),
                                            alpha: CGFloat(genre.colorAlpha)
                                        )))
                                        .frame(width: 4)
                                    Text(genre.name)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .frame(height:geometry.size.height/20)
                                //contentShape(Rectangle())をつけることでセル全体を選択できる
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedGenreId = genre.id
                                    selectedGenreName = genre.name
                                    showModal = true
                                    selectedGenreColor = UIColor(
                                        red: CGFloat(genre.colorRed),
                                        green: CGFloat(genre.colorGreen),
                                        blue: CGFloat(genre.colorBlue),
                                        alpha: CGFloat(genre.colorAlpha)
                                    )
                                }
                            }
                        }
                    }
                }
                .navigationTitle("学習対象を選択")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: RecordDeleteView()) {
                            Text("Go")
                                .font(.title)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .sheet(isPresented: $showModal) {
                    RecordViewModal(genreName: $selectedGenreName,showModal: $showModal, uiColor:$selectedGenreColor, selectedGenreId: $selectedGenreId)
                }
            }
            .navigationViewStyle(.stack)
        }
    }
    //ジャンルを選択したときのモーダル画面
    struct RecordViewModal: View{
        @Binding var genreName: String
        @Binding var showModal: Bool
        @Binding var uiColor: UIColor
        @Binding var selectedGenreId: String
        @State var allMinuteTime:Int = 0
        @State var selectedDate: Date = Date()
        @State var selectedTab = 1 //現在選択しているtabの番号を保存する変数
        var body: some View{
            NavigationView{
                VStack{
                    //自作したタブバーの表示
                    TabBarView(selectedTab: $selectedTab,uiColor: $uiColor)
                    TabView(selection: $selectedTab){
                        RecordViewManual(genreName: $genreName,uiColor: $uiColor,selectedDate: $selectedDate, allMinuteTime: $allMinuteTime).tag(1)
                        StopwatchView(allMinuteTime: $allMinuteTime,uiColor: $uiColor,genreName: $genreName,selectedTab: $selectedTab).tag(2)
                    }
                    .tabViewStyle(.page)
                    //戻るボタンとかをNavigationbarに追加
                    .toolbar {
                        //戻るを左上に指定
                        ToolbarItemGroup(placement: .navigationBarLeading){
                            Button(action: {
                                //戻るボタンを押したらshowModal=Falseになって画面が閉じる
                                showModal.toggle()
                            }, label:{
                                Text("戻る")
                            })
                        }
                        //tag1 and time>0の時押せる
                        //処理したいのは、Genreの日付を現在日時にするのと、StudyRecordの選択した日付、時間、ジャンルIDを保存するの
                        ToolbarItemGroup(placement: .navigationBarTrailing){
                            if (selectedTab == 1 && allMinuteTime >= 1){
                                Button(action: {
                                    //記録する
                                    //日付の処理
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.locale = Locale(identifier: "ja_JP") //日本時間に設定
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //年-月-日 時間:分:秒を0埋めで記録
                                    let dateString = dateFormatter.string(from: selectedDate)   //selectedDateからフォーマット通りに日付を変更しdataに
                                    let dateDate = dateFormatter.date(from: dateString) //ここで日付型にしてる。フォーマットが違うとエラーが出るので、本当はエラー処理した方がいいんだけど、同じフォーマットを使っているので問題ないはず
                                    //Realmに記録する前処理
                                    let newRecord = StudyRecord()   //genreId,date,durationMinuteの3つを記録
                                    newRecord.genreId = selectedGenreId
                                    newRecord.date = dateDate!
                                    newRecord.durationMinutes = allMinuteTime
                                    //Realmに記録する処理
                                    do {
                                        let realm = try Realm()
                                        try realm.write {
                                            realm.add(newRecord)
                                        }
                                        //Genreの日付を更新する処理
                                        if let targetGenre = realm.objects(Genre.self).filter("id == '\(selectedGenreId)'").first {
                                            try realm.write {
                                                targetGenre.lastUpdatedDate = Date()
                                            }
                                        }
                                    } catch {
                                        print("RecordViewModelの記録を追加するところでエラー: \(error)")
                                    }
                                    showModal.toggle()
                                }, label:{
                                    Text("記録する")
                                        .foregroundColor(Color.blue)
                                })
                            } else {
                                Text("記録する")
                                    .foregroundColor(Color.gray)
                            }
                        }
                    }
                }
                .navigationTitle("\(genreName)の記録")
            }
            
        }
        //TabBarを自作する
        struct TabBarView : View {
            @Binding var selectedTab : Int  //どのタブを選んでいるかの変数
            @Binding var uiColor : UIColor
            var body: some View {
                HStack {
                    Spacer()
                    Text("手動入力")
                        .foregroundColor(selectedTab == 1 ? Color.white : Color.gray)   //左が選択時で右が非選択時の色
                        .padding()
                        .background(selectedTab == 1 ? Color.blue : Color.clear)
                        .cornerRadius(10)
                        .onTapGesture {
                            self.selectedTab = 1
                        }
                    Spacer()
                    Text("ストップウォッチ")
                        .foregroundColor(selectedTab == 2 ? Color.white : Color.gray)
                        .padding()
                        .background(selectedTab == 2 ? Color.blue : Color.clear)
                        .cornerRadius(10)
                        .onTapGesture {
                            self.selectedTab = 2
                        }
                    Spacer()
                }
            }
        }
        //モーダル先の選択画面1　一番基本的な記録をする画面
        struct RecordViewManual : View{
            @Binding var genreName : String
            @Binding var uiColor : UIColor
            @Binding var selectedDate:Date
            @State private var dateFormat = "yyyy/M/d HH:mm"
            @State private var dateString = "2021-10-06T18:45:00"
            @State private var hDateModal = false //ハーフモーダルのオンオフ
            @State private var selectedHour:Int = 0     //勉強時間(時）
            @State private var selectedMinute:Int = 0  //勉強時間(分）
            @State private var timeString = "学習時間"
            @State private var hTimeModal = false //ハーフモーダルのオンオフ
            @Binding var allMinuteTime : Int //時間を全て分に直したもの
            //日付をStringに変える関数
            private func convDate() {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "ja_JP") //日本時間に設定
                dateFormatter.dateFormat = dateFormat
                dateString = dateFormatter.string(from: selectedDate)   //selectedDateからフォーマット通りに日付を変更
            }
            private func convMinute(){
                allMinuteTime = selectedMinute + (selectedHour*60)
            }
            func convMinuteHour(){
                selectedMinute = Int(allMinuteTime%60)
                selectedHour = Int(allMinuteTime/60)
            }
            var body: some View {
                VStack{
                    List{
                        HStack(spacing:20){
                            ZStack {
                                //四角を作って
                                Rectangle()
                                    .fill(Color(UIColor(named:"Background")!))
                                    .frame(width: 80, height: 80)
                                    .border(Color(UIColor(named:"Border")!), width: 1)
                                //その中を斜線で埋める
                                EasyBlockModel()
                                    .stroke(Color(uiColor), lineWidth: 2)
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    
                            }
                            .padding(0)
                            Text(genreName)
                        }
                        //2個目のリスト要素　日付選択
                        ZStack{
                            Label(
                                title:{
                                    Text(dateString)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                },
                                icon: {
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color(uiColor))
                                }
                            )
                            //ラベルを押すとハーフモーダルが出現
                            .contentShape(Rectangle())
                            .onTapGesture {
                                hDateModal.toggle()
                            }
                            //現時刻を取得するボタン
                            Button(action: {
                                selectedDate = Date()
                                convDate()
                            }) {
                                Text("現時刻")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        //日付が変わったりするたびstringにする関数動かす
                        .onAppear {
                            convDate()
                        }
                        .onChange(of: selectedDate) { newValue in
                            convDate()
                        }
                        //3個目のリスト要素　時間選択
                        HStack{
                            Label(
                                title:{
                                    if (selectedHour == 0 && selectedMinute == 0) {
                                        Text("学習時間")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    } else{
                                        Text("\(selectedHour)時間\(selectedMinute)分")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                },
                                icon: {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .foregroundColor(Color(uiColor))
                                        .rotation3DEffect(.degrees(180),
                                                          axis: (x: 0, y: 1, z: 0)) //y軸で回転させて左右反転
                                }
                            )
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        //ラベルを押すとハーフモーダルが出現
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hTimeModal.toggle()
                        }
                        .onAppear {
                            convMinute()
                            convMinuteHour()
                        }
                        .onChange(of: allMinuteTime){ _ in
                            convMinuteHour()
                        }
                        .onChange(of: selectedHour) { newValue in
                            convMinute()
                            convMinuteHour()
                        }
                        .onChange(of: selectedMinute) { newValue in
                            convMinute()
                            convMinuteHour()
                        }
                    }
                    //モーダル先の選択画面1で日付を押すと来るハーフモーダルのシート
                    .sheet(isPresented: $hDateModal) {
                        NavigationStack {
                            VStack {
                                Text("日時を選択")
                                DatePicker("", selection: $selectedDate)    //午前午後は端末の設定らしい
                                    .datePickerStyle(WheelDatePickerStyle())// 回転ホイールスタイルを指定
                                    .environment(\.locale, Locale(identifier: "ja_JP"))//日本表記にする
                            }
                            .toolbar {
                                //戻るを左上に指定
                                ToolbarItemGroup(placement: .navigationBarLeading){
                                    Button(action: {
                                        //戻るボタンを押したらshowModal=Falseになって画面が閉じる
                                        hDateModal.toggle()
                                    }, label:{
                                        Text("戻る")
                                    })
                                }
                            }
                        }.presentationDetents([.medium])    //ハーフモーダル化
                    }
                    //モーダル先の選択画面1で時間を押すと来るハーフモーダルのシート
                    .sheet(isPresented: $hTimeModal) {
                        NavigationStack {
                            //GeometryReaderは親ビューの大きさとか位置の情報をいい感じに教えてくれる
                            GeometryReader { geometry in
                                VStack {
                                    Text("時間を選択")
                                    HStack(spacing:0) {
                                        //現時点で求めるピッカーがないので手作りピッカー
                                        Picker(selection: self.$selectedHour, label: EmptyView()) {
                                            ForEach(0 ..< 24) {
                                                Text("\($0)時間")
                                            }
                                        }.pickerStyle(WheelPickerStyle())
                                        
                                        Picker(selection: self.$selectedMinute, label: EmptyView()) {
                                            ForEach(0 ..< 60) {
                                                Text("\($0)分")
                                            }
                                        }.pickerStyle(WheelPickerStyle())
                                        
                                    }
                                    .toolbar {
                                        //戻るを左上に指定
                                        ToolbarItemGroup(placement: .navigationBarLeading){
                                            Button(action: {
                                                //戻るボタンを押したらshowModal=Falseになって画面が閉じる
                                                hTimeModal.toggle()
                                            }, label:{
                                                Text("戻る")
                                            })
                                        }
                                    }
                                }
                            }
                        }.presentationDetents([.medium])    //ハーフモーダル化
                    }
                    //VStackのとこ
                }
            }
        }
    }
}
//BlockLinesView(ACLi: [Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor),Color(uiColor)])

