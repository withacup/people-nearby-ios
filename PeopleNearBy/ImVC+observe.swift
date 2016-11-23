//
//  ImVC+extensions.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/16/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import SocketIO

extension ImVC {
    
    func configObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate), name: .UIApplicationWillTerminate, object: nil)
        
    }
    
    func configSocket(socket: SocketIOClient) {
        
        socket.on("connect") {data, ack in
            
            self.socketId = self.socket.sid!
            print("$debug socket connected \(self.socketId!)")
            
            socket.emit("verifyUser", ["socketId":self.socketId, "userId":self.userId, "deviceToken":currentDeviceToken])
            
        }
        
        socket.on("connectionConfirmedByServer") {data, ack in
            
            self.turnOnConnectionStatus()// trun on the connection status
            
        }
        
        socket.on("newMessage") {data, ack in
            
            if let da = data as? [Dictionary<String, String>] {
                
                print("$debug \(da)")
                self.messages.append(Message(content: da[0]["message"]!, type: .from, userName: da[0]["from"]!))
                self.heightOfMessages.append(0.0)
                
                // core data down here
                
                let newMessage = MessageCoreData(context: context)
                newMessage.from = da[0]["from"]!
                newMessage.to = self.userId
                newMessage.content = da[0]["message"]!
//                ad.saveContext()
                
                self.messageTable.reloadData()
                
                self.scrollToBottom()
                
            } else {
                
                print("$debug convertion failed")
            }
        }
        
        socket.on("disconnect") {data, ack in
            
            if let data = data as? [String] {
                
                print("$debug disconnected on purpose")
                
//                self.status.title = data[0]
                
                self.turnOffConnectionStatus()
                
            }
        }
        
        socket.on("error") {data, ack in
            
            if let data = data as? [String] {
                
                print("$debug disconnected on error")
//                self.status.title = data[0]
                self.turnOffConnectionStatus()
                
            }
        }
    }
}
