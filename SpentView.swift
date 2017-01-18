//
//  SpentView.swift
//  swiftdemo
//
//  Created by Jerry Zhong on 1/12/16.
//  Copyright © 2016 ZhongJiancheng. All rights reserved.
//

import UIKit


@IBDesignable
class SpentView: UIView {
    @IBInspectable var allowance:Double = 10
    @IBInspectable var spent: Double = 7.5
    @IBInspectable var overspentColor: UIColor = UIColor(red: 228/255.0, green: 68/255.0, blue: 68/255.0, alpha: 1)
    @IBInspectable var allowanceColor: UIColor = UIColor(red: 49/255.0, green: 201/255.0, blue: 222/255.0, alpha: 1)
    @IBInspectable var savingColor: UIColor = UIColor(red: 51/255.0, green: 204/255.0, blue: 102/255.0, alpha: 1)
    @IBInspectable var arcWidth: CGFloat = 13.0
    
    let upperleftLabel = UILabel()
    let bottomrightLabel = UILabel()
    let midLabel = UILabel()
    let allowanceLabel = UILabel()
    let allowanceValueLabel = UILabel()
    let spentLabel = UILabel()
    let spentValueLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        self.addSubviews()
    }
    
    
    override func layoutSubviews() {
        let radius = min(self.frame.width, self.frame.height)/2 - 20
        upperleftLabel.frame = CGRectMake(0, self.frame.height/2 - 0.866 * (radius + self.arcWidth/2) - 10, self.frame.width/2 - 0.5 * (radius+self.arcWidth/2) - 30 - 4, 30)
        upperleftLabel.center = CGPointMake(upperleftLabel.center.x, self.frame.height/2 - 0.866 * (radius + self.arcWidth/2) - 10)
        bottomrightLabel.frame = CGRectMake(self.frame.width/2 + 0.5 * (radius+self.arcWidth/2) + 30 + 4, self.frame.height/2 + 0.866 * (radius + self.arcWidth/2) + 10, self.frame.width/2 - 0.5 * (radius+self.arcWidth/2) - 30 - 8, 30)
        bottomrightLabel.center = CGPointMake(bottomrightLabel.center.x, self.frame.height/2 + 0.866 * (radius + self.arcWidth/2) + 10)
        
        if (self.spent != 0 || self.allowance != 0) {
            if (self.spent > self.allowance) {
                upperleftLabel.text = "Overspent"
                upperleftLabel.textAlignment = NSTextAlignment.Right
                bottomrightLabel.text = ""
            } else {
                upperleftLabel.textAlignment = NSTextAlignment.Right
                upperleftLabel.text = "Actual Spending"
                upperleftLabel.numberOfLines = 2
                
                bottomrightLabel.text = "Saving"
                bottomrightLabel.textAlignment = .Left
            }
        }
        
        midLabel.frame =  CGRectMake(0, 0,  1.95 * (radius-self.arcWidth/2), 0.4 * (radius - self.arcWidth/2))
        midLabel.center = CGPointMake(self.frame.width/2, self.frame.height/2)
        if (self.spent > self.allowance) {
            midLabel.text = String(format: "Over: $%.2f", self.spent - self.allowance)
            midLabel.textColor = UIColor(red: 213/255.0, green: 59/255.0, blue: 59/255.0, alpha: 1)
        } else {
            midLabel.text = String(format: "Saving: $%.2f", self.allowance - self.spent)
            midLabel.textColor = UIColor(red: 38/255.0, green: 218/255.0, blue: 136/255.0, alpha: 1)
        }
        midLabel.setNeedsLayout()
        
        allowanceLabel.frame = CGRectMake(0, 0, 1.12 * (radius-self.arcWidth/2), 0.2 * (radius-self.arcWidth/2))
        allowanceLabel.center = CGPointMake(self.frame.width/2, self.frame.height/2 - (radius - self.arcWidth/2) * 0.743)
        
        allowanceValueLabel.frame = CGRectMake(0, 0, 1.50 * (radius-self.arcWidth/2), 0.237 * (radius-self.arcWidth/2))
        allowanceValueLabel.center = CGPointMake(self.frame.width/2, self.frame.height/2 - (radius - self.arcWidth/2) * 0.517)
        allowanceValueLabel.text = String(format: "$%.2f", self.allowance)
        
        spentLabel.frame = CGRectMake(0, 0, 1.20 * (radius-self.arcWidth/2), 0.2 * (radius-self.arcWidth/2))
        spentLabel.center = CGPointMake(self.frame.width/2, self.frame.height/2 + (radius - self.arcWidth/2) * 0.48)
        
        spentValueLabel.frame = CGRectMake(0, 0, 1.12 * (radius-self.arcWidth/2), 0.237 * (radius-self.arcWidth/2))
        spentValueLabel.center = CGPointMake(self.frame.width/2, self.frame.height/2 + (radius - self.arcWidth/2) * 0.712)
        spentValueLabel.text = String(format: "$%.2f", self.spent)
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
//        let radius = rect.width/2-20
        let radius = min(rect.width, rect.height)/2 - 20
        if (self.spent == 0 && self.allowance == 0) {
            let path = UIBezierPath(arcCenter: CGPointMake(rect.width/2, rect.height/2), radius: radius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
            path.lineWidth = self.arcWidth
            self.allowanceColor.setStroke()
            path.stroke()
        } else {
            // upper left arc
            let path = UIBezierPath(arcCenter: CGPointMake(rect.width/2, rect.height/2), radius: radius, startAngle: self.startRadians(), endAngle: self.startRadians() + self.upperleftRadians(), clockwise: true)
            path.lineWidth = self.arcWidth
            self.upperleftColor().setStroke()
            path.stroke()
            
            // bottom right arc
            let path2 = UIBezierPath(arcCenter: CGPointMake(rect.width/2, rect.height/2), radius: radius, startAngle: self.bottomRightStartRadians(), endAngle: self.bottomRightStartRadians() - self.bottomrightRadians(), clockwise: false)
            path2.lineWidth = self.arcWidth
            self.bottomrightColor().setStroke()
            path2.stroke()
        }
        
        // dash line
        let path3 = UIBezierPath()
        let dashPattern:[CGFloat] = [1,3];
        path3.setLineDash(dashPattern, count: 2, phase: 2)
        path3.moveToPoint(CGPointMake(rect.width/2 - 0.9428 * (radius-self.arcWidth/2) + 2, rect.height/2 - 0.316 * (radius - self.arcWidth/2)))
        path3.addLineToPoint(CGPointMake(rect.width/2 + 0.9428 * (radius - self.arcWidth/2) - 2, rect.height/2 - 0.316 * (radius - self.arcWidth/2)))
        
        path3.moveToPoint(CGPointMake(rect.width/2 - 0.9428 * (radius-self.arcWidth/2) + 2, rect.height/2 + 0.316 * (radius - self.arcWidth/2)))
        path3.addLineToPoint(CGPointMake(rect.width/2 + 0.9428 * (radius - self.arcWidth/2) - 2, rect.height/2 + 0.316 * (radius - self.arcWidth/2)))
        
        path3.lineWidth = 1.0
        UIColor.grayColor().setStroke()
        path3.stroke()
        
        // upperleft legend line
        
        if (self.spent != 0 || self.allowance != 0) {
            let path4 = UIBezierPath()
            path4.moveToPoint(CGPointMake(rect.width/2 - 0.5 * (radius+self.arcWidth/2), rect.height/2 - 0.866 * (radius + self.arcWidth/2)))
            path4.addLineToPoint(CGPointMake(rect.width/2 - 0.5 * (radius+self.arcWidth/2) - 10, rect.height/2 - 0.866 * (radius + self.arcWidth/2) - 10))
            path4.addLineToPoint(CGPointMake(rect.width/2 - 0.5 * (radius+self.arcWidth/2) - 30, rect.height/2 - 0.866 * (radius + self.arcWidth/2) - 10))
            path4.lineWidth = 1.0
            UIColor.grayColor().setStroke()
            path4.stroke()
            
            // bottomright legend line
            if (self.spent <= self.allowance) {
                let path5 = UIBezierPath()
                path5.moveToPoint(CGPointMake(rect.width/2 + 0.5 * (radius+self.arcWidth/2), rect.height/2 + 0.866 * (radius + self.arcWidth/2)))
                path5.addLineToPoint(CGPointMake(rect.width/2 + 0.5 * (radius+self.arcWidth/2) + 10, rect.height/2 + 0.866 * (radius + self.arcWidth/2) + 10))
                path5.addLineToPoint(CGPointMake(rect.width/2 + 0.5 * (radius+self.arcWidth/2) + 30, rect.height/2 + 0.866 * (radius + self.arcWidth/2) + 10))
                path5.lineWidth = 1.0
                UIColor.grayColor().setStroke()
                path5.stroke()
            }
        }
    }
    
    private func upperleftColor() -> UIColor {
        if (self.spent > self.allowance) {
            return self.overspentColor
        } else {
            return self.allowanceColor
        }
    }
    
    private func bottomrightColor() -> UIColor {
        if (self.spent > self.allowance) {
            return self.allowanceColor
        } else {
            return self.savingColor
        }
    }
    
    private func startRadians() -> CGFloat {
        return CGFloat(M_PI * 8.0 / 6.0) - self.upperleftRadians() / 2.0
    }
    private func bottomRightStartRadians() -> CGFloat {
        return CGFloat(M_PI * 2.0  / 6.0) + self.bottomrightRadians() / 2.0
    }
    
    private func upperleftRadians() -> CGFloat {
        if (self.spent > self.allowance) {
            let rad = (CGFloat)(2 * M_PI * (self.spent - self.allowance) / self.spent) - 0.02
            return rad < 0 ? 0 : rad
        } else {    // saving mode
            let rad  = (CGFloat)(2 * M_PI * self.spent / self.allowance) - 0.02
            return rad < 0 ? 0 : rad
        }
    }
    
    private func bottomrightRadians() -> CGFloat {
        if (self.spent > self.allowance) {
            let rad = (CGFloat)(2 * M_PI * self.allowance / self.spent) - 0.02;
            return rad < 0 ? 0 : rad
        } else {    // saving mode
            let rad = (CGFloat)(2 * M_PI * (self.allowance - self.spent) / allowance) - 0.02;
            return rad < 0 ? 0 : rad
        }
    }
    
    
    func degreesToRadians(degrees:Double) -> CGFloat{
        return (CGFloat)(3.14159265359 * degrees / 180.0);
    }
    
    private func addSubviews() {
        upperleftLabel.font = UIFont(name: "HelveticaNeue-light", size: 12)
        upperleftLabel.textColor = UIColor(red: 84/255.0, green: 72/255.0, blue: 72/255.0, alpha: 1)
        upperleftLabel.numberOfLines = 0
        //upperleftLabel.adjustsFontSizeToFitWidth = true
        upperleftLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        self.addSubview(upperleftLabel)
        
        bottomrightLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        bottomrightLabel.textColor = UIColor(red: 84/255.0, green: 72/255.0, blue: 72/255.0, alpha: 1)
        //bottomrightLabel.adjustsFontSizeToFitWidth = true
        bottomrightLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        self.addSubview(bottomrightLabel)
        
        
        midLabel.textAlignment = NSTextAlignment.Center
        midLabel.adjustsFontSizeToFitWidth = true
        midLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        midLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 40)
        midLabel.numberOfLines = 1
        self.addSubview(midLabel)
        
        allowanceLabel.textAlignment = NSTextAlignment.Center
        allowanceLabel.text = "Daily Allowance:"
        allowanceLabel.textColor = UIColor(red: 65/255.0, green: 65/255.0, blue: 65/255.0, alpha: 1)
        allowanceLabel.adjustsFontSizeToFitWidth = true
        allowanceLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        allowanceLabel.font = UIFont(name: "HelveticaNeue-Light", size: allowanceLabel.font.pointSize)
        self.addSubview(allowanceLabel)
        
        allowanceValueLabel.textAlignment = NSTextAlignment.Center
        allowanceValueLabel.textColor = UIColor(red: 65/255.0, green: 65/255.0, blue: 65/255.0, alpha: 1)
        allowanceValueLabel.adjustsFontSizeToFitWidth = true
        allowanceValueLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        allowanceValueLabel.font = UIFont(name: "HelveticaNeue", size: allowanceValueLabel.font.pointSize)
        self.addSubview(allowanceValueLabel)
        
        spentValueLabel.textAlignment = NSTextAlignment.Center
        spentValueLabel.textColor = UIColor(red: 65/255.0, green: 65/255.0, blue: 65/255.0, alpha: 1)
        spentValueLabel.adjustsFontSizeToFitWidth = true
        spentValueLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        spentValueLabel.font = UIFont(name: "HelveticaNeue", size: spentValueLabel.font.pointSize)
        self.addSubview(spentValueLabel)
        
        spentLabel.textAlignment = NSTextAlignment.Center
        spentLabel.text = "Actual Spending:"
        spentLabel.textColor = UIColor(red: 65/255.0, green: 65/255.0, blue: 65/255.0, alpha: 1)
        spentLabel.adjustsFontSizeToFitWidth = true
        spentLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        spentLabel.font = UIFont(name: "HelveticaNeue-Light", size: spentLabel.font.pointSize)
        self.addSubview(spentLabel)
        print(UIFont.fontNamesForFamilyName("Helvetica Neue"))
    }

}
