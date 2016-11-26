//
//  NewContactVC.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/26/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit

class NewContactVC: UIViewController {
    
    @IBOutlet weak var newContactName: UITextField!
    
    var _messageCenter: MessageCenter!

    override func viewDidLoad() {
        super.viewDidLoad()

        self._messageCenter = MessageCenter.sharedMessageCenter
        
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        
        guard self.newContactName.text != nil else {
            Debug.printBug(withNilValueName: "newContactName", when: "saving new contact info")
            return
        }
        
        self._messageCenter.append(newContact: self.newContactName.text!)
        self.dismiss(animated: true, completion: nil)
    }
}
