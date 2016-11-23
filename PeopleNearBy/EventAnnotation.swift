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
    
    // needed by MKAnnotation protocol
    var title: String? {
        
        return eventName
        
    }
    
    init(coordinate: CLLocationCoordinate2D, eventName: String, eventTime: String, eventHolder: String, eventImg: UIImage) {
        
        self.coordinate = coordinate
        self.eventName = eventName
        self.eventTime = eventTime
        self.eventHolder = eventHolder
        self.eventImg = eventImg
        
    }
}
