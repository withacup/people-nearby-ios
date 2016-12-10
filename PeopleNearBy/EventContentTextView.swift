//
//  EventContentTextView.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/29/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit

class EventContentTextView: UITextView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 5
        
    }

}
