//
//  YSCLocationDisplayViewController.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/13.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "YSCLocationDisplayViewController.h"

@interface YSCLocationDisplayViewController () <BMKMapViewDelegate>
@property (nonatomic, weak) IBOutlet BMKMapView *mapView;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@end

@implementation YSCLocationDisplayViewController

- (void)dealloc {
    if (self.mapView) {
        self.mapView = nil;
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mapView viewWillAppear];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil; // 不用时，置nil
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地理位置";
    //设置mapView
    self.mapView.delegate = self;
    self.mapView.zoomLevel = 15;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    self.mapView.showsUserLocation = NO;
    
    //放置大头针
    BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc]init];
    annotation.coordinate = CLLocationCoordinate2DMake([self.params[kParamLatitude] doubleValue],
                                                       [self.params[kParamLongitude] doubleValue]);
    [self.mapView addAnnotations:@[annotation]];
    [self.mapView showAnnotations:@[annotation] animated:YES];
}

@end
