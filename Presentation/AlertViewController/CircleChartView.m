//
//  CircleChartView.m
//  Edvizer
//
//  Created by chensiding on 16/1/12.
//  Copyright © 2016年 Appfish. All rights reserved.
//

#import "CircleChartView.h"
#import "UIColor+Colors.h"

@implementation CircleChartView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    CGRect frame = self.frame;
    CGFloat radius = (frame.size.height - 30) / 2;
    
    UIBezierPath *leftCirclePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0) radius:radius startAngle:M_PI / 2 endAngle:M_PI * 2.5 clockwise:YES];
    _leftCircleLayer = [[CAShapeLayer alloc]init];
    _leftCircleLayer.path = leftCirclePath.CGPath;
    _leftCircleLayer.fillColor = [UIColor clearColor].CGColor;
    
    _leftCircleLayer.strokeColor = [UIColor colorFromHexString:@"3bc7d5"].CGColor;
    _leftCircleLayer.lineWidth = 15;
    _leftCircleLayer.strokeStart = 0.001;
    _leftCircleLayer.strokeEnd = 0.75 - 0.001;
    
    [self.layer addSublayer:_leftCircleLayer];
    
    UIBezierPath *rightCirclePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0) radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    _rightCircleLayer = [[CAShapeLayer alloc]init];
    _rightCircleLayer.path = rightCirclePath.CGPath;
    _rightCircleLayer.fillColor = [UIColor clearColor].CGColor;
    
    _rightCircleLayer.strokeColor = [UIColor colorFromHexString:@"26da88"].CGColor;
    _rightCircleLayer.lineWidth = 15;
    _rightCircleLayer.strokeStart = 0;
    _rightCircleLayer.strokeEnd = 0.25;

    [self.layer addSublayer:_rightCircleLayer];

    CGFloat y = 20;
    CGFloat yStep = (frame.size.height - 40) / 3;
    CGFloat lineWidth = radius * 2 - 40;
    CGFloat x = frame.size.width / 2 - lineWidth / 2;
    
    for (int i=0;i<2;i++) {
        CAShapeLayer *layer = [[CAShapeLayer alloc]init];
        UIBezierPath *path = [[UIBezierPath alloc]init];
        [path moveToPoint:CGPointMake(x, y + yStep * (i+1))];
        [path addLineToPoint:CGPointMake(x + lineWidth, y + yStep * (i+1))];
        
        [layer setLineWidth:1/[UIScreen mainScreen].scale];
        [layer setLineDashPattern:
         [NSArray arrayWithObjects:[NSNumber numberWithInt:2],
          [NSNumber numberWithInt:1],nil]];
        [layer setLineJoin:kCALineJoinRound];
        layer.path = path.CGPath;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.strokeColor = [UIColor lightGrayColor].CGColor;
        layer.strokeEnd = 1;

        [self.layer addSublayer:layer];
    }
    
    _centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y + yStep, lineWidth, yStep)];
    _centerLabel.text = @"Saving: $19.88";
    _centerLabel.textAlignment = NSTextAlignmentCenter;
    _centerLabel.textColor = [UIColor colorFromHexString:@"26da88"];
    _centerLabel.font = [UIFont systemFontOfSize:24];
    _centerLabel.numberOfLines = 1;
    _centerLabel.adjustsFontSizeToFitWidth = YES;
    _centerLabel.minimumScaleFactor = 0.5;
    _centerLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self addSubview:_centerLabel];
    
    _topInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y + 10, lineWidth, yStep *0.45)];
    _topInfoLabel.text = @"Daily Allowance:";
    _topInfoLabel.textAlignment = NSTextAlignmentCenter;
    _topInfoLabel.font = [UIFont systemFontOfSize:8];
    _topInfoLabel.textColor = [UIColor colorFromHexString:@"414141"];
    _topInfoLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self addSubview:_topInfoLabel];
    
    _topDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y + yStep *0.4, lineWidth, yStep *0.6)];
    _topDataLabel.text = @"$78.69";
    _topDataLabel.textAlignment = NSTextAlignmentCenter;
    _topDataLabel.font = [UIFont systemFontOfSize:18];
    _topDataLabel.textColor = [UIColor colorFromHexString:@"414141"];
    _topDataLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self addSubview:_topDataLabel];
    
    _bottonInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y + yStep *2, lineWidth, yStep * 0.4)];
    _bottonInfoLabel.text = @"Actual Spending:";
    _bottonInfoLabel.textAlignment = NSTextAlignmentCenter;
    _bottonInfoLabel.font = [UIFont systemFontOfSize:8];
    _bottonInfoLabel.textColor = [UIColor colorFromHexString:@"414141"];
    _bottonInfoLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self addSubview:_bottonInfoLabel];
    
    _bottonDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y + yStep *2.4 - 10, lineWidth, yStep *0.6)];
    _bottonDataLabel.text = @"$59.01";
    _bottonDataLabel.textAlignment = NSTextAlignmentCenter;
    _bottonDataLabel.font = [UIFont systemFontOfSize:18];
    _bottonDataLabel.textColor = [UIColor colorFromHexString:@"414141"];
    _bottonDataLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self addSubview:_bottonDataLabel];
    
    _leftLegendLine = [[CAShapeLayer alloc]init];
    
    UIBezierPath *leftLegendLinePath = [[UIBezierPath alloc]init];
    
    CGFloat r = radius + 9;
    CGFloat r2= radius + 18;
    CGFloat xoffsetRatio = 0.5 * sqrt(2);
    CGFloat yoffsetRatio = 0.5 * sqrt(2);
    CGFloat horizontalLineWidth = 15;
    
    [leftLegendLinePath moveToPoint:CGPointMake(frame.size.width / 2 - r * xoffsetRatio, frame.size.height / 2 - r * yoffsetRatio)];
    [leftLegendLinePath addLineToPoint:CGPointMake(frame.size.width / 2 - r2 * xoffsetRatio, frame.size.height / 2 - r2 * yoffsetRatio)];
    [leftLegendLinePath addLineToPoint:CGPointMake(frame.size.width / 2 - r2 * xoffsetRatio - horizontalLineWidth, frame.size.height / 2 - r2 * yoffsetRatio)];
    [_leftLegendLine setLineWidth:1/[UIScreen mainScreen].scale];

    _leftLegendLine.path = leftLegendLinePath.CGPath;
    _leftLegendLine.fillColor = [UIColor clearColor].CGColor;
    _leftLegendLine.strokeColor = [UIColor darkGrayColor].CGColor;
    _leftLegendLine.strokeEnd = 1;
    
    [self.layer addSublayer:_leftLegendLine];
    
    _leftLegendLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width / 2 - r2 * xoffsetRatio - horizontalLineWidth - 40, frame.size.height / 2 - r2 * yoffsetRatio - 100, 40, 200)];
    _leftLegendLabel.numberOfLines = 0;
    _leftLegendLabel.textAlignment = NSTextAlignmentCenter;
    _leftLegendLabel.text = @"Actual Spending";
    _leftLegendLabel.font = [UIFont systemFontOfSize:8 weight:0.1];
    _leftLegendLabel.textColor = [UIColor colorFromHexString:@"414141"];
    
    [self addSubview:_leftLegendLabel];
    
    _rightLegendLine = [[CAShapeLayer alloc]init];
    
    UIBezierPath *rightLegendLinePath = [[UIBezierPath alloc]init];
    
    [rightLegendLinePath moveToPoint:CGPointMake(frame.size.width / 2 + r * xoffsetRatio, frame.size.height / 2 + r * yoffsetRatio)];
    [rightLegendLinePath addLineToPoint:CGPointMake(frame.size.width / 2 + r2 * xoffsetRatio, frame.size.height / 2 + r2 * yoffsetRatio)];
    [rightLegendLinePath addLineToPoint:CGPointMake(frame.size.width / 2 + r2 * xoffsetRatio + horizontalLineWidth, frame.size.height / 2 + r2 * yoffsetRatio)];
    [_rightLegendLine setLineWidth:1/[UIScreen mainScreen].scale];
    
    _rightLegendLine.path = rightLegendLinePath.CGPath;
    _rightLegendLine.fillColor = [UIColor clearColor].CGColor;
    _rightLegendLine.strokeColor = [UIColor darkGrayColor].CGColor;
    _rightLegendLine.strokeEnd = 1;
    
    [self.layer addSublayer:_rightLegendLine];
    
    _rightLegendLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width / 2 + r2 * xoffsetRatio + horizontalLineWidth, frame.size.height / 2 + r2 * yoffsetRatio - 100, 40, 200)];
    _rightLegendLabel.numberOfLines = 0;
    _rightLegendLabel.textAlignment = NSTextAlignmentCenter;
    _rightLegendLabel.text = @"Saving";
    _rightLegendLabel.font = [UIFont systemFontOfSize:8 weight:0.1];
    _rightLegendLabel.textColor = [UIColor colorFromHexString:@"414141"];
    
    [self addSubview:_rightLegendLabel];
}

@end
