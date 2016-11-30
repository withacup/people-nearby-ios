//
//  SignUpVC.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/26/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmTF: UITextField!
    
    var FIRAuthService: FirebaseAuthService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.FIRAuthService = FirebaseAuthService.sharedFIRAuthInstance
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onAuthSuccess(_:)), name: NSNotification.Name("onAuthSuccess"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onAuthFailed(_:)), name: NSNotification.Name("onAuthFailed"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        
        guard let email = emailTF.text, let username = userNameTF.text, let password = passwordTF.text else {
            Debug.printBug(withDescription: "no input field can be left blank")
            return
        }
        
        guard passwordTF.text! == confirmTF.text! else {
            Debug.printBug(withDescription: "confirm password and password is not the same")
            return
        }
        
        let newUserProfile = UserProfile(withUserName: username, userPhotoUrl: URL(fileURLWithPath: "none") , userEmail: email, userPass: password)
        
        self.FIRAuthService.createNewUserWith(userProfile: newUserProfile)
    }
    
    @IBAction func backBtnPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func onAuthSuccess(_ notificaiton: NSNotification) {
        
        if let userProfile = notificaiton.userInfo?["userProfile"] as? UserProfile {
            
            Debug.printEvent(withEventDescription: "Successfully created new user with user name: \(userProfile.userName)", inFile: "SignUpVC.swift")
            
            performSegue(withIdentifier: "SignUpVCtoContactsVC", sender: nil)
        }
    }
    
    func onAuthFailed(_ notification: NSNotification) {
        
        if let error = notification.userInfo?["error"] as? Error {
            
            Debug.printBug(withDescription: "Failed to authentificate in SignUpVC.swift \(error)")
            
        }
    }
    
    func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
}


























