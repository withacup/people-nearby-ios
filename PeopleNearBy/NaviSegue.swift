//
//  NaviSegue.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/29/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit

class NaviSegue: UIStoryboardSegue {

    override func perform() {
        self.source.navigationController?.pushViewController(self.destination, animated: true)
    }
}
