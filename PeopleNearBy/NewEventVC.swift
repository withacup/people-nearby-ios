//
//  NewEventVC.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/23/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class NewEventVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventTimeTextFeild: UITextField!
    @IBOutlet weak var eventContentTextView: UITextView!
    @IBOutlet weak var eventBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    private var geoFireInstance: GeoFire!
    private var REF_EVENT: FIRDatabaseReference!
    // location will be set by segue
    public var location: CLLocation!
    private var holder: String!
    private var imagePicker: UIImagePickerController!
    private let FILE_NAME = "NewEventVC.swift"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        geoFireInstance = GeoFireService.sharedInstance.getInstance
        
        REF_EVENT = GeoFireService.sharedInstance.REF_EVENT
        
        holder = MessageCenter.sharedMessageCenter.getUserId
        
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        
//        self.dismiss(animated: true, completion: nil)
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    // MARK: - Save event button
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        // TODO: 1. Store info to firebase
        //       2. Put the annotation to mapView
        
        saveBtn.setTitle("uploading ...", for: .normal)
//        eventNameTextField.isOpaque = true
        eventNameTextField.isEnabled = false
//        eventTimeTextFeild.isOpaque = true
        eventTimeTextFeild.isEnabled = false
        eventContentTextView.isOpaque = true
        eventContentTextView.isEditable = false
        eventBtn.isEnabled = false
        eventBtn.isOpaque = true
        let uuid = NSUUID().uuidString
        
        self.geoFireInstance.setLocation(self.location, forKey: uuid)
        
        let resizeImage = self.resizeImage(image: (eventBtn.imageView?.image)!, newWidth: 50)
        
        FIRStorageService.sharedInstance.saveEvent(withImage: resizeImage, id: uuid) {downloadURL in
            
            Debug.printEvent(withEventDescription: "event image stored with url: \(downloadURL)", inFile: self.FILE_NAME)
            self.postEventToFirebase(eventId: uuid)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func postEventToFirebase(eventId: String) {
        
        if let name = eventNameTextField.text, let time = eventTimeTextFeild.text, let content = eventContentTextView.text {
            
            let event: Dictionary<String, String> = [
                "name": name,
                "time": time,
                "content": content,
                "holder": holder,
                "eventId": eventId
            ]
            
            let ref = REF_EVENT.child(eventId)
            ref.setValue(event)
            
        } else {
            
            print("input cannot be empty")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            Debug.printEvent(withEventDescription: "image picked up", inFile: FILE_NAME)
            eventBtn.setImage(image, for: UIControlState.normal)
            
        } else {
            Debug.printEvent(withEventDescription: "user did not pick up image", inFile: FILE_NAME)
        }
        
        
        
        imagePicker.dismiss(animated: true, completion: nil)  // close the image picker
    }
    
    @IBAction func eventImgBtnPressed(_ sender: UIButton) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(newWidth, newHeight))
        image.draw(in: CGRect(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}
























