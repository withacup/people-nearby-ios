//
//  EventAnnotation.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/22/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import Foundation
import MapKit

class EventAnnotation: NSObject, MKAnnotation {
    
    var coordinate = CLLocationCoordinate2D()
    var eventName: String!
    var eventTime: String!
    var eventHolder: String!
    var eventImg: UIImage!
    var eventDescrition: String!
    var eventInfo: EventInfo!
    
    // the title for annotation callout
    var title: String? {
        
        return eventName
    }
    
    // the subtitle for annotation callout
    var subtitle: String? {
        
       return eventTime
    }
    
    init(coordinate: CLLocationCoordinate2D, eventInfo: EventInfo) {
        
        self.eventInfo = eventInfo
        
        self.coordinate = coordinate
        self.eventName = eventInfo.eventName
        self.eventTime = eventInfo.eventTime
        self.eventHolder = eventInfo.eventHolder
        self.eventImg = eventInfo.eventImg
        self.eventDescrition = eventInfo.eventDescrition
        
    }
}
