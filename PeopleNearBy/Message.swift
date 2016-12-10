//
//  Message.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/17/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import Foundation

enum messageType {
    case from
    case to
}

class Message {
    
    private var _content:String!
    private var _type: messageType!
    private var _date: NSDate!
    
    // _userName variable represents the sender's name that sent the this message to current user
    private var _userName: String!
    
    init(content:String, type: messageType, userName: String) {
        _content = content
        _type = type
        _userName = userName
        _date = NSDate()
    }
    
    init(content:String, typeString: String, userName: String) {
        _content = content
        
        if typeString == "from" {
            _type = .from
        } else {
            _type = .to
        }
        
        _userName = userName
        _date = NSDate()
    }
    
    var content:String {
        
        if _content == nil {
            
            _content = "No content with this message"
        }
        return _content
    }
    
    var type: messageType {
        
        if _type == nil {
            
            _type = .from
            
        }
        return _type
    }
    
    var userName: String {
        
        if _userName == nil {
            
            _userName = "Unkown"
            
        }
        return _userName
    }
    
    var date: NSDate {
        return _date
    }
}







