//
//  Images+CoreDataProperties.swift
//  
//
//  Created by Tianxiao Yang on 12/10/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Images {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Images> {
        return NSFetchRequest<Images>(entityName: "Images");
    }

    @NSManaged public var imageId: String?
    @NSManaged public var imageData: NSData?

}
