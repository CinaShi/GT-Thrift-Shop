//
//  UIView+Nib.m
//  yunshizhushou
//
//  Created by chensiding on 15/6/6.
//  Copyright (c) 2015年 com.kangfuzi.yunshizhushou. All rights reserved.
//

#import "UIView+Nib.h"

@implementation UIView(Nib)

+ (id)viewFromNib
{
    UIView *result = nil;
    NSArray* elements = [[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner: nil options: nil];
    
    for (id anObject in elements) {
        if ([anObject isKindOfClass:[self class]]){
            result = anObject;
            break;
        }
    }
    return result;
}

@end
