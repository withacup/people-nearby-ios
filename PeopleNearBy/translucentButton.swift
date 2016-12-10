//
//  translucentButton.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/23/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit

class translucentButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 5
        self.alpha = 0.8
        self.setTitle("Editing...", for: .selected)
        self.setTitle("Add Event", for: .normal)
        
    }
}
