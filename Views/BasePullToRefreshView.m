//
//  BasePullToRefreshView.m
//  HYTCosmetic
//
//  Created by yangshengchao on 15/1/4.
//  Copyright (c) 2015年 ZhongDaYunKe. All rights reserved.
//

#import "BasePullToRefreshView.h"

@implementation BasePullToRefreshView


//////////////////////////////////////////////////////////////////////////////////////////
//手动实例化view的初始化方法
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"initWithFrame，%@", NSStringFromCGRect(self.frame));
        [self initSbuviews];
    }
    return self;
}

//xib中实例化view的初始化方法
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"initWithCoder，%@", NSStringFromCGRect(self.frame));
        [self initSbuviews];
    }
    return self;
}

/*
 当你调用 -setNeedsDisplay，UIKit 将会在这个视图的图层上调用 -setNeedsDisplay。这为图层设置了一个标识，标记为 dirty(直译是脏的意思，想不出用什么词比较贴切,污染？)，但还显示原来的内容。它实际上没做任何工作，所以多次调用 -setNeedsDisplay 并不会造成性能损失。
 我的理解：就是设置一个参数dirty = YES;
 */
- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    NSLog(@"setNeedsDisplay，%@", NSStringFromCGRect(self.frame));
}

- (void)initSbuviews {
    NSLog(@"initSubviews，%@", NSStringFromCGRect(self.frame));
    
    
    
    //TODO:添加约束
}


//////////////////////////////////////////////////////////////////////////////////////////
- (void)setNeedsLayout {
    [super setNeedsLayout];
    NSLog(@"setNeedsLayout，%@", NSStringFromCGRect(self.frame));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"layoutSubviews，%@", NSStringFromCGRect(self.frame));
    
    self.segmentedControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height / 3)];
    self.segmentedControlView.backgroundColor = [UIColor redColor];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.segmentedControlView.height, self.width, self.height - self.segmentedControlView.height)];
    self.scrollView.backgroundColor = [UIColor blueColor];
    NSLog(@"segmentedControlView.frame=%@", NSStringFromCGRect(self.segmentedControlView.frame));
    [self addSubview:self.segmentedControlView];
    [self addSubview:self.scrollView];
}

- (void)drawRect:(CGRect)rect {
    NSLog(@"drawRect:%@，frame=%@", NSStringFromCGRect(rect), NSStringFromCGRect(self.frame));
}

//////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutIfNeeded {
    [super layoutIfNeeded];
    NSLog(@"layoutIfNeeded，%@", NSStringFromCGRect(self.frame));
}


- (void)setNeedsUpdateConstraints {
    [super setNeedsUpdateConstraints];
    NSLog(@"setNeedsUpdateConstraints，%@", NSStringFromCGRect(self.frame));
}



@end
