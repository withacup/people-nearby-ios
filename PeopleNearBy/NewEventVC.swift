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

class NewEventVC: UIViewController {

    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventTimeTextFeild: UITextField!
    @IBOutlet weak var eventContentTextView: UITextView!
    
    var geoFireInstance: GeoFire!
    var REF_EVENT: FIRDatabaseReference!
    var location: CLLocation!
    var holder: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        geoFireInstance = GeoFireService.sharedInstance.getInstance
        
        REF_EVENT = GeoFireService.sharedInstance.REF_EVENT
        
        holder = MessageCenter.sharedMessageCenter.getUserId
        
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        
//        self.dismiss(animated: true, completion: nil)
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        // TODO: 1. Store info to firebase
        //       2. Put the annotation to mapView
                
        let uuid = NSUUID().uuidString
        
        self.geoFireInstance.setLocation(self.location, forKey: uuid)
        
        self.postEventToFirebase(eventId: uuid)
        
        _ = navigationController?.popViewController(animated: true)
        
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
}
























