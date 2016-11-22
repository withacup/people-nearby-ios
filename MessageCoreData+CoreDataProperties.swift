//
//  MessageCoreData+CoreDataProperties.swift
//  
//
//  Created by Tianxiao Yang on 11/22/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension MessageCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageCoreData> {
        return NSFetchRequest<MessageCoreData>(entityName: "MessageCoreData");
    }

    @NSManaged public var from: String?
    @NSManaged public var to: String?
    @NSManaged public var content: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var toUserCoreData: UserCoreData?

}
