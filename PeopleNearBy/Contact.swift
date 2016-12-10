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
    private var _contactImg: UIImage!
    
    init(withContactName name: String, contactImg: UIImage?) {
        self._date = NSDate()
        self._contactName = name
        self._messageRec = [Message]()
        
        if let contactImg = contactImg {
            self._contactImg = contactImg
        } else {
            self._contactImg = UIImage(named: "dogs")
        }
    }
    
    init(withContactName name: String, andMessages: [Message], contactImg: UIImage?) {
        self._date = NSDate()
        self._contactName = name
        self._messageRec = andMessages
        
        if let contactImg = contactImg {
            self._contactImg = contactImg
        } else {
            self._contactImg = UIImage(named: "dogs")
        }
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
    
    public var getContactImg: UIImage {
        return _contactImg
    }
    
}
