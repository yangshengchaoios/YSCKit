//
//  CommonItemModel.h
//  YSCKit
//
//  Created by Builder on 16/7/8.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCDataBaseModel.h"

@interface CommonItemModel : YSCDataBaseModel
@property (nonatomic, strong) NSString *sectionTitle;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *viewController;
+ (instancetype)createItemBySectionTitle:(NSString *)section title:(NSString *)title viewController:(NSString *)viewController;
@end
