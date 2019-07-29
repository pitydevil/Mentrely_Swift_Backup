//
//  reminder.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 28/07/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import Foundation
import RealmSwift

class reminder: Object {

@objc dynamic var daily : String = ""
@objc dynamic var date : Date?

}
