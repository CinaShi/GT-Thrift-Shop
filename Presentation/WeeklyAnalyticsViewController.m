//
//  WeeklyAnalyticsViewController.m
//  Edvizer
//
//  Created by chensiding on 16/1/14.
//  Copyright © 2016年 Appfish. All rights reserved.
//

#import "WeeklyAnalyticsViewController.h"
#import "BannerTableViewCell.h"
#import "UIColor+Colors.h"

typedef NS_ENUM(NSUInteger, WeeklyAnalyticsViewCellSection) {
    WeeklyAnalyticsCellSection_Banner = 0,
    WeeklyAnalyticsCellSection_Week,
    WeeklyAnalyticsCellSection_MAX
};

@interface WeeklyAnalyticsViewController ()

@end

@implementation WeeklyAnalyticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:cellName_BannerTableViewCell bundle:nil] forCellReuseIdentifier:cellName_BannerTableViewCell];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"sectionHeader"];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return WeeklyAnalyticsCellSection_MAX;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == WeeklyAnalyticsCellSection_Banner) {
        return 1;
    } else {
        return 7;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == WeeklyAnalyticsCellSection_Banner) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellName_BannerTableViewCell];
        return cell;
    } else {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"sectionHeader"];
            cell.textLabel.text = @"10/22 - 10/28";
            cell.backgroundColor = [UIColor MainTintColor];
            cell.textLabel.textColor = [UIColor whiteColor];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            cell.textLabel.text = @"October 25th";
            if (indexPath.row %2 == 1) {
                cell.contentView.backgroundColor = [UIColor whiteColor];
            } else {
                cell.contentView.backgroundColor = [UIColor colorFromHexString:@"f2fdff"];
            }
            cell.textLabel.font = [UIFont systemFontOfSize:13];
        }
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == WeeklyAnalyticsCellSection_Banner) {
        return 70;
    } else {
        return 40;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == WeeklyAnalyticsCellSection_Week) {
        return 20;
    } else {
        return 0;
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
