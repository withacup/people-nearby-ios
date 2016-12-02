//
//  ImVC.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/12/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit
import SocketIO
import NotificationCenter

class ImVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Never change toUserTF, too many things connected to it due to poor programming skill
    @IBOutlet weak var toUser: UITextField!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var messageTable: UITableView! // display the messages
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!// input text view bottom space
    
    var isKeyBoardOnScreen: Bool = false// if the keyboard is already on screen
    var socketId: String!// inititated when socket connected with server
    var userId: String!// the user that is currently using the application on his phone
    var toUserId: String?// the textfield contain target user name
    
    // message center has the only socket object in the application and controls message
    // information and contact infomation
    var messageCenter: MessageCenter!
    var socket: SocketIOClient! // was inititated in message center
    var messages: [Message] = [] // current message in stored in current contact
    var heightOfMessages: [CGFloat] = []// cache the height of each cell so that we don't need to recalculate this number
    
 // -----------------behaviors of view controller-----------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.printEvent(withEventDescription: "view did load", inFile: "ImVC.swift")
//        navigationController?.setNavigationBarHidden(true, animated: false)
        self.messageTable.delegate = self
        self.messageTable.dataSource = self
        
        self.configKeyBoard()
        self.configureNotificationCenter()
        
        self.messageCenter = MessageCenter.sharedMessageCenter
        
        // TODO: need to figure out how to reconnect with server after wifi reconnected
        if self.messageCenter.isConnected {
            self.turnOnConnectionStatus()
        } else {
            self.turnOffConnectionStatus()
        }
        
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
//        self.navigationController?.navigationBar.barTintColor = self.colorWithHexString(hexString: "#343436")
//        configSocket(socket: socket)
//        configObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if toUserId != nil {
            toUser.text = toUserId
            self.messages = self.messageCenter.getMessages(fromContactName: toUserId!)
            self.messages.forEach({ (_) in
                self.heightOfMessages.append(0.0)
            })
            self.scrollToBottom()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // remove observer
        NotificationCenter.default.removeObserver(self)
    }
    
// -------------------table view functions-------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if let cell = messageTable.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageCell{
            
            _ = cell.configCell(message: self.messages[indexPath.row])
            
            return cell
        } else {
            
            return MessageCell()
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if heightOfMessages[indexPath.row] == 0.0 {
            
            if let cell = messageTable.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageCell{
                
                self.heightOfMessages[indexPath.row] = cell.configCell(message: self.messages[indexPath.row]) + 10
                
                return cell.content.frame.height + 10
                
            } else {
                
                print("$debug no resuable cell")
                
            }
        } else {
            
            return heightOfMessages[indexPath.row]
            
        }
        return 150
    }
    
    func scrollToBottom() {
        
        if !self.messages.isEmpty {
            // get the cell at the bottom
            let path = NSIndexPath(row: self.messages.count - 1, section: 0)
            
            self.messageTable.scrollToRow(at: path as IndexPath, at: .bottom, animated: true)
            
        } else {
            Debug.printBug(withDescription: "cannot scroll to bottom because the messges array is empty", inFile: "ImVC.swift")
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
// -------------------send button--------------------------
    @IBAction func sendBtnPressed(_ sender: Any) {
        
        // target user cannot be empty
        guard toUser.text != nil, toUser.text != "" else {
            inputTextView.text = "user id cannot be empty"
            return
        }
        
        // message content cannnot be empty
        guard inputTextView.text != nil, inputTextView.text != "" else {
            inputTextView.text = "content cannot be empty"
            return
        }
        
        socket.emit("message", ["message":self.inputTextView.text!, "from":self.userId, "to":self.toUser.text!])
        
        let newMessage = Message(content: self.inputTextView.text!, type: .to, userName: self.userId)
        
        self.messages.append(newMessage)
        self.messages.sort { (m1, m2) -> Bool in
            m1.date.compare(m2.date as Date) == .orderedAscending
        }
        self.messageCenter.append(toContact: toUser.text!, withNewMessage: newMessage)
        self.heightOfMessages.append(0.0)
        
        // coredata down here
//        let newMessage = MessageCoreData(context: context)
//        newMessage.from = self.userId
//        newMessage.to = self.toUser.text!
//        newMessage.content = self.inputTextView.text!
//        ad.saveContext()
        
        self.messageTable.reloadData()
        
        scrollToBottom()
        
        inputTextView.text = ""
    }
    
// --------------------back button pressed-------------------
    @IBAction func backBtnPressed(_ sender: UIButton) {
        
//        self.dismiss(animated: true, completion: nil)
        _ = navigationController?.popViewController(animated: true)
        
    }
    
// ----------------keyboard control------------------
    func configKeyBoard() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        view.addGestureRecognizer(tap)  
    }
    
    func dismissKeyboard() {
        
        view.endEditing(true)
        self.isKeyBoardOnScreen = false
        
    }
    
    func keyBoardWillShow(notification: NSNotification) {
        
        Debug.printEvent(withEventDescription: "keybaord show", inFile: "ImVC.swift")
        
        if !self.isKeyBoardOnScreen {
            
            self.isKeyBoardOnScreen = true
            
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
            
            Debug.printEvent(withEventDescription: "duration of keyboard animation time: \(duration)", inFile: "ImVC.swift")
            
            let rect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
//            let height = rect?.size.height
            
            if let height = rect?.size.height {
                
                bottomSpace.constant = height
                let tableHeight = messageTable.frame.height
                let tableWidth = messageTable.frame.width
                
                // change the table view size
                messageTable.frame = CGRect(x: messageTable.frame.origin.x, y: messageTable.frame.origin.y, width: tableWidth, height: tableHeight - height)
                
                self.scrollToBottom()
                
            }
            
            UIView.animate(withDuration: duration, animations: {() in
                
                self.view.layoutIfNeeded()
                
            })
        }
    }
    
    func keyBoardWillHide(notification: NSNotification) {
        
        Debug.printEvent(withEventDescription: "keyboard removed from screen", inFile: "ImVC.swift")
        
        self.isKeyBoardOnScreen = false
        
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        print(duration)
        
        bottomSpace.constant = 0
        
        UIView.animate(withDuration: duration, animations: {() in
            
            self.view.layoutIfNeeded()
            
        })
    }
    
 // ---------------------convert hex string to UIColor-------------------------------
    
    func colorWithHexString(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = NSCharacterSet(charactersIn: "#") as CharacterSet
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
    
    // MARK: - Delete button
    @IBAction func deleteBtnPressed(_ sender: UIButton) {
        MessageCenter.sharedMessageCenter.deleteContact(withContactEmail: self.toUserId!)
        _ = navigationController?.popViewController(animated: true)
    }
}



























