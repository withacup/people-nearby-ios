//
//  SignInVC.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/15/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {

    @IBOutlet weak var userEmailTF: UITextField!
    @IBOutlet weak var userPassTF: UITextField!
    @IBOutlet weak var errorLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onAuthSuccess), name: NSNotification.Name("onAuthSuccess"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onAuthFailed), name: NSNotification.Name("onAuthFailed"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @IBAction func LoginBtnPressed(_ sender: Any) {
        
        guard let email = userEmailTF.text, let password = userPassTF.text else {
            errorLbl.text = "email and password cannot be empty"
            Debug.printBug(withDescription: "email and password cannot be empty")
            return
        }
        
        if MessageCenter.sharedMessageCenter.isHandlerAdded == false {
            MessageCenter.sharedMessageCenter.addNotificationHandlers()
        }
        
        FirebaseAuthService.sharedFIRAuthInstance.signInWith(email: email, password: password)
    }
    
    func onAuthSuccess(_ notification: NSNotification) {
        
        if let userProfile = notification.userInfo?["userProfile"] as? UserProfile {
            
            Debug.printEvent(withEventDescription: "user login success with user name: \(userProfile.userName)", inFile: "SignInVC.swift")
            
            let email = userProfile.userEmail
            if let userImage = CoredataService.attempToGetImage(withId: email) {
                
                FirebaseAuthService.sharedFIRAuthInstance.currentUserProfile.setUserIcon(userIcon: userImage)
                
            } else {
                
                FIRStorageService.sharedInstance.retrieveUserIcon(withId: email, completion: { (userIcon) in
                    CoredataService.insert(withNewImage: userIcon, id: email)
                })
                
            }
            performSegue(withIdentifier: "ContactsVC", sender: nil)
        }
    }
    
    func onAuthFailed(_ notification: NSNotification) {
        
        if let error = notification.userInfo?["error"] as? Error {
            
            errorLbl.text = error.localizedDescription
            errorLbl.isHidden = false
            
            Debug.printBug(withFileLocation: "SignInVC.swift", error: error, withOperation: "when sing in with user email: \(userEmailTF.text!)")
            
        }
    }
}













