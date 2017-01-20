//
//  SearchPromptModel.h
//  YSCKit
//
//  Created by Builder on 16/7/14.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCDataBaseModel.h"

@interface SearchPromptModel : YSCDataBaseModel
@property (nonatomic, assign) NSInteger promptId;
@property (nonatomic, strong) NSString *promptName;
@property (nonatomic, assign) NSInteger promptType;
@end
