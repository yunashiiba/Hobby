//
//  Encounter.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/04.
//

import Foundation
import RealmSwift

struct EncounterData: Encodable {
    let id1: Int
    let id2: Int
    let x: Float
    let y: Float
}

func encounted(id1: Int, id2: Int, x: Float, y: Float, completion: @escaping (Int) -> Void) {
    
    let datas = EncounterData(id1: id1, id2: id2, x: x, y: y)
    
    guard let url = URL(string: urlset() + "encounter") else {
        print("Invalid URL")
        completion(0)
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
        let jsonData = try JSONEncoder().encode(datas)
        request.httpBody = jsonData
    } catch {
        print("Error encoding JSON: \(error)")
        completion(0)
        return
    }
    
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 15
    let session = URLSession(configuration: config)
    
    let task = session.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Network Error: \(error.localizedDescription)")
            completion(0)
            return
        }
        
        guard let data = data else {
            print("No data received")
            completion(0)
            return
        }
        
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
            if let dataArray = jsonData as? [String] {
                DispatchQueue.main.async {
                    if dataArray.count > 0 {
                        print("Received data: \(dataArray)")
                        completion(2)
                        toRealmEncount(data: dataArray)
                    } else {
                        print("noHobby")
                        completion(1)
                    }
                }
            } else {
                print("Failed to parse JSON")
                completion(0)
            }
        } catch {
            print("Error decoding response: \(error.localizedDescription)")
            completion(0)
        }
    }
    
    task.resume()
}


func toRealmEncount(data: [String]){
    let realm = try! Realm()
    for i in 0..<data.count/7 {
        try! realm.write {
            let encount = Encount()
            encount.id = (realm.objects(Encount.self).max(ofProperty: "id") as Int? ?? 0) + 1
            encount.hobby = data[7*i]
            encount.color = data[7*i + 1]
            encount.country = Int(data[7*i + 2])!
            encount.user = Int(data[7*i + 3])!
            encount.encountDay = Date()
            realm.add(encount)
            
            for j in 4...6 {
                if data[7*i + j] != "" && data[7*i + j] != data[7*i] {
                    let encounthobby = EncountHobby()
                    encounthobby.hobby = data[7*i + j]
                    encounthobby.encount = encount.id
                    encounthobby.motherhobby = data[7*i]
                    realm.add(encounthobby)
                }
            }
        }
    }
}
