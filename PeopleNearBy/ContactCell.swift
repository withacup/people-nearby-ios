//
//  ContactCell.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/25/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    // If there is unread message in the current contact, show this mark
    @IBOutlet weak var newMessageMark: UIView!
    @IBOutlet weak var contactNameLbl: UILabel!
    @IBOutlet weak var contactImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        newMessageMark.layer.cornerRadius = 5
        newMessageMark.isHidden = true
    }
    
    public func  configureCell(withContactName contactName: String, andContactImg contactImg: UIImage) {
        
        contactNameLbl.text = contactName
        self.contactImg.image = contactImg
        
    }
    
    public func removeMark() {
        newMessageMark.isHidden = true
    }
    
    public func addMark() {
        newMessageMark.isHidden = false
    }
    
}





