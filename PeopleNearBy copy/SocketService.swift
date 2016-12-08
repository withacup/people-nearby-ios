//
//  SocketService.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/17/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import SocketIO

class SocketService {
    
    static let socket = SocketIOClient(socketURL: URL(string: ipAddress)!, config: [.log(true), .forcePolling(true)])
    
}
