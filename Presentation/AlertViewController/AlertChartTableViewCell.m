//
//  AlertChartTableViewCell.m
//  Edvizer
//
//  Created by chensiding on 16/1/12.
//  Copyright © 2016年 Appfish. All rights reserved.
//

#import "AlertChartTableViewCell.h"

@implementation AlertChartTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [AlertChartTableViewCell applyStyleToView:self.infoViewContainer];
    [AlertChartTableViewCell applyStyleToView:self.chartViewContainer];
    
}

+ (void)applyStyleToView:(UIView *)view {
    view.layer.cornerRadius = 8;
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 0.5f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
