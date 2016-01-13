//
//  AlertChartTableViewCell.h
//  Edvizer
//
//  Created by chensiding on 16/1/12.
//  Copyright © 2016年 Appfish. All rights reserved.
//

#import <UIKit/UIKit.h>

#define cellName_AlertChartTableViewCell @"AlertChartTableViewCell"

@interface AlertChartTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *infoViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIView *chartViewContainer;

@end
