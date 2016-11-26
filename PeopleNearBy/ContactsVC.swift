//
//  ContactsVC.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/25/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit

class ContactsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var contactsTable: UITableView!
    
    var contactNames = [String]()
    var messageCenter: MessageCenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.messageCenter = MessageCenter.sharedMessageCenter
        
        contactsTable.delegate = self
        contactsTable.dataSource = self
        
        configureObserver()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        Debug.printEvent(withEventDescription: "view did appear", inFile: "ContactsVC.swift")
        self.contactNames = messageCenter.getAllContactNames()
        self.contactsTable.reloadData()
        
    }

// ----------------notification center---------------------
    
    func configureObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.newContact(_:)), name: NSNotification.Name("newContactName"), object: nil)
        
    }
    
    func newContact(_ notification: NSNotification) {
        
        if let newContactName = notification.userInfo?["newContactName"] as? String {
            
            contactNames.insert(newContactName, at: 0)
            contactsTable.reloadData()
            
        }
    }
    
// ----------------table view functions--------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as? ContactCell{
            cell.configureCell(withContactName: self.contactNames[indexPath.row], andContactImg: UIImage(named: "dog")!)
            
            return cell
        }
        Debug.printBug(withDescription: "No cell avaiable for Contacts table")
        return ContactCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let contactName = self.contactNames[indexPath.row]
        
        performSegue(withIdentifier: "ContactsVCToImVC", sender: contactName)
    }
    
// --------------------segue---------------------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ContactsVCToImVC", let destination = segue.destination as? ImVC, let contactName = sender as? String {
            
            destination.toUserId = contactName
            
        } else {
            Debug.printBug(withDescription: "fail to peform segue: ContactsVCToImVC")
        }
    }
    
// -------------------Log Out------------------------
    
    @IBAction func LogoutBtnPressed() {
        
        if FirebaseAuthService.sharedFIRAuthInstance.SignOut() {
            
            MessageCenter.sharedMessageCenter.removeNotificationHandlers()
            dismiss(animated: true, completion: nil)
            
        }
    }
}


















