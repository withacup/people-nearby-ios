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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.turnOnConnectionStatus), name: Notification.Name("connectionConfirmed"), object: nil)
    }
    
    func newMessageReceived(_ notification: NSNotification) {
        
        Debug.printEvent(withEventDescription: "new message receive from notification center: \(notification.userInfo)", inFile: "ImVC+observe.swift")
        
        if let newMessage = notification.userInfo?["newMessage"] as? Message {
            if newMessage.userName == self.toUser.text! {
                self.messages.append(newMessage)
                self.messages.sort { (m1, m2) -> Bool in
                    m1.date.compare(m2.date as Date) == .orderedAscending
                }
                self.heightOfMessages.append(0.0)
                self.messageTable.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
    func socketDisconnected() {
        
        self.turnOffConnectionStatus()
        
    }
}
