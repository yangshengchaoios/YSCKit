//
//  TestPullToRefreshResultTableViewCell1.m
//  YSCKit
//
//  Created by Builder on 16/7/14.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "TestPullToRefreshResultTableViewCell1.h"

@implementation TestPullToRefreshResultTableViewCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = kDefaultGrayColor;
    [self.playButton ysc_addCornerWithRadius:40 / 2];
    [self.playButton ysc_makeBorderWithColor:kDefaultBlueColor1 borderWidth:1];
}
+ (CGFloat)heightOfCellByObject:(NSObject *)object {
    return 115;
}
- (void)layoutObject:(SearchResultModel *)model {
    [self.coverImageView ysc_setImageWithURLString:model.pictureUrl];
    self.nameLabel.text = TRIM_STRING(model.title);
}

@end
