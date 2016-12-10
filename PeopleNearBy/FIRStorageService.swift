//
//  FIRStorageService.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 12/8/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import FirebaseStorage


class FIRStorageService {
    private let FILE_NAME: String = "FIRStorageService.swift"
    private var _storage: FIRStorage!
    private var _BASE_REF: FIRStorageReference!
    private var _USER_REF: FIRStorageReference!
    private var _EVENT_REF: FIRStorageReference!
    
    private init() {
        self._storage = FIRStorage.storage()
        self._BASE_REF = _storage.reference(forURL: "gs://peoplenearby-3c47b.appspot.com").child("image")
        self._USER_REF = _BASE_REF.child("user")
        self._EVENT_REF = _BASE_REF.child("event")
    }
    
    static var sharedInstance: FIRStorageService = FIRStorageService()
    
    // MARK: - save event image into firbase storage
    /// This method can insert event image into strage, it will pass the download url to completion block
    public func saveEvent(withImage newImage: UIImage, id: String, completion: @escaping (_ downloadURL: String) -> Void) {
        
        if let imageData = UIImageJPEGRepresentation(newImage, 1.0) {
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            self._EVENT_REF.child(id).put(imageData, metadata: metaData) {(metadata, error) in
                
                if let error = error {
                    
                    Debug.printBug(withFileLocation: "FIrstorageServeice.swfit", error: error, withOperation: "uploading image with id:  \(id)")
                    
                } else {
                    Debug.printEvent(withEventDescription: "uploading user: \(metaData.downloadURL()?.absoluteString)", inFile: self.FILE_NAME)
                    
                    completion((metadata?.downloadURL()?.absoluteString)!)
                    
                }
            }
        }
    }
    
    // MARK: - save user icon into firebase storage
    /// This method can insert user icon into strage, it will pass the download url to completion block
    public func saveUser(withIcon newIcon: UIImage, id: String, completion: @escaping (_ downloadURL: String) -> Void) {
        
        if let imageData = UIImageJPEGRepresentation(newIcon, 1.0) {
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            self._USER_REF.child(id).put(imageData, metadata: metaData) {(metadata, error) in
                
                if let error = error {
                    
                    Debug.printBug(withFileLocation: "FIrstorageServeice.swfit", error: error, withOperation: "uploading image with id:  \(id)")
                    
                } else {
                    Debug.printEvent(withEventDescription: "uploading user: \(metaData.downloadURL()?.absoluteString)", inFile: self.FILE_NAME)
                    
                    completion((metadata?.downloadURL()?.absoluteString)!)
                    
                }
            }
        }
    }
    
    // MARK: - retrieve event image from firebase storage
    /// completion will be called after image is downloaded from database
    public func retrieveEventImage(withId id: String, completion: @escaping (_ eventIamge: UIImage) -> Void) {
        let ref = _EVENT_REF.child(id)
        ref.data(withMaxSize: 5 * 1024 * 1024, completion: {(data, error) in
            if let error = error {
                Debug.printBug(withFileLocation: self.FILE_NAME, error: error , withOperation: "retrieving event image from firebase with id \(id)")
            } else {
                completion(UIImage(data: data!)!)
            }
        
        })
    }
    
    // MARK: - retrieve user icon from firebase storage
    /// completion will be called after image is downloaded from database
    public func retrieveUserIcon(withId id: String, completion: @escaping (_ userIcon: UIImage) -> Void ) {
        let ref = _USER_REF.child(id)
        ref.data(withMaxSize: 5 * 1024 * 1024, completion: {(data, error) in
            if let error = error {
                Debug.printBug(withFileLocation: self.FILE_NAME, error: error , withOperation: "retrieving user icon from firebase with id \(id)")
            } else {
                completion(UIImage(data: data!)!)
            }
        })

    }
    // MARK: - delete event image from firebase storage
    /// completion will be called when image is successfully deleted, overwise error will be shown in console
    public func deleteImage(withEventId imageId: String, completion: @escaping () -> Void) {
        _EVENT_REF.child(imageId).delete { (error) in
            if let error = error {
                Debug.printBug(withFileLocation: self.FILE_NAME, error: error, withOperation: "deleting event image with id: \(imageId)")
            } else {
                completion()
            }
        }
    }
}























