//
//  RedSpotView.m
//
//  Created by Joey on 14-5-6.
//  Copyright (c) 2014年 Joey. All rights reserved.
//

#import "RedSpotView.h"

@implementation RedSpotView
{
    UILabel *_unreadLabel;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = RGB(255, 65, 73);
        _unreadLabel = [UILabel new];
        _unreadLabel.textColor = [UIColor whiteColor];
        _unreadLabel.backgroundColor = self.backgroundColor;
        _unreadLabel.font = [UIFont boldSystemFontOfSize:10.0f];
        _unreadLabel.textAlignment = NSTextAlignmentCenter;
        self.layer.masksToBounds = YES;
    }
    return self;
}


- (void)setUnreadNumber:(NSUInteger)unreadNumber
{
    _unreadNumber = unreadNumber;
    NSString *unreadStr = _unreadNumber>99?[NSString stringWithFormat:@"99+"]:[NSString stringWithFormat:@"%d",_unreadNumber];
    self.width = [unreadStr sizeWithFont:[UIFont boldSystemFontOfSize:10.0f] constrainedToSize:CGSizeMake(MAXFLOAT, 20)].width+4;
    self.width = self.width < 20? 20:self.width;
    self.height = 20.0f;
    if(unreadNumber>0){
        [self setNeedsDisplay];
        self.hidden = NO;
    }else{
        self.hidden = YES;
    }
}

- (void)drawRect:(CGRect)rect
{
    NSString *unreadStr = _unreadNumber>99?[NSString stringWithFormat:@"99+"]:[NSString stringWithFormat:@"%d",_unreadNumber];
    _unreadLabel.text = unreadStr;
    self.layer.cornerRadius = self.width > self.height+5?self.width/3:self.width/2;
    [_unreadLabel drawTextInRect:self.bounds];
}
@end
