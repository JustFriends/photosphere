//
//  ScrollView.swift
//  photosphere
//
//  Created by David Fontenot on 10/25/15.
//  Copyright © 2015 CodePath. All rights reserved.
//

import UIKit

class ScrollViewPage: UIView {
    var s: String?
    var i: Int?
    init(s: String, i: Int) {
        self.s = s
        self.i = i
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}
