//
//  CoredataService.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/30/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import Foundation
import CoreData

class CoredataService {
    private var _userMO: UserCoreData!
    private init () {}
    
    public func setUserMO(userMO: UserCoreData) {
        self._userMO = userMO
    }
    
    public var userMO: UserCoreData {
        if self._userMO == nil {
            Debug.printBug(withNilValueName: "userMO", when: "using user MO to set up relationship in file CoredataService.swift")
        }
        return self._userMO
    }
    
    static let shared = CoredataService()
    
    // MARK: - insert a new message into a specific contact
    /// This method will insert a new message object into database, and update everything with the corresponding contact object. If the contact not already exsisted in the database, this method will create the corresponding method
    static func insert(withContactName contactName: String, newMessage: Message?) {
        
        Debug.printEvent(withEventDescription: "inserting new contact: \(contactName) and newMessage: \(newMessage?.content) to coredata", inFile: "CoredadtaService.swift")
        
        let fetchRequest: NSFetchRequest<Contacts> = Contacts.fetchRequest()
        // predicate: get contact that match both contactName and useId
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@", "contactId", contactName, "toUserCoreData.userId", CoredataService.shared.userMO.userId!)
        // add toUser and append toMessage
        fetchRequest.predicate = predicate
        var res: [Contacts]? = nil
        
        do {
            
            res = try CoredataService.getContext().fetch(fetchRequest)
            
        } catch {
            Debug.printBug(withNilValueName: "\(error) found with contactName: \(contactName) userId: \(CoredataService.shared.userMO.userId!)", when: "fetching data from contact in CoredataService.swift")
        }
        
        var currentContact: Contacts!
        
        // if corresponding contact found
        if let res = res {
            if res.count > 0 {
                currentContact = res[0]
            } else {
                // if not found, create a new one
                let newContact = Contacts(context: CoredataService.getContext())
                newContact.contactId = contactName
                newContact.date = NSDate()
                newContact.toUserCoreData = CoredataService.shared.userMO
                
                currentContact = newContact
            }
        }
        
        // create corresponding message coreadate object
        let newMess = MessageCoreData(context: CoredataService.getContext())
        
        newMess.content = newMessage?.content
        newMess.date = newMessage?.date
//        newMess.toContact = currentContact // this is a inverse relationship
        
        if newMessage?.type == .from {
            newMess.type = "from"
        } else {
            newMess.type = "to"
        }
        
        newMess.userName = newMessage?.userName
        
        currentContact.addToToMessageCoreData(newMess)
        currentContact.date = newMess.date
        
    }
    
    // MARK: - Insert a new empty contact
    /// This method will create a empty contact with NSDate()
    static func insert(emptyContact contact: Contact) {
        
        Debug.printEvent(withEventDescription: "inserting new contact: \(contact.getContactName) to coredata", inFile: "CoredadtaService.swift")
        
        let newEmptyContact = Contacts(context: CoredataService.getContext())
        newEmptyContact.contactId = contact.getContactName
        newEmptyContact.date = contact.getDate
        // add modify to user attribute
        newEmptyContact.toUserCoreData = CoredataService.shared.userMO
    }
    
    // MARK: - Retrieve Messages With Contact Name
    static func getMessages(withContactName contactName: String) -> [MessageCoreData]? {
        
        // https://code.tutsplus.com/tutorials/core-data-and-swift-relationships-and-more-fetching--cms-25070
        let fetchRequest: NSFetchRequest<MessageCoreData> = MessageCoreData.fetchRequest()
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let predicate = NSPredicate(format: "%K == %@", "toContact.contactId", contactName)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        var res: [MessageCoreData]?
        do {
            try res = CoredataService.getContext().fetch(fetchRequest)
        } catch {
            Debug.printBug(withDescription: "\(error)")
        }
        return res
    }
    
    // MARK: - Retrieve Contacts
    static func getContactsFromCoredata(withUserName userName: String) -> [Contacts]? {
        
        let fetchRequest: NSFetchRequest<Contacts> = Contacts.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "toUserCoreData.userId", userName)
        
        var res: [Contacts]?
        
        do {
             res = try CoredataService.getContext().fetch(fetchRequest)
        } catch {
            Debug.printBug(withDescription: "\(error)")
            res = nil
        }
        return res
    }
    
    // MARK: - Delete contact function 
    /// Calling this function will delete this contact and all corresponding messages
    static func deleteContact(withContactEmail contactEmail: String) {
        let fetchRequest: NSFetchRequest<Contacts> = Contacts.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", "contactId", contactEmail)
        fetchRequest.predicate = predicate
        
        // Bcause there must such a contact, force try is ok
        let contactToDelete = try! CoredataService.getContext().fetch(fetchRequest)
        CoredataService.getContext().delete(contactToDelete[0])
    }
    
    // MARK: - Get Context function
    static func getContext() -> NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    // MARK: - Core Data stack
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "PeopleNearBy")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
