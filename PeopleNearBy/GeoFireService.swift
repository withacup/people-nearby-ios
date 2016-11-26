//
//  GeoFireService.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/23/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import FirebaseDatabase


private let DB_BASE = FIRDatabase.database().reference()

class GeoFireService {
    
    private var geoFireInstance: GeoFire? = nil
    private var geoFireRef: FIRDatabaseReference? = nil
    private var _serviceInstance: GeoFireService? = nil
    
    static let sharedInstance = GeoFireService()
    
    private init(){
        geoFireRef = DB_BASE.child("location")
        geoFireInstance = GeoFire(firebaseRef: geoFireRef)
    }
    
    var getInstance: GeoFire {
        
        return self.geoFireInstance!
    }
    
    var REF_BASE: FIRDatabaseReference {
        
        return DB_BASE
        
    }
    
    var REF_EVENT: FIRDatabaseReference {
        
        return DB_BASE.child("event")
        
    }
    
    var REF_LOCATION: FIRDatabaseReference {
        
        return DB_BASE.child("location")
        
    }
    
}















