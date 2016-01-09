//
//  custom_TextField.swift
//  Edvizer
//
//  Created by Jeff Liu on 11/19/15.
//  Copyright © 2015 Appfish. All rights reserved.
//


import UIKit

class custom_TestField: UITextField {
    
    override func awakeFromNib()
    {
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 3
        layer.cornerRadius = 10
    }
    
}

