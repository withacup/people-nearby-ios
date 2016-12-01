//
//  Contact.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/25/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import Foundation

class Contact {
    
    private var _contactName: String!
    private var _messageRec: [Message]!
    private var _date: NSDate!
    
    init(withContactName name: String) {
        self._date = NSDate()
        self._contactName = name
        self._messageRec = [Message]()
    }
    
    init(withContactName name: String, andMessages: [Message]) {
        self._date = NSDate()
        self._contactName = name
        self._messageRec = andMessages
    }
    
    /// This append method will append current new Message into messageRe array.
    /// And will update current contact date with the newest message
    public func append(withNewMessage newMessage: Message) {
        self._date = newMessage.date
        self._messageRec.append(newMessage)
    }
    
    public var getContactName: String {
        
        if self._contactName == nil {
            
            Debug.printBug(withNilValueName: "_contact", when: "getting contact name from contact object")
            self._contactName = ""
            
        }
            
        return self._contactName
    }
    
    public var getMessageRec: [Message] {
        if self._messageRec == nil {
            Debug.printBug(withNilValueName: "_messageRec", when: "getting message array from contact object")
        }
        return self._messageRec
    }
    
    public var getDate: NSDate {
        return _date
    }
    
}
