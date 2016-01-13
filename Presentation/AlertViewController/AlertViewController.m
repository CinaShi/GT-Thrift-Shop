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
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == AlertViewCellSection_Banner) {
        BannerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName_BannerTableViewCell];
        
        return cell;
    } else if (indexPath.section == AlertViewCellSection_Chart) {
        AlertChartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName_AlertChartTableViewCell];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.textLabel.text = @"cell";
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == AlertViewCellSection_Banner) {
        return 80;
    } else if (indexPath.section == AlertViewCellSection_Chart) {
        return 340;
    }
    
    return 80;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
