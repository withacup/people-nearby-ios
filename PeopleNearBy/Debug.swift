//
//  Debug.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/25/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import Foundation

class Debug {
    
    static func printBug(withFileLocation fileName: String, error: Error, withOperation operation: String) {
        
        print("$debug Error with file: \(fileName) error: \(error) when: \(operation)")
    }
    
    static func printBug(withDescription description: String) {
        
        print("$debug Error with description: \(description)")
    }
    
    static func printBug(withNilValueName variableName: String, when operation: String) {
        
        print("$debug Found nil with value: \(variableName) when: \(operation)")
        
    }
    
    static func printEvent(withEventDescription event: String, inFile fileName: String) {
        
        print("$debug \(event) in \(fileName)")
        
    }
    
}
