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

    @IBOutlet weak var toUser: UITextField!
    @IBOutlet weak var statusTextView: UITextView!
    @IBOutlet weak var inputTextView: UITextView!
//    @IBOutlet weak var displayTextField: UITextView!
    @IBOutlet weak var sendBtn: UIButton!

    // diaplay the messages
    @IBOutlet weak var messageTable: UITableView!
    
    // input text view bottom space
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    
    // if the keyboard is already on screen
    private var isKeyBoardOnScreen: Bool = false
    
    var socketId: String!
    var userId: String!
    
    let socket = SocketService.socket
    var messages: [Message] = []
    var heightOfMessages: [CGFloat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTable.delegate = self
        messageTable.dataSource = self
        
        turnOffConnectionStatus() // trun off the connection status
        
        configKeyBoard()
        configSocket(socket: socket)
        configObserver()
        
        socket.connect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // observe when keyboard will move
        NotificationCenter.default.addObserver(self, selector: #selector(ImVC.keyBoardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ImVC.keyBoardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
        
        print("$debug cellforrowat \(indexPath.row)")
        
        if let cell = messageTable.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageCell{
//            cell.awakeFromNib()
            
            _ = cell.configCell(message: self.messages[indexPath.row])
            
            return cell
        } else {
            
            // impossible
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
            
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
// -------------------send button--------------------------
    @IBAction func sendBtnPressed(_ sender: Any) {
        
        guard toUser.text != nil, toUser.text != "" else {
            inputTextView.text = "user id cannot be empty"
            return
        }
        
        guard inputTextView.text != nil, inputTextView.text != "" else {
            inputTextView.text = "content cannot be empty"
            return
        }
        
        socket.emit("message", ["message":self.inputTextView.text!, "from":self.userId, "to":self.toUser.text!])
        
        self.messages.append(Message(content: self.inputTextView.text!, type: .to, userName: self.userId))
        self.heightOfMessages.append(0.0)
        
        // coredate down here
        let newMessage = MessageCoreData(context: context)
        newMessage.from = self.userId
        newMessage.to = self.toUser.text!
        newMessage.content = self.inputTextView.text!
        ad.saveContext()
        
        self.messageTable.reloadData()
        
        scrollToBottom()
        
        inputTextView.text = ""
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
        print("$debug keyboard show")
        if !self.isKeyBoardOnScreen {
            
            self.isKeyBoardOnScreen = true
            
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
            print(duration)
            let rect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
            let height = rect?.size.height
            
            if let height = height {
                
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
        print("$debug keyboard remove")
        
        self.isKeyBoardOnScreen = false
        
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        print(duration)
        
        bottomSpace.constant = 0
        
        UIView.animate(withDuration: duration, animations: {() in
            
            self.view.layoutIfNeeded()
            
        })
        
    }
    
}



























