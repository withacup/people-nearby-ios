//
//  SignInVC.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/15/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {

    @IBOutlet weak var inputField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isOpaque = true
    }
    
    @IBAction func LoginBtnPressed(_ sender: Any) {
        
        if let id = inputField.text {
            
            performSegue(withIdentifier: "ImVC", sender: id)
            
        } else {
            
            print("$debug you need to specify an id ")
        }

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImVC" {
            if let destination = segue.destination as? ImVC {
                if let item = sender as? String {
                    destination.userId = item
                }
            }
        }
    }
    
}
