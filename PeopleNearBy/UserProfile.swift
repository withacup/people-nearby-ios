//
//  UserProfile.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/26/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import Foundation

class UserProfile {
    
    private var _userName: String!
    private var _userPhotoUrl: URL!
    private var _userEmail: String!
    private var _userPass: String!
    
    init(withUserName userName: String, userPhotoUrl: URL, userEmail: String, userPass: String) {
        _userName = userName
        _userPass = userPass
        _userPhotoUrl = userPhotoUrl
        _userEmail = userEmail
    }
    
    var userName: String {
        return _userName
    }
    
    var userEmail: String {
        return _userEmail
    }
    
    var userPhotoUrl: URL {
        return _userPhotoUrl
    }
    
    var userPass: String {
        return _userPass
    }
    
    
}
