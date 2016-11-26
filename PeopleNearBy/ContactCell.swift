//
//  ContactCell.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/25/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    @IBOutlet weak var contactNameLbl: UILabel!
    @IBOutlet weak var contactImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    public func  configureCell(withContactName contactName: String, andContactImg contactImg: UIImage) {
        
        contactNameLbl.text = contactName
        self.contactImg.image = contactImg
        
    }
}
