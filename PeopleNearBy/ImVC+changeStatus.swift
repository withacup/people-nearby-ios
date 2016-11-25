//
//  ImVC+changeStatus.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/16/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit

extension ImVC {

    func turnOffConnectionStatus() {
        
//        self.statusTextView.text = "Connecting ..."
//        self.statusTextView.textColor = UIColor.red
//        self.status.title = "Connecting.."
        
        self.statusLbl.text = "Connecting..."
        self.sendBtn.isEnabled = false
        
        
    }
    
    func turnOnConnectionStatus() {
        
//        self.statusTextView.text = "Connected!"
//        self.statusTextView.textColor = UIColor.green
//        self.status.title = "Connected!"
        
        self.statusLbl.text = "Connected"
        self.sendBtn.isEnabled = true
        
    }
    
    func willEnterForeground() {
        turnOffConnectionStatus()
        socket.connect()
    }
    
    func willEnterBackground() {
        socket.disconnect()
    }
    
    func willTerminate() {
        socket.disconnect()
    }
}
