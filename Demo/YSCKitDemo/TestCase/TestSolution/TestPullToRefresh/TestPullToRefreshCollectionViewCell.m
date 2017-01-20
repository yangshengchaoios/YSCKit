//
//  TestPullToRefreshCollectionViewCell.m
//  YSCKit
//
//  Created by Builder on 16/7/14.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "TestPullToRefreshCollectionViewCell.h"

@implementation TestPullToRefreshCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = kDefaultGrayColor;
}

+ (CGSize)sizeOfCellByObject:(NSObject *)object {
    return CGSizeMake(100, 120);
}

- (void)layoutObject:(SearchResultModel *)model {
    [self.coverImageView ysc_setImageWithURLString:model.pictureUrl];
    self.nameLabel.text = TRIM_STRING(model.title);
}

@end
