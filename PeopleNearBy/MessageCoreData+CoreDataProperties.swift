//
//  MessageCoreData+CoreDataProperties.swift
//  
//
//  Created by Tianxiao Yang on 11/30/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension MessageCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageCoreData> {
        return NSFetchRequest<MessageCoreData>(entityName: "MessageCoreData");
    }

    @NSManaged public var content: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var type: String?
    @NSManaged public var userName: String?
    @NSManaged public var toContact: Contacts?

}
