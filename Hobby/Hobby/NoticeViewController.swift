//
//  NoticeViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/05.
//

import UIKit
import RealmSwift

class NoticeViewController: UIViewController {
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        let now = Date()
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
        let recentRecords = realm.objects(Encount.self).filter("encountDay >= %@", twentyFourHoursAgo)
    }
    
}


func noticeSet() {
    let realm = try! Realm()
    let now = Date()
    let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
    let recentRecords = realm.objects(Encount.self).filter("encountDay >= %@", twentyFourHoursAgo)
    
    //　通知設定に必要なクラスをインスタンス化
    let trigger: UNNotificationTrigger
    let content = UNMutableNotificationContent()
    var notificationTime = DateComponents()
    
    // トリガー設定
    notificationTime.hour = 20
    notificationTime.minute = 54
    trigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: true)
    
    // 通知内容の設定
    content.title = "やあ"
    content.sound = UNNotificationSound.default
    if recentRecords.count > 0{
        content.body = "今日は" + String(recentRecords.count) + "人と遭遇したよ"
    }else{
        content.body = "今日は遭遇しなかったよ"
    }
    
    // 通知スタイルを指定
    let request = UNNotificationRequest(identifier: "uuid", content: content, trigger: trigger)
    // 通知をセット
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}
