//
//  AnalyticsHistoryViewController.m
//  Edvizer
//
//  Created by chensiding on 16/1/14.
//  Copyright © 2016年 Appfish. All rights reserved.
//

#import "AnalyticsHistoryViewController.h"
#import "UIColor+Colors.h"
#import "SearchView.h"
#import "UIView+Nib.h"
#import "WeeklyAnalyticsViewController.h"

@interface AnalyticsHistoryViewController ()

@property (strong, nonatomic) SearchView *searchView;

@end

@implementation AnalyticsHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Analytics History";
    self.tableView.tableFooterView = [UIView new];
    
    self.searchView = [SearchView viewFromNib];
    self.searchView.frame = CGRectMake(0, 0, self.view.frame.size.width, 75);
    self.tableView.tableHeaderView = self.searchView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"sectionHeaderCell" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"dateCell" forIndexPath:indexPath];
        
        if (indexPath.row %2 == 1) {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        } else {
            cell.contentView.backgroundColor = [UIColor colorFromHexString:@"f2fdff"];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row > 0) {
        WeeklyAnalyticsViewController *viewController = [[WeeklyAnalyticsViewController alloc]init];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
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
