//
//  Diary.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 18/08/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import Foundation
import RealmSwift

class Diary: Object {
    @objc dynamic var namaDiary : String = ""
    @objc dynamic var tanggalDiary : Date?
      let Items = List<selectedDiary>()
}
