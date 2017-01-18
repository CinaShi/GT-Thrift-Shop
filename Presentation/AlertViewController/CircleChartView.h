//
//  CircleChartView.h
//  Edvizer
//
//  Created by chensiding on 16/1/12.
//  Copyright © 2016年 Appfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleChartView : UIView

@property (strong, nonatomic) CAShapeLayer *leftLegendLine;
@property (strong, nonatomic) CAShapeLayer *rightLegendLine;
@property (strong, nonatomic) UILabel *leftLegendLabel;
@property (strong, nonatomic) UILabel *rightLegendLabel;

@property (strong, nonatomic) CAShapeLayer *leftCircleLayer;
@property (strong, nonatomic) CAShapeLayer *rightCircleLayer;

@property (strong, nonatomic) UILabel *centerLabel;
@property (strong, nonatomic) UILabel *topInfoLabel;
@property (strong, nonatomic) UILabel *topDataLabel;
@property (strong, nonatomic) UILabel *bottonInfoLabel;
@property (strong, nonatomic) UILabel *bottonDataLabel;

@end
