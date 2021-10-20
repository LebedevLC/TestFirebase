//
//  FireBaseTestModel.swift
//  FireBase(HomeWork_8)
//
//  Created by Сергей Чумовских  on 19.10.2021.
//

import Foundation
import Firebase

class FireBaseTestModel {

    let name: String
    let number: Int
    let ref: DatabaseReference?
    
    init(name: String, number: Int) {
        self.ref = nil
        self.name = name
        self.number = number
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: Any],
            let number = value["number"] as? Int,
            let name = value["name"] as? String else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.name = name
        self.number = number
    }
    
    func toAnyObject() -> [String: Any] {
        return [
            "name": name,
            "number": number
        ]
    }
    
    func toFirestore() -> [String: Any] {
        return [
            name : number
//         UUID().uuidString : number
        ]
    }
}
