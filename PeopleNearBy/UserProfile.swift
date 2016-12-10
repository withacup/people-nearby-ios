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
    private var _userImg: UIImage!
    
    init(withUserName userName: String, userPhotoUrl: URL, userEmail: String, userPass: String, userImg: UIImage?) {
        _userName = userName
        _userPass = userPass
        _userPhotoUrl = userPhotoUrl
        _userEmail = userEmail
        if let img = userImg {
            _userImg = img
        } else {
            _userImg = UIImage(named: "dog")
        }
    }
    
    public func setUserIcon(userIcon: UIImage) {
        self._userImg = userIcon
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
    
    var userImg: UIImage {
        return _userImg
    }    
}
