//
//  ImVC+changeStatus.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/16/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit

extension ImVC {
    /// will disable send button, cahgne status bar
    func turnOffConnectionStatus() {
        
        self.statusLbl.text = "Connecting..."
        self.sendBtn.isEnabled = false
        
        
    }
    /// Will enable send button, set socket, set userId, change status bar
    func turnOnConnectionStatus() {
        
        self.statusLbl.text = "Connected"
        self.sendBtn.isEnabled = true
        self.socket = messageCenter.getSocket
        
        self.userId = self.messageCenter.getUserId
    }
}
    
    // moved to MessageCenter.swift
    
//    func willEnterForeground() {
//        turnOffConnectionStatus()
//        socket.connect()
//    }
//    
//    func willEnterBackground() {
//        if socket.status != .disconnected {
//            socket.removeAllHandlers()
//            socket.disconnect()
//        }
//    }
//    
//    func willTerminate() {
//        if socket.status != .disconnected {
//            socket.removeAllHandlers()
//            socket.disconnect()
//        }
//    }
