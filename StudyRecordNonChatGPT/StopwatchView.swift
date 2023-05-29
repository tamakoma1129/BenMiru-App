import SwiftUI

//ストップウォッチ
/*
 スタート、ストップ、リセット機能完備。
 実行中にバックグラウンドに行くとタイマーが停止され、Userdefaultに現在時刻が保存される。
 バックからフォアグラウンドに戻ると現在時刻が取得され、Userdefaultに保存された時間との差分をタイマーに加算し、タイマーが再開する。
 */
struct StopwatchView: View {
    @Binding var allMinuteTime : Int
    @StateObject private var viewModel: StopwatchViewModel
    
    init(allMinuteTime: Binding<Int>) {
        _allMinuteTime = allMinuteTime
        _viewModel = StateObject(wrappedValue: StopwatchViewModel(updateAllMinuteTime: allMinuteTime))
    }

    var body: some View {
        VStack {
            //経過時間を表示
            Text(viewModel.displayTime)
                .font(.system(size: 50))
                .padding()
            
            HStack {
                //スタート
                Button(action: { viewModel.start() }) {
                    Text("Start")
                }
                .padding()
                //ストップ
                Button(action: { viewModel.stop() }) {
                    Text("Stop")
                }
                .padding()
                //リセット
                Button(action: { viewModel.reset() }) {
                    Text("Reset")
                }
                .padding()
            }
        }//UIApplication.willResignActiveNotificationがバックグラウンドに移る際に出る通知。それを受け取ってviewModel.appMovedToBackground()メソッドを呼んでる。
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            viewModel.appMovedToBackground()
        }//こちらは上のフォアグラウンドに戻ってきた時ver
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.appMovedToForeground()
        }
    }
}
//ストップウォッチの機能を追加するためのクラス
class StopwatchViewModel: ObservableObject {
    @Published var displayTime: String = "00:00:00"
    var updateAllMinuteTime: ((Int) -> Void)?
    private var timer: Timer? = nil
    private var timeInterval: TimeInterval = 0.0
    private var backgroundEntryDate: Date? = nil
    private var isRunning: Bool = false //ストップウォッチが動作してるか否かのフラグ
    init(updateAllMinuteTime: Binding<Int>) {
        self.updateAllMinuteTime = { newTime in updateAllMinuteTime.wrappedValue = newTime }
    }
    //スタート関数
    func start() {
        timer?.invalidate() //invalidateは起動しているタイマーを削除するメソッド。削除してもすぐ下の行でスタートするから誤差は無いに等しい。
        //scheduledTimerは指定した間隔（今回は0.01秒）で指定した処理を行うというもの
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in  //weak selfはメモリを安全に使うためのあーだこーだ
            //timeInterval=経過時間
            self?.timeInterval += 0.01
            self?.updateAllMinuteTime?(Int(Int(self?.timeInterval ?? 0.0)/60))
            //表示する時間を更新する
            self?.updateDisplayTime()
        }
        isRunning = true
    }
    //ストップ関数
    func stop() {
        timer?.invalidate() //起動中のタイマーを削除＝停止
        timer = nil
        isRunning = false
    }
    //リセット関数
    func reset() {
        stop()  //上のストップ関数を起動
        timeInterval = 0.0  //トータル時間を0に
        updateDisplayTime() //描写を更新するために変数を更新
    }
    //バックグラウンドに移ったときの関数
    func appMovedToBackground() {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "backgroundEntryDate")
        UserDefaults.standard.set(timeInterval, forKey: "timeInterval")
        UserDefaults.standard.set(isRunning, forKey: "isRunning")
        stop()
    }
    //フォアグラウンドに移ったときの関数
    func appMovedToForeground() {
        let storedDate = UserDefaults.standard.double(forKey: "backgroundEntryDate")//バックグラウンドに入った時の時間
        let storedTimeInterval = UserDefaults.standard.double(forKey: "timeInterval")//何秒起動してたか
        let isRunning = UserDefaults.standard.bool(forKey: "isRunning")//ストップウォッチが起動してたか否か
        let timeDifference = Date().timeIntervalSince1970 - storedDate
        timeInterval = storedTimeInterval + (isRunning ? timeDifference : 0.0)
        updateDisplayTime()//得た情報からデータを更新
        if isRunning {
            start()
        }
    }
    //データを更新する時の関数
    private func updateDisplayTime() {
        let totalSeconds = Int(timeInterval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        displayTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}