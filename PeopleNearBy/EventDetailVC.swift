//
//  EventDetailVC.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/24/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EventDetailVC: UIViewController {
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventHolder: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var eventInfo: EventInfo!
    var REF_EVENT: FIRDatabaseReference!
    var REF_LOCATION: FIRDatabaseReference!
    var eventId: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        eventDescription.layer.borderWidth = 0.5
        eventDescription.layer.borderColor = UIColor.black.cgColor
        eventDescription.isEditable = false
        
        eventTitle.text = eventInfo.eventName
        eventHolder.text = eventInfo.eventHolder
        eventTime.text = eventInfo.eventTime
        eventDescription.text = eventInfo.eventDescrition
        eventId = eventInfo.eventId
        
        REF_EVENT = GeoFireService.sharedInstance.REF_EVENT
        REF_LOCATION = GeoFireService.sharedInstance.REF_LOCATION
        
        // If current user is not event holder, disable delete button
        if MessageCenter.sharedMessageCenter.getUserId != eventHolder.text! {
            deleteBtn.isHidden = true
            deleteBtn.isEnabled = false
            
        }
    }
    
    func configViewWithEventInfo(withEventInfo eventInfo: EventInfo) {
        
        self.eventInfo = eventInfo
        
    }

    @IBAction func contactHolderBtnPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "ImVC", sender: eventHolder.text!)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ImVC", let destination = segue.destination as? ImVC {
            
            destination.toUserId = sender as? String
            
        }
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        
//        self.dismiss(animated: true, completion: nil)
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func deleteBtnPressed(_ sender: UIButton) {
        
        REF_LOCATION.child(self.eventId).removeValue { (error, ref) in
            
            if error == nil {
                
                self.REF_EVENT.child(self.eventId).removeValue(completionBlock: { (error, ref) in
                    
                    if (error == nil) {
                        
                        self.navigationController?.popViewController(animated: true)
                        
                    } else {
                        
                        Debug.printBug(withFileLocation: "EventDetailVC", error: error!, withOperation: "deleting value in event collection")
                    }
                })
            } else {
                
                Debug.printBug(withFileLocation: "EventDetailVC", error: error!, withOperation: "deleting value in location collection")
            }
        }
    }
}
































