//
//  ImVC+observe.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/16/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import SocketIO

extension ImVC {
    
//    func configObserver() {
        
        
//        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(willEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate), name: .UIApplicationWillTerminate, object: nil)
//        
//    }
    
    func configureNotificationCenter() {
        
        // observe when keyboard will move
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.newMessageReceived(_:)), name: Notification.Name("newMessage"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.socketDisconnected), name: Notification.Name("socketDisconnected"), object: nil)
        
    }
    
    func newMessageReceived(_ notification: NSNotification) {
        
        Debug.printEvent(withEventDescription: "new message receive from notification center: \(notification.userInfo)", inFile: "ImVC+observe.swift")
        
        if let newMessage = notification.userInfo?["newMessage"] as? Message {
            
            self.messages.append(newMessage)
            self.heightOfMessages.append(0.0)
            self.messageTable.reloadData()
            
        }
    }
    
    func socketDisconnected() {
        
        self.turnOffConnectionStatus()
        
    }
    
//    func configSocket(socket: SocketIOClient) {
    
        // I can actually have multiple observer in different object in application, socket will notify all of them 
        // when corresponding event happened
        
//        socket.on("connect") {data, ack in
//            
//            self.socketId = self.socket.sid!
//            print("$debug socket connected \(self.socketId!)")
//            
//            socket.emit("verifyUser", ["socketId":self.socketId, "userId":self.userId, "deviceToken":currentDeviceToken])
//            
//        }
//        
//        socket.on("connectionConfirmedByServer") {data, ack in
//            
//            self.turnOnConnectionStatus()// trun on the connection status
//            
//        }
        
//        socket.on("newMessage") {data, ack in
//            
//            if let da = data as? [Dictionary<String, String>] {
//                
//                print("$debug \(da)")
//                
//                let newMessage = Message(content: da[0]["message"]!, type: .from, userName: da[0]["from"]!)
//                
//                self.messageCenter.append(toContact: newMessage.userName, withNewMessage: newMessage)
//                
//                self.messages.append(newMessage)
//                self.heightOfMessages.append(0.0)
//                
//                // core data down here
//                
////                let newMessage = MessageCoreData(context: context)
////                newMessage.from = da[0]["from"]!
////                newMessage.to = self.userId
////                newMessage.content = da[0]["message"]!
////                ad.saveContext()
//                
//                self.messageTable.reloadData()
//                
//                self.scrollToBottom()
//                
//            } else {
//                
//                print("$debug convertion failed")
//            }
//        }
        
//        socket.on("disconnect") {data, ack in
//            
//            if let data = data as? [String] {
//                
//                self.turnOffConnectionStatus()
//                Debug.printEvent(withEventDescription: "disconnect with server on purpose \(data[0])", inFile: "ImVC+observe.swift")
//                
//            }
//        }
//        
//        socket.on("error") {data, ack in
//            
//            if let data = data as? [String] {
//                
//                self.turnOffConnectionStatus()
//                
//                Debug.printBug(withDescription: "disconnect with server on error \(data[0])")
//                
//            }
//        }
//    }
}
