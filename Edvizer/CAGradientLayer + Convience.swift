//
//  CAGradientLayer + Convience.swift
//  Edvizer
//
//  Created by Jeff Liu on 11/11/15.
//  Copyright © 2015 Appfish. All rights reserved.
//


//Build the Gradient Function (Blueish Top, and Greenish Button)
import UIKit

extension CAGradientLayer {
    
    func blueGreenColor() -> CAGradientLayer {
        
        let topColor = UIColor(red: 49/255.0, green: 201/255.0, blue: 222/255.0, alpha: 0.95)
        let bottomColor = UIColor(red: 84/255.0, green: 222/255.0, blue: 122/255.0, alpha: 0.90)
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocation: [Float] = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocation
        
        
        
        return gradientLayer
    }
    
}
