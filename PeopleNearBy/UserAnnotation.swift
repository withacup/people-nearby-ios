//
//  UserAnnotation.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/22/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import Foundation
import MapKit

class UserAnnotation: NSObject, MKAnnotation {
    
    var coordinate = CLLocationCoordinate2D()
    var userId: String!
    var userImg: UIImage!
    
    init(coordinate: CLLocationCoordinate2D, userId: String, userImg: UIImage) {
        
        self.coordinate = coordinate
        self.userId = userId
        self.userImg = userImg
        
    }
}
