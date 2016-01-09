//
//  Completion_Button.swift
//  Edvizer
//
//  Created by Jeff Liu on 11/20/15.
//  Copyright © 2015 Appfish. All rights reserved.
//

import UIKit

class Completion_Button: UIButton {

    override func awakeFromNib() {
        backgroundColor = UIColor(red: 49/255.0, green: 201/255.0, blue: 222/255.0, alpha: 0.95)
        layer.shadowOffset = CGSizeMake(0, 2.0);
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1
    }

}
