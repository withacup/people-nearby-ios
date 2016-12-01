//
//  Contacts+CoreDataProperties.swift
//  
//
//  Created by Tianxiao Yang on 11/30/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Contacts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contacts> {
        return NSFetchRequest<Contacts>(entityName: "Contacts");
    }

    @NSManaged public var contactId: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var toMessageCoreData: NSSet?
    @NSManaged public var toUserCoreData: UserCoreData?

}

// MARK: Generated accessors for toMessageCoreData
extension Contacts {

    @objc(addToMessageCoreDataObject:)
    @NSManaged public func addToToMessageCoreData(_ value: MessageCoreData)

    @objc(removeToMessageCoreDataObject:)
    @NSManaged public func removeFromToMessageCoreData(_ value: MessageCoreData)

    @objc(addToMessageCoreData:)
    @NSManaged public func addToToMessageCoreData(_ values: NSSet)

    @objc(removeToMessageCoreData:)
    @NSManaged public func removeFromToMessageCoreData(_ values: NSSet)

}
