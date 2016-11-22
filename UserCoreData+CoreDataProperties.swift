//
//  UserCoreData+CoreDataProperties.swift
//  
//
//  Created by Tianxiao Yang on 11/22/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension UserCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserCoreData> {
        return NSFetchRequest<UserCoreData>(entityName: "UserCoreData");
    }

    @NSManaged public var userId: String?
    @NSManaged public var toMessageCoreData: NSSet?

}

// MARK: Generated accessors for toMessageCoreData
extension UserCoreData {

    @objc(addToMessageCoreDataObject:)
    @NSManaged public func addToToMessageCoreData(_ value: MessageCoreData)

    @objc(removeToMessageCoreDataObject:)
    @NSManaged public func removeFromToMessageCoreData(_ value: MessageCoreData)

    @objc(addToMessageCoreData:)
    @NSManaged public func addToToMessageCoreData(_ values: NSSet)

    @objc(removeToMessageCoreData:)
    @NSManaged public func removeFromToMessageCoreData(_ values: NSSet)

}
