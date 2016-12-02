//
//  MessageCenter.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/25/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import Foundation
import SocketIO
import CoreData

class MessageCenter {
    
    // singleton class
    static let sharedMessageCenter = MessageCenter()
    
    private var _socket: SocketIOClient!
    private var _contacts = Dictionary<String, Contact>()
    private var _socketId: String!
    private var _userId: String!
    private var _isConnected: Bool = false
    private var _isHandlerAdded: Bool = true
    private var _dataIsRetrieved: Bool = false
    
    private init(){
    
        self._socket = SocketIOClient(socketURL: URL(string: ipAddress)!, config: [.log(false), .forcePolling(true)])
        
        self.configureNotificationHandlers()
        
        
        self.configureHandlers(socket: _socket)
    }
    
    private func configureNotificationHandlers() {
        
        // Will disconenct with server when the application is going to terminate or enter background.
        // I do this because socket.io can is monitering all sockets that is connecting to the server,
        // when there is a disconnection happened, socket.io will remove the corresponding socket id
        // on server. In that case, I can easily find out if an application is currently connecting to
        // server, and I can choose to wether or not send a notification through APNs to the target user.
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate), name: .UIApplicationWillTerminate, object: nil)

    }
    
    private func configureHandlers(socket: SocketIOClient) {
        
        // add handlers here to deal with new messages and application bahaviors
        socket.on("connect") {data, ack in
            
            self._socketId = self._socket.sid!
            
            Debug.printEvent(withEventDescription: "socket connected with ID: \(self._socketId)", inFile: "MessageCenter.swift")
            
            // in case I forgot to setup _userId before I call this function
            guard self._userId != nil else {
                Debug.printBug(withNilValueName: "_userId", when: "emiting userId to server in message center")
                return
            }
            
            // bind user ID with socket ID on server side
            socket.emit("verifyUser", ["socketId":self._socketId, "userId":self._userId, "deviceToken":currentDeviceToken])
            
        }
        
        socket.on("connectionConfirmedByServer") {data, ack in
            
            Debug.printEvent(withEventDescription: "successfully confirmed userId: \(self._userId)", inFile: "MessageCenter.swift")
            // after confirming with the server, send this notif to other task
            NotificationCenter.default.post(name: Notification.Name("connectionConfirmed"), object: nil)
            
            self._isConnected = true
        }
        
        // MARK: - on newMessage from server
        socket.on("newMessage") {data, ack in
            if let da = data as? [Dictionary<String, String>] {
                
                Debug.printEvent(withEventDescription: "new message from server \(da[0])", inFile: "MessageCenter.swift")
                
                let newMessage = Message(content: da[0]["message"]!, type: .from, userName: da[0]["from"]!)
                
                // send a notification to contactVC and ImVC
                let userInfoDict = ["newMessage":newMessage]
                
                NotificationCenter.default.post(name: Notification.Name("newMessage"), object: nil, userInfo: userInfoDict)
                
                // store new message to message center
                self.append(toContact: newMessage.userName, withNewMessage: newMessage)
                
            } else {
                
                Debug.printBug(withDescription: "Unable to convert data from server")
                
            }
            
        }
        
        socket.on("disconnect") {data, ack in
            
            if let data = data as? [String] {
                
                // Notify ImVC so that it can change status of button and label
                NotificationCenter.default.post(name: Notification.Name("socketDisconnected"), object: nil)
                
                Debug.printEvent(withEventDescription: "disconnect with server on purpose \(data[0])", inFile: "MessageCenter.swift")
                
            }
        }
        
        socket.on("error") {data, ack in
            
            if let data = data as? [String] {
                
                // Notify ImVC so that it can change status of button and label
                NotificationCenter.default.post(name: Notification.Name("socketDisconnected"), object: nil)
                Debug.printBug(withDescription: "disconnect with server on error \(data[0])")
                
            }
        }
    }
    
    public var getSocket: SocketIOClient {
        
        return self._socket
        
    }
    
    // MARK: - append a new message to sepcific contact
    /// Will append the new message into the contact with the specific contact name.
    /// If you want to add a empty contact, use append(newContact:)
    public func append(toContact contactName: String, withNewMessage newMessage: Message) {
        
        if let contact = self._contacts[contactName] {
            
            // If there is such a contact in message center
            
            contact.append(withNewMessage: newMessage)
            
        } else {
            
            // If there is no such contact, add a new contact array to center, and notify contact view
            self._contacts[contactName] = Contact(withContactName: contactName, andMessages: [newMessage])
            
            let newContactDict = ["newContact":self._contacts[contactName]]
            
            NotificationCenter.default.post(name: NSNotification.Name("newContact"), object: nil, userInfo: newContactDict)
        }
        
        CoredataService.insert(withContactName: contactName, newMessage: newMessage)
    }
    
    // MARK: - append a single new empty contact, this method will only be called in newContactVC.swift
    /// Add a empty contact into message center
    public func append(newContact contactName: String) {
        
        if let contact = self._contacts[contactName] {
            
            Debug.printBug(withDescription: "contact already exsist when adding new contact into message center: \(contact)")
            
        } else {
            
            self._contacts[contactName] = Contact(withContactName: contactName)
            Debug.printEvent(withEventDescription: "contact added to message center: \(contactName)", inFile: "MessageCenter.swfit")
            
            let newContactDict = ["newContact":self._contacts[contactName]]
            
            NotificationCenter.default.post(name: NSNotification.Name("newContact"), object: nil, userInfo: newContactDict)
            
            CoredataService.insert(emptyContact: self._contacts[contactName]!)
        }
    }
    
    public func getMessages(fromContactName contactName: String) -> [Message] {
        
        if let contact = self._contacts[contactName] {
            return contact.getMessageRec
        } 
            
        Debug.printBug(withNilValueName: "contact", when: "getting contact in message center with contact name: \(contactName)")
        return Contact(withContactName: "Bad contact").getMessageRec
    }
    
    public func getAllContact() -> [Contact]{
        
        var contacts = [Contact]()
        
        self._contacts.forEach { (key, value) in
            contacts.append(value)
        }
        contacts.sort { (c1, c2) -> Bool in
            c1.getDate.compare(c2.getDate as Date) == .orderedDescending
        }
        return contacts
    }
    
    // MARK: - Delete contact function
    
    /// This method will call deleteContact() in CoredataService.
    /// It will delete data in both MessageCenter and - Coredata. ContactsVC need to update its data from message center after calling this function
    public func deleteContact(withContactEmail contactEmail: String) {
        Debug.printEvent(withEventDescription: "deleting contact", inFile: "MessageCenter.swift")
        CoredataService.deleteContact(withContactEmail: contactEmail)
        
        self._contacts.removeValue(forKey: contactEmail)
        
    }
    
    public var isConnected: Bool {
        return _isConnected
    }
    
    public var isHandlerAdded: Bool {
        return _isHandlerAdded
    }
    
    public func connect() {
        
        self._userId = FirebaseAuthService.sharedFIRAuthInstance.currentUserProfile.userEmail
        
        guard self._userId != nil else {
            Debug.printBug(withNilValueName: "_userId", when: "applicatoin is attempting to connect socket to server")
            return
        }
        
        guard !self.isConnected else {
            Debug.printBug(withDescription: "socket has already been connected to server")
            return
        }
        
        self._isConnected = true
        
        // if it is not the first time loading application, don't retrieve data
        if !self._dataIsRetrieved {
            self.atttempToRetrieveDataForCurrentUser {
                NotificationCenter.default.post(name: NSNotification.Name("dataRetrieved"), object: nil)
            }
            self._dataIsRetrieved = false
        }
        
        self._socket.connect()
    }
    
    // MARK: - retrieve data corresponding to the current user
    // Attemp to retrieve user object from coredata. This function will deal with both user and its corresponding data including contacts and messages
    private func atttempToRetrieveDataForCurrentUser(callback: @escaping () -> Void) {
        
        // if thers is a exsiting user stored in database, retrieve it and its relevant data (contacts message)
        var userCoredata: [UserCoreData]? = nil

        do {
            let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K == %@", "userId", self._userId)
            try userCoredata = CoredataService.getContext().fetch(fetchRequest)

        } catch {
            Debug.printBug(withDescription: "\(error) in file MEssageCenter.swift")
        }

        // Becuase user id is unique, so it's gonna be safe to retrieve oldUser[0] as the current user
        if let oldUser = userCoredata {
            if oldUser.count > 0 {
                self.attempToRetrieveData(fromUesr: self._userId)
                CoredataService.shared.setUserMO(userMO: oldUser[0])
            } else {
                let newUser = UserCoreData(context: CoredataService.getContext())
                newUser.userId = self._userId
                CoredataService.shared.setUserMO(userMO: newUser)
            }
        }
        callback()
    }
    
    // MARK: - attemp to retrieve data
    private func attempToRetrieveData(fromUesr userName: String) {
        if let retrievedContacts = CoredataService.getContactsFromCoredata(withUserName: userName) {
            for contact in retrievedContacts {
                
//                Debug.printEvent(withEventDescription: "\(contact.date)", inFile: "MessageCenter.swift")
                
                guard let contactId = contact.contactId else {
                    Debug.printBug(withNilValueName: "contactId", when: "retrieving data from coredata in MessageCenter.swif")
                    return
                }
                
                Debug.printEvent(withEventDescription: "retrieving data from coredate", inFile: "MessageCenter.swif")
                
                _contacts[contactId] = Contact(withContactName: contactId)
                if let retrievedMessages = CoredataService.getMessages(withContactName: contact.contactId!){
                    for retrievedMessage in retrievedMessages {
                        
                        let mess = Message(content: retrievedMessage.content!, typeString: retrievedMessage.type!, userName: retrievedMessage.userName!)
                        
                        _contacts[contactId]?.append(withNewMessage: mess)
                    }
                }
            }
            
            Debug.printEvent(withEventDescription: "finished loading messages from core data", inFile: "MessageCenter.swift")
            
        }
    }
    
    public func disconnect() {
        
        guard self.isConnected else {
            Debug.printBug(withDescription: "socket has already been disconnect with server")
            return
        }
        self._isConnected = false
        
        self._socket.disconnect()
    }
    
    public func setUserId(userId: String) {
        self._userId = userId
    }
    
    public var getUserId: String {
        return self._userId
    }
    
    public func clearAllMessages() {
        self._isHandlerAdded = false
        self._contacts.removeAll()
        
    }
    
    public func addNotificationHandlers() {
        self._isHandlerAdded = true
        self.configureNotificationHandlers()
    }
    
    public func removeNotificationHandlers() {
        
        Debug.printEvent(withEventDescription: "removing notification center handlebars", inFile: "MessageCenter.swift")
        NotificationCenter.default.removeObserver(self)
        
    }
    
    @objc func willEnterForeground() {
        
        Debug.printEvent(withEventDescription: "will enter foreground: self.isconnected \(self.isConnected)", inFile: "MessageCenter")
        if !self.isConnected {
            
            self.connect()
            
        }
    }
    
    @objc func willEnterBackground() {
        
        Debug.printEvent(withEventDescription: "will enter background: self.isconnected \(self.isConnected)", inFile: "MessageCenter")
        
        if self.isConnected {
            
            self.disconnect()
            
        }
    }
    
    @objc func willTerminate() {
        
        Debug.printEvent(withEventDescription: "will enter terminate: self.isconnected \(self.isConnected)", inFile: "MessageCenter")
        
        if self.isConnected {
            
            self.disconnect()
            
        }
    }
}





























