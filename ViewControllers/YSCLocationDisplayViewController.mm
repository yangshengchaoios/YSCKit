//
//  YSCLocationDisplayViewController.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/13.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "YSCLocationDisplayViewController.h"
#import "BNRoutePlanModel.h"
#import "BNCoreServices.h"

@interface YSCLocationDisplayViewController () <BMKMapViewDelegate, BMKRouteSearchDelegate, BNNaviUIManagerDelegate,BNNaviRoutePlanDelegate>
@property (nonatomic, weak) IBOutlet BMKMapView *mapView;
@property (strong, nonatomic) BMKRouteSearch *routesearch;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@property (weak, nonatomic) IBOutlet UIButton *startNavigateButton;//开始导航按钮
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
    self.mapView.delegate = self;
    self.mapView.zoomLevel = 15;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    self.mapView.showsUserLocation = NO;
    
    if (![self.params[kParamIsNavigationable] boolValue]) {
        [self addEndAnnotation];
        [self addStartAnnotation];//TODO:重新定位自己
        [self searchDrvingRoute];//线路规划
    }
    else {
        self.startNavigateButton.hidden = YES;
        [self addEndAnnotation];
    }
}

//目的地标记
- (void)addEndAnnotation {
    BMKCustomAnnotation *endAnnotation = [[BMKCustomAnnotation alloc] init];
    endAnnotation.type = 0;//终点
    endAnnotation.imageName = @"icon_location_normal";
    endAnnotation.coordinate = CLLocationCoordinate2DMake([self.params[kParamLatitude] doubleValue],
                                                          [self.params[kParamLongitude] doubleValue]);
    NSArray *annotationArray = @[endAnnotation];
    [self.mapView addAnnotations:annotationArray];
    [self.mapView showAnnotations:annotationArray animated:YES];
}

//起始标记(需要导航时才添加)
- (void)addStartAnnotation {
    BMKCustomAnnotation *startAnnotation = [[BMKCustomAnnotation alloc] init];
    startAnnotation.type = 0;//起点
    startAnnotation.imageName = @"icon_location_my";
    startAnnotation.coordinate = CLLocationCoordinate2DMake(EZGDATA.currentLatitude,EZGDATA.currentLongitude);
    NSArray *annotationArray = @[startAnnotation];
    [self.mapView addAnnotations:annotationArray];
    [self.mapView showAnnotations:annotationArray animated:NO];
}

//====================================
//
//  百度导航
//
//====================================
- (void)searchDrvingRoute {
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.pt = CLLocationCoordinate2DMake(EZGDATA.currentLatitude, EZGDATA.currentLongitude);
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.pt = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    
    BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
    drivingRouteSearchOption.from = start;
    drivingRouteSearchOption.to = end;
    BOOL flag = [self.routesearch drivingSearch:drivingRouteSearchOption];
    self.startNavigateButton.hidden = ! flag;
    if(flag) {
        NSLog(@"路径规划成功");
        //计算导航路径
        [self findRoutePlan];
    }
    else {
        NSLog(@"路径规划失败");
    }
}
- (void)findRoutePlan {
    NSMutableArray *nodesArray = [[NSMutableArray alloc]initWithCapacity:2];
    //起点 传入的是原始的经纬度坐标，若使用的是百度地图坐标，可以使用BNTools类进行坐标转化
    BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
    startNode.pos = [[BNPosition alloc] init];
    startNode.pos.x = EZGDATA.currentLongitude;
    startNode.pos.y = EZGDATA.currentLatitude;
    startNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:startNode];
    
    //NOTE:也可以在此加入1到3个的途经点
    
    //终点
    BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
    endNode.pos = [[BNPosition alloc] init];
    endNode.pos.x = self.longitude;
    endNode.pos.y = self.latitude;
    endNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:endNode];
    
    [BNCoreServices_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Recommend naviNodes:nodesArray time:nil delegete:self userInfo:nil];
}
//显示总的距离
- (void)layoutDistance:(int)totalDistance {
//    if (totalDistance < 1000) {
//        self.distanceLabel.text = [NSString stringWithFormat:@"%ld米", (long)totalDistance];
//    }
//    else {
//        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f公里", totalDistance / 1000.0];
//    }
}
//显示总的耗时
- (void)layoutTime:(BMKTime *)duration {
    NSMutableString *tempStr = [NSMutableString string];
    if (duration.dates > 0) {
        [tempStr appendFormat:@"%d天", duration.dates];
    }
    if (duration.hours > 0) {
        [tempStr appendFormat:@"%d小时", duration.hours];
    }
    if (duration.minutes > 0) {
        [tempStr appendFormat:@"%d分钟", duration.minutes];
    }
    if (duration.seconds > 0) {
        [tempStr appendFormat:@"%d秒", duration.seconds];
    }
//    self.timeLabel.text = tempStr;
}
//开始导航按钮
- (IBAction)startNavigateButtonClicked:(id)sender {
    if(NO == [BNCoreServices_Instance isServicesInited]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"引擎尚未初始化完成，请稍后再试"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else {//路径规划成功，开始导航
        [BNCoreServices_UI showNaviUI:BN_NaviTypeReal delegete:self isNeedLandscape:NO];
    }
}

#pragma mark - BNNaviRoutePlanDelegate
//算路成功回调
- (void)routePlanDidFinished:(NSDictionary *)userInfo {
    NSLog(@"算路成功,userinfo=%@", userInfo);
}
//算路失败回调
- (void)routePlanDidFailedWithError:(NSError *)error andUserInfo:(NSDictionary *)userInfo {
    NSLog(@"算路失败,userinfo=%@", userInfo);
    [self showResultThenHide:@"导航线路规划失败"];
    if ([error code] == BNRoutePlanError_LocationFailed) {
        NSLog(@"获取地理位置失败");
    }
    else if ([error code] == BNRoutePlanError_LocationServiceClosed)
    {
        NSLog(@"定位服务未开启");
    }
}
//算路取消回调
- (void)routePlanDidUserCanceled:(NSDictionary*)userInfo {
    NSLog(@"算路取消");
}

#pragma mark - BNNaviUIManagerDelegate
//退出导航回调
- (void)onExitNaviUI:(NSDictionary*)extraInfo {
    NSLog(@"退出导航");
}
//退出导航声明页面回调
- (void)onExitDeclarationUI:(NSDictionary*)extraInfo {
    NSLog(@"退出导航声明页面");
}
//退出电子狗回调
- (void)onExitDigitDogUI:(NSDictionary*)extraInfo {
    NSLog(@"退出电子狗页面");
}


#pragma mark - BMKMapViewDelegate
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(BMKCustomAnnotation *)annotation {
    BMKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"location_annotation"];
    if (nil == annotationView) {
        annotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"location_annotation"];
        annotationView.annotation = annotation;
        annotationView.canShowCallout = NO;
        annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    }
    annotationView.image = [UIImage imageNamed:annotation.imageName];
    return annotationView;
}
- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = RGBA(130, 241, 91, 0.7);
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 5.0;
        return polylineView;
    }
    return nil;
}

#pragma mark - BMKRouteSearchDelegate
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult *)result errorCode:(BMKSearchErrorCode)error {
    NSArray *array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
        int planPointCounts = 0;
        for (BMKDrivingStep *transitStep in plan.steps) {
            planPointCounts += transitStep.pointsCount;
        }
        //轨迹点
        BMKMapPoint *temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        int totalDistance = 0;
        for (BMKDrivingStep *transitStep in plan.steps) {
            for(int k = 0; k < transitStep.pointsCount; k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            totalDistance += transitStep.distance;//累加距离
        }
        [self layoutDistance:totalDistance];//显示总距离
        [self layoutTime:plan.duration];//显示总耗时
        
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
    }
}

@end
