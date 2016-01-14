//
//  SearchView.m
//  Edvizer
//
//  Created by chensiding on 16/1/14.
//  Copyright © 2016年 Appfish. All rights reserved.
//

#import "SearchView.h"

@implementation SearchView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.searchButton.layer.cornerRadius = 5;
    self.searchButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.searchButton.layer.borderWidth = 1;
}

@end
