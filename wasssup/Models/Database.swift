//
//  Database.swift
//  wasssup
//
//  Created by Lawrence Gimenez on 01/05/2017.
//  Copyright © 2017 Law Gimenez. All rights reserved.
//

import UIKit
import RealmSwift

class Database {
    
    public func getAllMessages() -> [Message] {
        let realm = try! Realm()
        let messages = realm.objects(Message.self)
        return Array(messages)
    }
    
    public func saveMessage(message: Message) {
        let realm = try! Realm()
        try! realm.write {
            realm.create(Message.self, value: message, update: true)
        }
    }
}
