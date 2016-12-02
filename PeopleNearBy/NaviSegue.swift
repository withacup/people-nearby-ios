//
//  NaviSegue.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/29/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit

/// Custom segue to make it possible for segue be used with navigation view
class NaviSegue: UIStoryboardSegue {
    override func perform() {
        /// When calling - performSegue, push a new - viewController on the top of view stack
        self.source.navigationController?.pushViewController(self.destination, animated: true)
    }
}
