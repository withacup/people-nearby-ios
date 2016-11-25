//
//  EventInfo.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/24/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import Foundation

class EventInfo {
    
    private var _eventName: String!
    private var _eventTime: String!
    private var _eventHolder: String!
    private var _eventDescription: String!
    private var _eventImg: UIImage!
    private var _eventId: String!
    
    init(eventName: String, eventTime: String, eventHolder: String, eventDesription: String, eventImg: UIImage, eventId: String) {
        _eventName = eventName
        _eventTime = eventTime
        _eventHolder = eventHolder
        _eventDescription = eventDesription
        _eventImg = eventImg
        _eventId = eventId
    }
    
    var eventName: String {
        
        return _eventName
    }
    
    var eventTime: String {
    
        return _eventTime
    }
    
    var eventHolder: String {
        
        return _eventHolder
    }
    
    var eventDescrition: String {
        
        return _eventDescription
    }
    
    var eventImg: UIImage {
        
        return _eventImg
    }
    
    var eventId: String {
        
        return _eventId
    }
    
}
