//
//  MessageCell.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/17/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    // Content of message
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var view: MessageTextView!
    
    /// Constrain on left side of the message bubble
    var leftSpace: NSLayoutConstraint! = nil
    /// Constrain on right side of the message bubble
    var rightSpace: NSLayoutConstraint! = nil
    /// Indicate wether it's a incoming cell or outgoing cell
    var cellType: messageType!
    
    /// Current bubble width
    private var currentWidth: CGFloat!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        currentWidth = layer.frame.width
        
        // http://stackoverflow.com/questions/26180822/swift-adding-constraints-programmatically
        
        if leftSpace == nil, rightSpace == nil {
        
            leftSpace = NSLayoutConstraint(item: content, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: content.superview, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
            
            rightSpace = NSLayoutConstraint(item: content, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: content.superview, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
            
            NSLayoutConstraint.activate([leftSpace,rightSpace])    
        }        
    }
    
    func configCell(message: Message) -> CGFloat {
        content.text = message.content // first
        
        //http://stackoverflow.com/questions/24141610/cgsize-sizewithattributes-in-swift
        
        let myString: NSString = content.text as NSString
        
        var size: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)])
        
        let contentWidth = size.width
        
        cellType = message.type
        
        // dynamic bubbles (spend fvcking 10 hours debugging this stupid textview)
        if cellType == .from {
            
            if size.width > 355 {
                rightSpace.constant = -70
                size.width = 355
            } else {
                rightSpace.constant = -(355 - contentWidth)
            }
            
            leftSpace.constant = 10
            
            content.backgroundColor = UIColor.white
            
        } else {
            
            if size.width > 355 {
                leftSpace.constant = 70
                size.width = 355
            } else {
                leftSpace.constant = 355 - contentWidth - 5
            }
        
            rightSpace.constant = -10
            
            content.backgroundColor = UIColor.green
            
        }
        
        content.textAlignment = NSTextAlignment.left
        
        // http://stackoverflow.com/questions/50467/how-do-i-size-a-uitextview-to-its-content
        
        var fixedWidth: CGFloat!
        
        if cellType == .from {
            
            fixedWidth = 365 + rightSpace.constant
            
        } else {
            
            fixedWidth = 360 - leftSpace.constant
            
        }
        
        let newSize = content.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = content.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        content.frame = newFrame;
        
        return content.frame.height        
    }
}

































