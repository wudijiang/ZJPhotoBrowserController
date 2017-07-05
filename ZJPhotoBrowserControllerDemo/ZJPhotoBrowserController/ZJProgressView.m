//
//  ZJProgressView.m
//  ZJPhotoBrowserControllerDemo
//
//  Created by YZJ on 16/4/13.
//  Copyright © 2016年 YZJ. All rights reserved.
//

#import "ZJProgressView.h"

@implementation ZJProgressView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI
{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 圆环
    CGFloat circleX = self.center.x;
    CGFloat circleY = self.center.y;
    CGFloat radius = 15;
    
    [[UIColor colorWithWhite:0 alpha:0.2] set];
    CGContextAddArc(ctx, circleX, circleY, radius+2, 0, M_PI*2, 0);
    CGContextFillPath(ctx);
    
    [[UIColor colorWithWhite:1 alpha:1] set];
    // CGContextSetLineWidth(ctx, 2);
    CGContextAddArc(ctx, circleX, circleY, radius+2, 0, M_PI*2, 0);
    CGContextStrokePath(ctx);
    
    CGContextMoveToPoint(ctx, circleX, circleY);
    CGFloat endAngleChange = M_PI*2*_progress;
    if (endAngleChange < 0.3) {
        endAngleChange = 0.3;
    }
    CGContextAddArc(ctx, circleX, circleY, radius, -M_PI_2, -M_PI_2+endAngleChange, 0);
    CGContextClosePath(ctx);
    // CGContextStrokePath(ctx);
    CGContextFillPath(ctx);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.frame = [UIScreen mainScreen].bounds;
}
@end
