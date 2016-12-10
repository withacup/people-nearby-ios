//
//  UserCoreData+CoreDataProperties.swift
//  
//
//  Created by Tianxiao Yang on 11/30/16.
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
    @NSManaged public var toContacts: NSSet?

}

// MARK: Generated accessors for toContacts
extension UserCoreData {

    @objc(addToContactsObject:)
    @NSManaged public func addToToContacts(_ value: Contacts)

    @objc(removeToContactsObject:)
    @NSManaged public func removeFromToContacts(_ value: Contacts)

    @objc(addToContacts:)
    @NSManaged public func addToToContacts(_ values: NSSet)

    @objc(removeToContacts:)
    @NSManaged public func removeFromToContacts(_ values: NSSet)

}
