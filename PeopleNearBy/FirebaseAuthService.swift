//
//  FirebaseAuthService.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/26/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import Foundation
import FirebaseAuth
import SwiftKeychainWrapper
import CoreData

class FirebaseAuthService {
    
    private let FILE_NAME: String = "FirebaseAuthService.swift"
    private var _currentUserProfile: UserProfile!
    private init() {}
    
    static let sharedFIRAuthInstance = FirebaseAuthService()
    
    public func signInWith(email: String, password pass: String) {
        
        FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
            if let err = error {
                
                Debug.printBug(withFileLocation: "FirebaseAuthService.swift", error: err, withOperation: "failed to signIn with email: \(email) and password: \(pass)")
                
                let errorDict = ["error":err]
                
                NotificationCenter.default.post(name: NSNotification.Name("onAuthFailed"), object: nil, userInfo: errorDict)
                
            } else {
                
                Debug.printEvent(withEventDescription: "diaplay name: \(user?.displayName) url: \(user?.photoURL?.absoluteString)", inFile: "signIn.swift")
                
                var newUserProfile: UserProfile!
                
                if let userImg = CoredataService.attempToGetImage(withId: (user?.email)!) {
                    newUserProfile = UserProfile(withUserName: (user?.displayName)!, userPhotoUrl: (user?.photoURL)!, userEmail: (user?.email)!, userPass: "none", userImg: userImg)
                    
                    self._currentUserProfile = newUserProfile
                    
                    Debug.printEvent(withEventDescription: "Successfully singIn with user: \(user?.displayName) email verified: \(user?.isEmailVerified)", inFile: "firbaseauthservice.swift")
                    
                    let newUserProfileDict = ["userProfile":newUserProfile]
                    
                    NotificationCenter.default.post(name: NSNotification.Name("onAuthSuccess"), object: nil, userInfo: newUserProfileDict)
                    
                    // never call this method out of firebase auth service
                    MessageCenter.sharedMessageCenter.connect()
                    
                    Debug.printEvent(withEventDescription: "connecting to server when sign in", inFile: self.FILE_NAME)
                    
                    self.setKeyChain(withUserEmail: email, password: pass)

                } else {
                    FIRStorageService.sharedInstance.retrieveUserIcon(withId: (user?.email)!, completion: { (userIcon) in
                        
                        newUserProfile = UserProfile(withUserName: (user?.displayName)!, userPhotoUrl: (user?.photoURL)!, userEmail: (user?.email)!, userPass: "none", userImg: userIcon)
                        
                        CoredataService.insert(withNewImage: userIcon, id: (user?.email)!)
                        
                        self._currentUserProfile = newUserProfile
                        
                        Debug.printEvent(withEventDescription: "Successfully singIn with user: \(user?.displayName) email verified: \(user?.isEmailVerified)", inFile: "firbaseauthservice.swift")
                        
                        let newUserProfileDict = ["userProfile":newUserProfile]
                        
                        NotificationCenter.default.post(name: NSNotification.Name("onAuthSuccess"), object: nil, userInfo: newUserProfileDict)
                        
                        // never call this method out of firebase auth service
                        MessageCenter.sharedMessageCenter.connect()
                        
                        Debug.printEvent(withEventDescription: "connecting to server when sign in", inFile: self.FILE_NAME)
                        
                        self.setKeyChain(withUserEmail: email, password: pass)

                    })
                }
                
                
                
            }
        })
    }
    
    /// This method will only create user for auth, if you want to save user icon or displayname, call changeUserProfile.
    public func createNewUserWith(userEmail: String, userPassword: String, completion: @escaping () -> Void) {
        
        FIRAuth.auth()?.createUser(withEmail: userEmail, password: userPassword, completion: { (user, error) in
            if error == nil {
                
                Debug.printEvent(withEventDescription: "successfully created user with email: \(userEmail)", inFile: self.FILE_NAME)
                
                completion()
                
            } else {
                
                Debug.printBug(withFileLocation: "firebaseauthservice.swift", error: error!, withOperation: "fail to authentificate with email: \(userEmail)")
                
                let errorDict = ["error":error]
                
                NotificationCenter.default.post(name: NSNotification.Name("onAuthFailed"), object: nil, userInfo: errorDict)
                
            }
        })
    }
    
    /// This method will change user profile, but it can't change user password
    public func changeUserProfile(userProfile: UserProfile, completion: @escaping (_ error: Error?) -> Void) {
        
        let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
        changeRequest?.photoURL = userProfile.userPhotoUrl
        changeRequest?.displayName = userProfile.userName
        changeRequest?.commitChanges(completion: { (error) in
            
            guard error == nil else {
                Debug.printBug(withFileLocation: "firebaseAuthService.swift", error: error!, withOperation: "change user profile infomation")
                completion(error)
                return
            }
            
            Debug.printEvent(withEventDescription: "successfully created user: \(userProfile.userName) email: \(userProfile.userEmail)", inFile: "firebaseAuthService.swift")
            
            self._currentUserProfile = userProfile
            
            let userProfileDict = ["userProfile": userProfile]
            
            NotificationCenter.default.post(name: NSNotification.Name("onAuthSuccess"), object: nil, userInfo: userProfileDict)
            
            // never call this method out of firebase auth service
            MessageCenter.sharedMessageCenter.connect()
            
            Debug.printEvent(withEventDescription: "connecting to server when sign up", inFile: self.FILE_NAME)
            
            self.setKeyChain(withUserEmail: userProfile.userEmail, password: userProfile.userPass)
            
            completion(nil)
        })        
    }
    
    public func SignOut() -> Bool{
        
        do {
            self.removeKeyChain()
            
            try FIRAuth.auth()?.signOut()
            MessageCenter.sharedMessageCenter.disconnect()
            MessageCenter.sharedMessageCenter.clearAllMessages()
            
            Debug.printEvent(withEventDescription: "successfully signed out with user email: \(self._currentUserProfile.userEmail)", inFile: "firebaseAuthService.swift")
            
        } catch {
            Debug.printBug(withFileLocation: "firebaseAuthService.swift", error: error, withOperation: "sign out failed")
            return false
        }
        return true
    }
    
    public var currentUserProfile: UserProfile {
        
        return self._currentUserProfile
    }
    
    private func setKeyChain(withUserEmail userEmail: String, password: String){
        KeychainWrapper.standard.set(userEmail, forKey: KEY_USER_EMAIL)
        KeychainWrapper.standard.set(password, forKey: KEY_PASSWORD)
        Debug.printEvent(withEventDescription: "\(userEmail) \(password) added to the keychain", inFile: "FirebaseAuthService.swift")
    }
    
    private func removeKeyChain() {
        let res = KeychainWrapper.standard.removeAllKeys()
        Debug.printEvent(withEventDescription: "\(res) removed from keychain", inFile: "FirebaseAuthService.swift")
    }
    
}




















