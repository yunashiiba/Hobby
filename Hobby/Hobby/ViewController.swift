//
//  ViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/07/12.
//
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    let realm = try! Realm()
    var userId = 0
    
    @IBOutlet var testLabel : UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        noticeSet()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        testLabel.text = "未ログイン"
        
        let user = realm.objects(UserData.self)
        if user.count > 0 {
            userId = user[0].id
            testLabel.text = String(userId)
        }else{
            performSegue(withIdentifier: "toStart", sender: self)
        }
        
        let encount = realm.objects(EncountHobby.self)
        print(encount)
    }
    
    @IBAction func encount(){
        encounted(id1: userId, id2: 1, x:10.1,y: 10.1) { result in
            DispatchQueue.main.async {
                print("aaaaa")
                print(result)
            }
        }
    }
    
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
    }


}
