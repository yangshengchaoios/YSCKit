//
//  EZGAddressSearchCell.m
//  EZGoal
//
//  Created by 钟博文 on 15/11/3.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGAddressSearchCell.h"

@implementation EZGAddressSearchCell

+ (CGFloat)HeightOfCellByObject:(NSObject *)object {
    return AUTOLAYOUT_LENGTH(102);
}
- (void)layoutObject:(SearchPoiModel *)dataModel {
    self.nameLabel.text = dataModel.poiName;
    self.addressLabel.text = dataModel.poiAddress;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        self.checkmarkImgView.hidden = NO;
    }
    else {
        self.checkmarkImgView.hidden = YES;
    }
}

@end
