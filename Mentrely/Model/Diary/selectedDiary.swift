//
//  selectedDiary.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 18/08/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import Foundation
import RealmSwift

class selectedDiary: Object {
    @objc dynamic var isiDiary : String = ""
    var parentDiary  = LinkingObjects(fromType: Diary.self, property: "Items")
}
