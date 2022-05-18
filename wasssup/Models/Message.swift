//
//  Message.swift
//  wasssup
//
//  Created by Lawrence Gimenez on 01/05/2017.
//  Copyright © 2017 Law Gimenez. All rights reserved.
//

import UIKit
import RealmSwift

class Message: Object {
    
    dynamic var messageId: String?
    dynamic var date: String?
    dynamic var userId: String?
    dynamic var content: String?
    dynamic var username: String?
    
    override class func primaryKey() -> String {
        return "messageId"
    }
}
