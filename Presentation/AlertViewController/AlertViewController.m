//
//  AlertViewController.m
//  Edvizer
//
//  Created by chensiding on 16/1/12.
//  Copyright © 2016年 Appfish. All rights reserved.
//

#import "AlertViewController.h"
#import "BannerTableViewCell.h"
#import "AlertChartTableViewCell.h"
#import "UIColor+Colors.h"

typedef NS_ENUM(NSUInteger, AlertViewCellSection) {
    AlertViewCellSection_Banner = 0,
    AlertViewCellSection_Chart,
    AlertViewCellSection_Today,
    AlertViewCellSection_Recursive,
    AlertViewCellSection_Max
};

@interface AlertViewController ()

@end

@implementation AlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"Daily Summary - 10/21/2015";
    
    [self.tableView registerNib:[UINib nibWithNibName:cellName_BannerTableViewCell bundle:nil] forCellReuseIdentifier:cellName_BannerTableViewCell];
    [self.tableView registerNib:[UINib nibWithNibName:cellName_AlertChartTableViewCell bundle:nil] forCellReuseIdentifier:cellName_AlertChartTableViewCell];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellSectionHeader"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return AlertViewCellSection_Max;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == AlertViewCellSection_Today) {
        return 4;
    } else if (section == AlertViewCellSection_Recursive) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == AlertViewCellSection_Banner) {
        BannerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName_BannerTableViewCell];
        
        return cell;
    } else if (indexPath.section == AlertViewCellSection_Chart) {
        AlertChartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName_AlertChartTableViewCell];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.section == AlertViewCellSection_Today) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSectionHeader"];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = [UIFont systemFontOfSize:15 weight:0.2];
            cell.textLabel.text = @"Today's Transactions";
            cell.backgroundColor = [UIColor mainTintColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
            
            NSArray *titles  = @[@"", @"Coco Garden", @"Chipotle", @"Party"];
            NSArray *subTitles  = @[@"", @"-$30.00", @"-$12.99", @"-$38.99"];
            cell.textLabel.text = titles[indexPath.row];
            cell.detailTextLabel.text = subTitles[indexPath.row];
            
            cell.textLabel.font = [UIFont systemFontOfSize:12 weight:0.1];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13 weight:0.1];
            cell.textLabel.textColor = [UIColor textColor];
            cell.detailTextLabel.textColor = [UIColor textColor];
            
            if (indexPath.row %2 == 1) {
                cell.backgroundColor = [UIColor whiteColor];
            } else {
                cell.backgroundColor = [UIColor colorFromHexString:@"f2fdff"];
            }
            
            return cell;
        }
    } else {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSectionHeader"];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = [UIFont systemFontOfSize:15 weight:0.2];
            cell.textLabel.text = @"Recurring Bill Transaction";
            cell.backgroundColor = [UIColor mainTintColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
            
            NSArray *titles  = @[@"", @"MeLife Insurance"];
            NSArray *subTitles  = @[@"", @"-$50.00"];
            cell.textLabel.text = titles[indexPath.row];
            cell.detailTextLabel.text = subTitles[indexPath.row];
            
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13 weight:0.1];
            cell.textLabel.textColor = [UIColor textColor];
            cell.detailTextLabel.textColor = [UIColor textColor];
            
            if (indexPath.row %2 == 1) {
                cell.backgroundColor = [UIColor whiteColor];
            } else {
                cell.backgroundColor = [UIColor colorFromHexString:@"f2fdff"];
            }
            
            return cell;
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = @"cell";
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section >= AlertViewCellSection_Today) {
        return 20;
    } else {
        return CGFLOAT_MIN;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == AlertViewCellSection_Banner) {
        return 80;
    } else if (indexPath.section == AlertViewCellSection_Chart) {
        return 340;
    } else {
        if (indexPath.row == 0) {
            return 25;
        } else {
            return 40;
        }
    }
    
    return 80;
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
