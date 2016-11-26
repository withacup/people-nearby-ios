//
//  MessageCenter.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/25/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import Foundation
import SocketIO

class MessageCenter {
    
    // singleton class
    static let sharedMessageCenter = MessageCenter()
    
    private var _socket: SocketIOClient!
    private var _contacts = Dictionary<String, Contact>()
    private var _socketId: String!
    private var _userId: String!
    private var _isConnected: Bool = false
    
    private init(){
    
        self._socket = SocketIOClient(socketURL: URL(string: ipAddress)!, config: [.log(false), .forcePolling(true)])
        
        // Will disconenct with server when the application is going to terminate or enter background.
        // I do this because socket.io can is monitering all sockets that is connecting to the server,
        // when there is a disconnection happened, socket.io will remove the corresponding socket id
        // on server. In that case, I can easily find out if an application is currently connecting to
        // server, and I can choose to wether or not send a notification through APNs to the target user.
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate), name: .UIApplicationWillTerminate, object: nil)
        
        self.configureHandlers(socket: _socket)
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
            
            self._isConnected = true
        }
        
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
    
    public func append(toContact contactName: String, withNewMessage newMessage: Message) {
        
        if let contact = self._contacts[contactName] {
            
            // If there is such a contact in message center
            
            contact.append(withNewMessage: newMessage)
            
        } else {
            
            // If there is no such contact, add a new contact array to center, and notify contact view
            self._contacts[contactName] = Contact(withContactName: contactName, andMessages: [newMessage])
            
            let newContactDict = ["newContactName":contactName]
            
            NotificationCenter.default.post(name: NSNotification.Name("newContactName"), object: nil, userInfo: newContactDict)
        }
    }
    
    public func append(newContact contactName: String) {
        
        if let contact = self._contacts[contactName] {
            
            Debug.printBug(withDescription: "contact already exsist when adding new contact into message center: \(contact)")
            
        } else {
            
            self._contacts[contactName] = Contact(withContactName: contactName)
            Debug.printEvent(withEventDescription: "contact added to message center: \(contactName)", inFile: "MessageCenter.swfit")
        }
    }
    
    public func getMessages(fromContactName contactName: String) -> [Message] {
        
        if let contact = self._contacts[contactName] {
            return contact.getMessageRec
        } 
            
        Debug.printBug(withNilValueName: "contact", when: "getting contact in message center with contact name: \(contactName)")
        return Contact(withContactName: "Bad contact").getMessageRec
        
    }
    
    public func getAllContactNames() -> [String]{
        
        var contactNames = [String]()
        
        self._contacts.forEach { (key, value) in
            contactNames.append(key)
        }
        return contactNames
    }
    
    public var isConnected: Bool {
        return _isConnected
    }
    
    public func connect() {
        
        guard self._userId != nil else {
            Debug.printBug(withNilValueName: "_userId", when: "applicatoin is attempting to connect socket to server")
            return
        }
        
        guard !self.isConnected else {
            Debug.printBug(withDescription: "socket has already been connected to server")
            return
        }
        
        self._isConnected = true
        
        self._socket.connect()
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
        
        self._contacts.removeAll()
        
    }
    
    public func removeNotificationHandlers() {
        
        Debug.printEvent(withEventDescription: "removing notification center handlebars", inFile: "MessageCenter.swift")
        NotificationCenter.default.removeObserver(self)
        
    }
    
    @objc func willEnterForeground() {
        
//        Debug.printEvent(withEventDescription: "applicatoin will enter foreground with userId: \(self._userId)", inFile: "MessageCenter")
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





























