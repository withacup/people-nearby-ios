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
    
    var contacts = [Contact]()
    var messageCenter: MessageCenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.messageCenter = MessageCenter.sharedMessageCenter
        self.contacts = messageCenter.getAllContact()
        contactsTable.delegate = self
        contactsTable.dataSource = self
        
        configureObserver()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        Debug.printEvent(withEventDescription: "view did appear", inFile: "ContactsVC.swift")
        sortContact()
        self.contactsTable.reloadData()
        
    }

// ----------------notification center---------------------
    
    func configureObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.newContact(_:)), name: NSNotification.Name("newContact"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.newMessage(_:)), name: NSNotification.Name("newMessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.whenDataRetrieved), name: NSNotification.Name("dataRetrieved"), object: nil)
        
    }
    
    func newContact(_ notification: NSNotification) {
        
        if let newContact = notification.userInfo?["newContact"] as? Contact {
            
            contacts.append(newContact)
            sortContact()
            contactsTable.reloadData()
            
        }
    }
    
    func newMessage(_ notification: NSNotification) {
        if let mess = notification.userInfo?["newMessage"] as? Message {
            for i in 0..<contacts.count {
                if contacts[i].getContactName == mess.userName {
                    contacts.insert(contacts[i], at: 0)
                    contacts.remove(at: i + 1)
                    break
                }
            }
        }
        contactsTable.reloadData()
    }
    
    func whenDataRetrieved() {
        
        self.contacts = messageCenter.getAllContact()
        contactsTable.reloadData()
    }
    
// ----------------table view functions--------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as? ContactCell{
            cell.configureCell(withContactName: self.contacts[indexPath.row].getContactName, andContactImg: UIImage(named: "dog")!)
            
            return cell
        }
        Debug.printBug(withDescription: "No cell avaiable for Contacts table")
        return ContactCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let contact = self.contacts[indexPath.row]
        
        performSegue(withIdentifier: "ContactsVCToImVC", sender: contact)
    }
    
// --------------------segue---------------------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ContactsVCToImVC", let destination = segue.destination as? ImVC, let contact = sender as? Contact {
            
            destination.toUserId = contact.getContactName
            
        }
    }
    
// -------------------Log Out------------------------
    
    @IBAction func LogoutBtnPressed() {
        
        if FirebaseAuthService.sharedFIRAuthInstance.SignOut() {
            
            MessageCenter.sharedMessageCenter.removeNotificationHandlers()
//            dismiss(animated: true, completion: nil)
            _ = navigationController?.popToRootViewController(animated: true)
            
        }
    }
    
    private func sortContact() {
        self.contacts.sort { (c1, c2) -> Bool in
            c1.getDate.compare(c2.getDate as Date) == .orderedDescending
        }
    }
}


















