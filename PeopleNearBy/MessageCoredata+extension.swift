//
//  MessageCoredata+extension.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/21/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import Foundation
import CoreData

extension MessageCoreData {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.date = NSDate()
    }
}
