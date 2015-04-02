//
//  YSCPickerView.h
//  KQ
//
//  Created by YangShengchao on 15/3/28.
//  Copyright (c) 2015年 yangshengchao. All rights reserved.
//

#import "RegionModel.h"

typedef NS_ENUM(NSInteger, YSCPickerType) {
    YSCPickerTypeDate = 0,
    YSCPickerTypeTime,
    YSCPickerTypeDateTime,
    YSCPickerTypeAddress ,
};

@interface YSCPickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerBottom;//260

@property (assign, nonatomic) YSCPickerType pickerType;
@property (copy, nonatomic) CallBackWithResponseBlock selectingBlock;
@property (copy, nonatomic) CallBackBlock completionShowBlock;
@property (copy, nonatomic) CallBackBlock completionHideBlock;


- (void)showPickerView:(id)initObject;
- (void)hidePickerView;

@end
