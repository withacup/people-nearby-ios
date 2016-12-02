//
//  Debug.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/25/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import Foundation

/// Swich to indicate if print out the event and bug
private let debugMode = true

/// A Debug tool
class Debug {
    
    static func printBug(withFileLocation fileName: String, error: Error, withOperation operation: String) {
        
        if debugMode {
            
            print("$❌ Error with file: \(fileName) error: \(error) when: \(operation)")
            
        }
    }
    
    static func printBug(withDescription description: String) {
        
        if debugMode {
            
            print("$❌ Error with description: \(description)")
            
        }
    }
    
    static func printBug(withDescription description: String, inFile: String) {
        
        if debugMode {
            
            print("$❌ Error with description: \(description) in file \(inFile)")
            
        }
    }
    
    static func printBug(withNilValueName variableName: String, when operation: String) {
        
        if debugMode {
            
            print("$❌ Found nil with value: \(variableName) when: \(operation)")
            
        }
    }
    
    static func printEvent(withEventDescription event: String, inFile fileName: String) {
        
        if debugMode {
            
            print("$✅ \(event) in \(fileName)")
            
        }
    }
    
}
