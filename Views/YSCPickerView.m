//
//  YSCPickerView.m
//  KQ
//
//  Created by YangShengchao on 15/3/28.
//  Copyright (c) 2015年 yangshengchao. All rights reserved.
//

#import "YSCPickerView.h"

#define HeightOfContainerView       360
#define DurationOfAnimation         0.3f

@interface YSCPickerView ()

@property (nonatomic, strong) NSArray *provinceArray;
@property (nonatomic, weak) ProvinceModel *currentPovinceModel;
@property (nonatomic, weak) CityModel *currentCityModel;
@property (nonatomic, weak) SectionModel *currentSectionModel;

@end

@implementation YSCPickerView

- (void)awakeFromNib {
    [super awakeFromNib];
    WeakSelfType blockSelf = self;
    
    //初始化
    self.containerBottom.constant = -AUTOLAYOUT_LENGTH(HeightOfContainerView);
    self.hidden = YES;
    [UIView makeRoundForView:self.doneButton withRadius:5];
    [UIView makeBorderForView:self.doneButton withColor:[UIColor blackColor] borderWidth:1];
    [self.datePicker bk_addEventHandler:^(id sender) {
        if (YSCPickerTypeDate == blockSelf.pickerType) {
            if (blockSelf.selectingBlock) {
                blockSelf.selectingBlock([blockSelf.datePicker date]);
            }
        }
    } forControlEvents:UIControlEventValueChanged];
    self.datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [self.datePicker setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
    [self.datePicker setMinimumDate:[NSDate dateFromString:@"1930-01-01" withFormat:DateFormat3]];
    [self.datePicker setMaximumDate:[NSDate date]];

    
    //点击半透明关闭选择器
    [self bk_whenTapped:^{
        [blockSelf hidePickerView];
    }];
    
    //点击完成按钮关闭选择器
    [self.doneButton bk_addEventHandler:^(id sender) {
        [blockSelf hidePickerView];
    } forControlEvents:UIControlEventTouchUpInside];
}
- (void)setPickerType:(YSCPickerType)pickerType {
    _pickerType = pickerType;
    if (YSCPickerTypeDate == pickerType) {
        self.pickerView.hidden = YES;
        self.datePicker.hidden = NO;
    }
    else {
        self.pickerView.hidden = NO;
        self.datePicker.hidden = YES;
    }
    
    //必须要初始化数据
    if (YSCPickerTypeAddress == pickerType) {
        if ([NSArray isEmpty:self.provinceArray]) {
            self.provinceArray = [ProvinceModel initProvinces];
        }
    }
    else if (YSCPickerTypeDate == pickerType) {
        self.datePicker.datePickerMode = UIDatePickerModeDate;
    }
    else if (YSCPickerTypeTime == pickerType) {
        self.datePicker.datePickerMode = UIDatePickerModeTime;
    }
    else if (YSCPickerTypeDateTime == pickerType) {
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
}
- (void)showPickerView:(id)initObject {
    self.hidden = NO;
    [UIView animateWithDuration:DurationOfAnimation animations:^{
        self.containerBottom.constant = AUTOLAYOUT_LENGTH(0);
        if (self.completionShowBlock) {
            self.completionShowBlock();
        }
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        //必须重新刷新界面
        if (YSCPickerTypeAddress == self.pickerType) {
            RegionModel *initRegion = (RegionModel *)initObject;
            if ([NSObject isNotEmpty:initRegion] && [initRegion isKindOfClass:[RegionModel class]]) {
                //选中province
                [self.pickerView reloadAllComponents];
                for (int i = 0; i < [self.provinceArray count]; i++) {
                    ProvinceModel *province = self.provinceArray[i];
                    if (initRegion.pid == province.pid) {
                        self.currentPovinceModel = province;
                        [province initCityArray];
                        [self.pickerView selectRow:i inComponent:0 animated:YES];
                        break;
                    }
                }
                //选中city
                if (self.currentPovinceModel) {
                    [self.pickerView reloadComponent:1];
                    for (int i = 0; i < [self.currentPovinceModel.cityArray count]; i++) {
                        CityModel *city = self.currentPovinceModel.cityArray[i];
                        if (initRegion.cid == city.cid) {
                            self.currentCityModel = city;
                            [city initSectionArray];
                            [self.pickerView selectRow:i inComponent:1 animated:YES];
                            break;
                        }
                    }
                }
                //选择section
                if (self.currentCityModel) {
                    [self.pickerView reloadComponent:2];
                    for (int i = 0; i < [self.currentCityModel.sectionArray count]; i++) {
                        SectionModel *section = self.currentCityModel.sectionArray[i];
                        if (initRegion.sid == section.sid) {
                            self.currentSectionModel = section;
                            [self.pickerView selectRow:i inComponent:2 animated:YES];
                            break;
                        }
                    }
                }
            }
            else {
                [self.pickerView reloadAllComponents];
            }
        }
        else if (YSCPickerTypeDate == self.pickerType) {
            NSDate *initDate = (NSDate *)initObject;
            if ([NSObject isEmpty:initDate] || (! [initDate isKindOfClass:[NSDate class]])) {
                initDate = [NSDate date];
            }
            [self.datePicker setDate:initDate animated:YES];
        }
        else {
            //NOTE:other picker type
        }
    }];
}
- (void)hidePickerView {
    [UIView animateWithDuration:DurationOfAnimation animations:^{
        self.containerBottom.constant = -AUTOLAYOUT_LENGTH(HeightOfContainerView);
        if (self.completionHideBlock) {
            self.completionHideBlock();
        }
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (YSCPickerTypeAddress == self.pickerType) {
        return 3;
    }
    return 0;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (YSCPickerTypeAddress == self.pickerType) {
        if (0 == component) {
            return [self.provinceArray count];
        }
        else if (1 == component) {
            return [self.currentPovinceModel.cityArray count];
        }
        else if (2 == component) {
            return [self.currentCityModel.sectionArray count];
        }
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 32;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (YSCPickerTypeAddress == self.pickerType) {
        if (0 == component) {
            return [(ProvinceModel *)self.provinceArray[row] province];
        }
        else if (1 == component) {
            return [(CityModel *)self.currentPovinceModel.cityArray[row] city];
        }
        else if (2 == component) {
            return [(SectionModel *)self.currentCityModel.sectionArray[row] section];
        }
    }
    return nil;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (YSCPickerTypeAddress == self.pickerType) {
        if (0 == component) {
            self.currentPovinceModel = self.provinceArray[row];
            [self.currentPovinceModel initCityArray];
            
            self.currentCityModel = self.currentPovinceModel.cityArray[0];
            [self.currentCityModel initSectionArray];
            
            self.currentSectionModel = self.currentCityModel.sectionArray[0];
            
            [pickerView reloadComponent:1];
            [pickerView reloadComponent:2];
            [pickerView selectRow:0 inComponent:1 animated:YES];
            [pickerView selectRow:0 inComponent:2 animated:YES];
        }
        else if (1 == component) {
            self.currentCityModel = self.currentPovinceModel.cityArray[row];
            [self.currentCityModel initSectionArray];
            
            self.currentSectionModel = self.currentCityModel.sectionArray[0];
            
            [pickerView reloadComponent:2];
            [pickerView selectRow:0 inComponent:2 animated:YES];
        }
        else if (component == 2) {
            self.currentSectionModel = self.currentCityModel.sectionArray[row];
        }
        
        //回调选中的结果
        if (self.currentPovinceModel && self.currentCityModel && self.currentSectionModel) {
            RegionModel *regionModel = [RegionModel new];
            regionModel.pid = self.currentPovinceModel.pid;
            regionModel.province = self.currentPovinceModel.province;
            regionModel.cid = self.currentCityModel.cid;
            regionModel.city = self.currentCityModel.city;
            regionModel.sid = self.currentSectionModel.sid;
            regionModel.section = self.currentSectionModel.section;
            if (self.selectingBlock) {
                self.selectingBlock(regionModel);
            }
        }
        else {
            if (self.selectingBlock) {
                self.selectingBlock(nil);
            }
        }
    }
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *titleLabel = (UILabel*)view;
    if (!titleLabel) {
        CGSize size = [pickerView rowSizeForComponent:component];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = AUTOLAYOUT_FONT(32);
    }
    
    NSString *titleString = @"";
    if (0 == component) {
        titleString = [(ProvinceModel *)self.provinceArray[row] province];
    }
    else if (1 == component) {
        titleString = [(CityModel *)self.currentPovinceModel.cityArray[row] city];
    }
    else if (2 == component) {
        titleString = [(SectionModel *)self.currentCityModel.sectionArray[row] section];
    }
    titleLabel.text = titleString;
    return titleLabel;
}

@end
