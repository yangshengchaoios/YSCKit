//
//  EZGRescueCarInfoViewController.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/13.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGRescueCarInfoViewController.h"

@interface EZGRescueCarInfoViewController ()
@property (nonatomic, weak) IBOutlet UILabel *carModelLabel;
@property (nonatomic, weak) IBOutlet UILabel *carYearLabel;
@property (nonatomic, weak) IBOutlet UILabel *carNumberLabel;
@property (nonatomic, weak) IBOutlet UILabel *mileAgeLabel;
@property (nonatomic, weak) IBOutlet UILabel *registerDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *carVehicleNumberLabel;
@property (nonatomic, weak) IBOutlet UILabel *carEngineNumberLabel;
@end

@implementation EZGRescueCarInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"待援车辆";
    
    self.carModelLabel.text = nil;
    self.carYearLabel.text = nil;
    self.carNumberLabel.text = nil;
    self.mileAgeLabel.text = nil;
    self.registerDateLabel.text = nil;
    self.carVehicleNumberLabel.text = nil;
    self.carEngineNumberLabel.text = nil;
    
    MyCarModel *carModel = self.params[kParamModel];
    if (isNotEmpty(carModel.modelYear)) {
        self.carModelLabel.text = [NSString stringWithFormat:@"%@ %@ %@款", Trim(carModel.brandName),
                                   [NSString replaceString:carModel.seriesName byRegex:carModel.brandName to:@""],
                                   Trim(carModel.modelYear)];
    }
    else {
        self.carModelLabel.text = [NSString stringWithFormat:@"%@ %@", Trim(carModel.brandName),
                                   [NSString replaceString:carModel.seriesName byRegex:carModel.brandName to:@""]];
    }
    self.carYearLabel.text = Trim(carModel.modelName);
    if ([carModel.carMileage integerValue] > 0) {
        self.mileAgeLabel.text = [NSString stringWithFormat:@"%ld公里", [carModel.carMileage integerValue]];
    }
    self.registerDateLabel.text = [NSDate ConvertDateString:carModel.carRegisterDate fromFormat:DateFormat1 toFormat:DateFormat5];
    self.carVehicleNumberLabel.text = Trim(carModel.carVehicleNumber);
    self.carEngineNumberLabel.text = Trim(carModel.carEngineNumber);
}

@end
