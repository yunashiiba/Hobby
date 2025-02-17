//
//  Signup4ViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/07/31.
//

import UIKit

class Signup4ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    
    @IBOutlet weak var HobbyPickerView: UIPickerView!
    @IBOutlet var SearchTextfield: UITextField!
    @IBOutlet weak var alartLabel: UILabel!
    @IBOutlet var createButton: UIButton!
    
    var results: [String] = []
    var buttons: [UIButton] = []
    var labels: [UILabel] = []
    
    var selected = 0
    
    var hobby: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        HobbyPickerView.delegate = self
        HobbyPickerView.dataSource = self
        
        for i in 1...3 {
            let button = self.view.viewWithTag(i) as! UIButton
            let label = self.view.viewWithTag(i + 3) as! UILabel
            button.addTarget(self, action: #selector(Signup4ViewController.tap), for: .touchUpInside)
            buttons.append(button)
            labels.append(label)
        }
        
        connect()
    }
    
    @objc func tap(_ sender: UIButton) {
        results[sender.tag + 5] = ""
        labelset()
    }
    
    func labelset() {
        let subArray = Array(results[6...8])
        let nonEmptyStrings = subArray.filter { !$0.isEmpty }
        let emptyStrings = subArray.filter { $0.isEmpty }
        let sortedSubArray = nonEmptyStrings + emptyStrings
        
        createButton.isEnabled = !nonEmptyStrings.isEmpty
        results.replaceSubrange(6...8, with: sortedSubArray)
        
        for i in 0...2 {
            labels[i].text = results[i + 6]
            buttons[i].isHidden = labels[i].text == ""
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hobby.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return hobby[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selected = row
    }
    
    func connect() {
        waitingAnimation(Motherview: self.view)
        fetch(url: "request_hobby") { [weak self] hobbies, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to fetch user IDs: \(error)")
                    self.neterror(id: 0)
                    return
                }
                if let hobbies = hobbies as? [[Any]] {
                    if !hobbies.isEmpty {
                        var datas: [(String, Int)] = []
                        for hobby in hobbies {
                            if let hobbyName = hobby[0] as? String, let hobbyCount = hobby[1] as? Int {
                                datas.append((String(hobbyName), hobbyCount))
                            }
                        }
                        datas.sort { $0.1 > $1.1 }
                        
                        self.hobby = datas.map { $0.0 }
                        self.HobbyPickerView.reloadAllComponents()
                        self.labelset()
                        
                        for _ in 0...3 {
                            let remove = self.view.viewWithTag(100)
                            remove?.removeFromSuperview()
                        }
                        print("User IDs: \(hobbies)")
                    }
                } else {
                    print("No user IDs found")
                    self.neterror(id: 0)
                }
            }
        }
    }
    
    func connect2() {
        waitingAnimation(Motherview: self.view)
        guard let url = URL(string: urlset() + "request_usercreate") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(results)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user: \(error)")
            DispatchQueue.main.async {
                self.neterror(id: 2)
            }
            return
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                DispatchQueue.main.async {
                    self.neterror(id: 2)
                }
                return
            }
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.neterror(id: 2)
                }
                return
            }
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                let userdata = jsonData as? [String]
                if userdata != nil && userdata!.count == 9  {
                    print(userdata!)
                    
                    DispatchQueue.main.async {
                        toRealm(data: userdata!)
                        self.performSegue(withIdentifier: "unwindToMain", sender: self)
                    }
                } else {
                    self.neterror(id: 2)
                    print("Failed to parse JSON")
                }
            } catch {
                DispatchQueue.main.async {
                    self.neterror(id: 2)
                    print("Error decoding response: \(error)")
                }
            }
        }
        task.resume()
    }
    
    func neterror(id: Int) {
        for _ in 0...3 {
            let remove = self.view.viewWithTag(100)
            remove?.removeFromSuperview()
        }
        
        let alertView = UIAlertController(
            title: "エラー",
            message: "ネットワークエラーです",
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default) {_ in
            self.performSegue(withIdentifier: "unwindToStart", sender: self)
        }
        let reaction = UIAlertAction(title: "再読み込み", style: .default) {_ in
            if id == 0 {
                self.connect()
            } else {
                self.connect2()
            }
        }
        alertView.addAction(action)
        alertView.addAction(reaction)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func hobbySearch(){
        if let newHobby = SearchTextfield?.text, !newHobby.isEmpty {
            if let index = self.hobby.firstIndex(of: newHobby) {
                self.HobbyPickerView.selectRow(index, inComponent: 0, animated: true)
                selected = index
                self.HobbyPickerView.reloadAllComponents()
                alartLabel.text = ""
            }else{
                alartLabel.text = "ないです"
            }
        }
    }
    
    @IBAction func hobbySerect(){
        let subArray = Array(results[6...8])
        let nonEmptyStrings = subArray.filter { !$0.isEmpty }
        var emptyStrings = subArray.filter { $0.isEmpty }
        if emptyStrings.count > 0 {
            if nonEmptyStrings.contains(hobby[selected]) {
                alartLabel.text = "被ってます"
            }else{
                emptyStrings[0] = hobby[selected]
                alartLabel.text = ""
            }
        }else{
            alartLabel.text = "3つまでです"
        }
        let sortedSubArray = nonEmptyStrings + emptyStrings
        results.replaceSubrange(6...8, with: sortedSubArray)
        
        labelset()
    }
    
    @IBAction func hobbyCreate() {
        let alertView = UIAlertController(
            title: "Hobbyを追加",
            message: "",
            preferredStyle: .alert)
        var textField: UITextField?
        alertView.addTextField { alertTextField in
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            if let newHobby = textField?.text, !newHobby.isEmpty {
                if let index = self.hobby.firstIndex(of: newHobby) {
                    self.selected = index
                    self.HobbyPickerView.selectRow(index, inComponent: 0, animated: true)
                } else {
                    self.hobby.append(newHobby)
                    self.HobbyPickerView.reloadAllComponents()
                    self.selected = self.hobby.count - 1
                    self.HobbyPickerView.selectRow(self.hobby.count - 1, inComponent: 0, animated: true)
                }
                self.HobbyPickerView.reloadAllComponents()
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)

        alertView.addAction(action)
        alertView.addAction(cancelAction)
        present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func create(){
        connect2()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToSignup3" {
            if let destinationVC = segue.destination as? Signup3ViewController {
                destinationVC.results = results
            }
        }
    }
    
    @IBAction func back(_ sender: UIStoryboardSegue) {
            performSegue(withIdentifier: "unwindToSignup3", sender: self)
        }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}
