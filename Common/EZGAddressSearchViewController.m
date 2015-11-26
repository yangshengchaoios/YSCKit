//
//  EZGAddressSearchViewController.m
//  EZGoal
//
//  Created by yangshengchao on 15/10/22.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGAddressSearchViewController.h"
#import "EZGAddressSearchCell.h"
#import "MJRefresh.h"

@interface EZGAddressSearchViewController () <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,BMKMapViewDelegate, BMKLocationServiceDelegate, BMKPoiSearchDelegate, BMKGeoCodeSearchDelegate, UIScrollViewDelegate>

//地图相关
@property (weak, nonatomic) IBOutlet UIView *mapViewContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewContainerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeightToTop;
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeight;             //410/240
@property (strong, nonatomic) NSString *locationChangedIdentifier;
@property (nonatomic, assign) BOOL isNeedReSearchByLocation;                        //是否需要重新解析中心GPS坐标
@property (nonatomic, strong) BMKPoiSearch *poiSearch;                              //poi搜索器
@property (nonatomic, assign) BOOL isLocatationModified;                            //地理位置信息是否已经更新，防止自动定位延迟修改
@property (nonatomic, strong) SearchPoiModel *selectedPoiModel;                     //当前用户选择的位置信息
@property (nonatomic, strong) NSString *userSelectedCity;

@property (weak, nonatomic) IBOutlet YSCTableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIImageView *centerImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerImageViewHeightToTop;
@property (nonatomic, assign) BOOL isSearch;//判断是否是搜索结果界面传过来的

//搜索相关
@property (strong, nonatomic) UISearchBar *searchBar;                               //搜索输入框
@property (strong, nonatomic) UISearchDisplayController *searchDisplayController;   //搜索控制器
@property (strong, nonatomic) NSMutableArray *searchResultArray;                    //搜索结果数组
@property (assign, nonatomic) NSInteger currentPageIndex;                           //搜索结果页码，从1开始
@property (nonatomic, assign) NSInteger currentSelectedRow;                         //当前选中的行号
@property (nonatomic, assign) float y;
@end

@implementation EZGAddressSearchViewController

- (void)dealloc {
    if (self.mapView) {
        self.mapView = nil;
    }
    if (self.poiSearch) {
        self.poiSearch = nil;
    }
    if (self.locationChangedIdentifier) {
        [APPDATA bk_removeObserversWithIdentifier:self.locationChangedIdentifier];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mapView viewWillAppear];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil; // 不用时，置nil
    self.poiSearch.delegate = nil;
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    WEAKSELF
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"位置";
    self.tableView.didScrollBlock = ^() {
        [UIView animateWithDuration:0.3 animations:^{
            if (weakSelf.tableView.contentOffset.y > 0) {
                weakSelf.mapViewContainerViewHeight.constant = AUTOLAYOUT_LENGTH(250);
                float height = AUTOLAYOUT_LENGTH(44) + AUTOLAYOUT_LENGTH(125) - AUTOLAYOUT_LENGTH(60);
                weakSelf.centerImageViewHeightToTop.constant = height;//根据坐标来调整
                weakSelf.mapViewHeightToTop.constant = - weakSelf.mapViewContainerViewHeight.constant / 2.0f;
            }
            else if (weakSelf.tableView.contentOffset.y < 0) {
                weakSelf.mapViewContainerViewHeight.constant = AUTOLAYOUT_LENGTH(500);
                weakSelf.centerImageViewHeightToTop.constant = AUTOLAYOUT_LENGTH(234);
                weakSelf.mapViewHeightToTop.constant = 0;
            }
            [weakSelf.view layoutIfNeeded];
        }];
    };
    [self initMapView];
    [self initSearchBar];
    [self initTableView];
    [EZGDATA startLocationService];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"确定" style:UIBarButtonItemStylePlain handler:^(id sender) {
        if (weakSelf.block) {
            weakSelf.block(weakSelf.selectedPoiModel);
        }
        [weakSelf backViewController];
    }];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"取消" style:UIBarButtonItemStylePlain handler:^(id sender) {
        [weakSelf backViewController];
    }];
}

//初始化地图相关
- (void)initMapView {
    WEAKSELF
    //初始化地图搜索相关
    self.poiSearch = [[BMKPoiSearch alloc]init];
    self.poiSearch.delegate = self;
    
    //设置mapView
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.mapView.zoomLevel = 17;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    //去除精度圈
    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc]init];
    displayParam.isAccuracyCircleShow = NO;//精度圈是否显示
    displayParam.locationViewImgName= @"icon_center_point";//定位图标名称
    displayParam.locationViewOffsetX = 0;//定位偏移量(经度)
    displayParam.locationViewOffsetY = 0;//定位偏移量（纬度）
    [self.mapView updateLocationViewWithParam:displayParam];
    self.mapView.showsUserLocation = YES;//显示定位图层
    self.isLocatationModified = NO;
    
    //定位当前位置
    if (nil == EZGDATA.userLocation) {
        [EZGDATA startLocationService];
        self.locationChangedIdentifier = [APPDATA bk_addObserverForKeyPath:@"currentLongitude" task:^(id target) {
            if (weakSelf.isLocatationModified) {//NOTE:如果位置信息被修改了，就关闭定位直接返回
                if (weakSelf.locationChangedIdentifier) {
                    [APPDATA bk_removeObserversWithIdentifier:weakSelf.locationChangedIdentifier];//关闭自动定位
                    weakSelf.locationChangedIdentifier = nil;
                }
                return ;
            }
            
            if (EZGDATA.userLocation) {//定位成功，启动地理位置解析
                if (weakSelf.locationChangedIdentifier) {
                    [APPDATA bk_removeObserversWithIdentifier:weakSelf.locationChangedIdentifier];//关闭自动定位
                    weakSelf.locationChangedIdentifier = nil;
                }
                [weakSelf.mapView updateLocationData:EZGDATA.userLocation];
                [weakSelf searchByLocationCoordinate:CLLocationCoordinate2DMake(EZGDATA.currentLatitude, EZGDATA.currentLongitude)];
            }
            else {
                //定位失败
            }
        }];
    }
    else {
        [self.mapView updateLocationData:EZGDATA.userLocation];
        [self searchByLocationCoordinate:CLLocationCoordinate2DMake(EZGDATA.currentLatitude, EZGDATA.currentLongitude)];
    }

}
//解析GPS坐标
- (void)searchByLocationCoordinate:(CLLocationCoordinate2D)reverseGeoPoint {
//    [self showAddressLocationByLocationCoordinate:reverseGeoPoint];
    [self.mapView setCenterCoordinate:reverseGeoPoint animated:YES];
    WEAKSELF
    [EZGDATA resolveLocationCoordinate:reverseGeoPoint block:^(NSObject *object) {
        if (object) {
            BMKReverseGeoCodeResult *result = (BMKReverseGeoCodeResult *)object;
            if (isEmpty(weakSelf.userSelectedCity)) {//保证城市只设置一次
                weakSelf.userSelectedCity = Trim(result.addressDetail.city);
            }
            NSMutableArray *tempArray = [NSMutableArray array];
            if (weakSelf.selectedPoiModel && self.isSearch == YES) {
                weakSelf.isSearch = NO;
                [tempArray addObject:weakSelf.selectedPoiModel];
            }
            SearchPoiModel *firstPoiModel = [SearchPoiModel new];
            firstPoiModel.poiName = Trim(result.addressDetail.streetName);
            firstPoiModel.poiAddress = Trim(result.address);
            firstPoiModel.poiLocation = result.location;
            [tempArray addObject:firstPoiModel];
            
            NSArray *poiInfoList = result.poiList;
            for (NSInteger i=0; i<poiInfoList.count; i++) {
                BMKPoiInfo *info = poiInfoList[i];
                SearchPoiModel *model = [[SearchPoiModel alloc]init];
                model.poiName = info.name;
                model.poiAddress = info.address;
                model.poiLocation = info.pt;
                [tempArray addObject:model];
            }
            weakSelf.currentSelectedRow = 0;
            [weakSelf.tableView refreshAtPageIndex:kDefaultPageStartIndex response:tempArray error:nil];
            //选中后滚动
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        else {
            [weakSelf.tableView refreshAtPageIndex:kDefaultPageStartIndex response:nil error:@"位置信息解析失败"];
        }
    }];
}
//初始化searchBar
- (void)initSearchBar {
    WEAKSELF
    self.searchResultArray = [NSMutableArray array];
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"搜索地点";
    [self.view addSubview:self.searchBar];
    
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    //搜索结果表rect
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
//    self.searchDisplayController.searchResultsTableView.rowHeight = AUTOLAYOUT_LENGTH(102);
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.searchDisplayController.searchResultsTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    NSLog(@"self.searchDisplayController.searchResultsTableView.subViews:%@",self.searchDisplayController.searchResultsTableView.subviews);
    [EZGAddressSearchCell registerCellToTableView:self.searchDisplayController.searchResultsTableView];
    self.searchDisplayController.searchResultsTableView.contentSize = CGSizeMake(0, 20);
    self.searchDisplayController.searchResultsTableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf searchByPageIndex:weakSelf.currentPageIndex + 1];
    }];
    //修改背景色 228 231 233
    self.searchBar.barTintColor = RGB(228, 231, 233);
    [self.searchBar setBackgroundImage:[UIImage imageNamed:@"image_search_background.png"]];
    
}
//初始化表
- (void)initTableView {
    WEAKSELF
    //实现以下四个属性的设置就可以简单的使用框架
    self.tableView.cellName = @"EZGAddressSearchCell";
    self.tableView.enableRefresh = NO;
    self.tableView.enableLoadMore = NO;//TODO:如何加载更多数据？
    self.tableView.cellSeperatorLeft = 30;
    self.tableView.separatorColor = RGB(228, 228, 228);
    self.tableView.requestType = RequestTypeCustomResponse;
    self.tableView.tipsView.actionButton.hidden = YES;
    self.tableView.clickCellBlock = ^(NSObject *object,NSIndexPath *indexPath) {
        //只刷新打钩
        weakSelf.isNeedReSearchByLocation = NO;
        weakSelf.currentSelectedRow = indexPath.row;
        [weakSelf.tableView reloadData];
        
        //移动地图
        weakSelf.selectedPoiModel = (SearchPoiModel *)object;
        [weakSelf.mapView setCenterCoordinate:weakSelf.selectedPoiModel.poiLocation animated:YES];
    };
    self.tableView.layoutCellView = ^(UIView *view, NSObject *object) {
        EZGAddressSearchCell *cell = (EZGAddressSearchCell *)view;
        NSArray *tempArray = weakSelf.tableView.cellDataArray[0];
        if ([tempArray indexOfObject:object] == weakSelf.currentSelectedRow) {
            weakSelf.selectedPoiModel = (SearchPoiModel *)object;
            cell.isSelected = YES;
        }
        else {
            cell.isSelected = NO;
        }
        [cell layoutObject:object];
    };
    self.tableView.willBeginDeceleratingBlock = ^{
        //TODO:压缩mapView
    };
}
//按照关键词进行搜索
- (void)searchByPageIndex:(NSInteger)pageIndex {
    if (isEmpty(self.searchBar.text)) {
        return;
    }
    if (isNotEmpty(self.userSelectedCity)) {//在当前城市中查找poi
        BMKCitySearchOption *option = [[BMKCitySearchOption alloc]init];
        option.city = self.userSelectedCity;//利用定位的城市来检索
        option.keyword = Trim(self.searchBar.text);
        option.pageCapacity = kDefaultPageSize;
        option.pageIndex = (int)(pageIndex - 1);
        [self.poiSearch poiSearchInCity:option];
    }
    else {//TODO:根据中心点、半径和检索词发起周边检索 poiSearchNearBy
        
    }
}

#pragma mark - searchResultsDataSource searchResultsDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResultArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EZGAddressSearchCell *cell = [EZGAddressSearchCell dequeueCellByTableView:tableView];
    SearchPoiModel *dataModel = self.searchResultArray[indexPath.row];
    cell.nameLabel.text = dataModel.poiName;
    cell.addressLabel.text = dataModel.poiAddress;
    cell.checkmarkImgView.hidden = YES;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.isLocatationModified = YES;
    [self.searchDisplayController setActive:NO animated:YES];
    self.selectedPoiModel = self.searchResultArray[indexPath.row];
    NSLog(@"%f %f",self.selectedPoiModel.poiLocation.longitude,self.selectedPoiModel.poiLocation.latitude);
    self.isSearch = YES;
    [self.searchResultArray removeAllObjects];//移除搜索结果，以免下次搜索的时候再次出现
    [self searchByLocationCoordinate:self.selectedPoiModel.poiLocation];
}
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView{
    tableView.rowHeight = AUTOLAYOUT_LENGTH(100);
}
#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {

}
//搜索按钮点击方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (isEmpty(self.searchBar.text)) {
        [self showResultThenHide:@"搜索内容不能为空"];
        return;
    }
    [searchBar resignFirstResponder];
    [self searchByPageIndex:kDefaultPageStartIndex];
}
//取消按钮点击事件
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchResultArray removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}
//searchBar搜索框内容变化的时候调用
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //NOTE:微信是在删除的时候清空列表；增加文字不改变列表！
}

#pragma mark - BMKPoiSearchDelegate 城市检索
//返回POI搜索结果
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode {
    self.currentPageIndex = poiResult.pageIndex + 1;
    if (kDefaultPageStartIndex == self.currentPageIndex) {
        [self.searchResultArray removeAllObjects];
    }
    NSInteger oldCount = [self.searchResultArray count];//加载更多时要用
    if (self.isSearch) {
        self.isSearch = NO;
        [self.searchResultArray addObject:self.selectedPoiModel];//添加选中的那个cell模型数据
    }
    for (BMKPoiInfo *info in poiResult.poiInfoList) {
        SearchPoiModel *tempModel = [SearchPoiModel new];
        tempModel.poiName = Trim(info.name);
        tempModel.poiAddress = [NSString stringWithFormat:@"%@%@",Trim(info.city),Trim(info.address)];
        tempModel.poiLocation = info.pt;
        [self.searchResultArray addObject:tempModel];
    }
    
    if (kDefaultPageStartIndex == self.currentPageIndex) {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else {
        [UIView insertTableViewCell:self.searchDisplayController.searchResultsTableView oldCount:oldCount addCount:[poiResult.poiInfoList count]];
        [self.searchDisplayController.searchResultsTableView.footer endRefreshing];
    }
}

#pragma mark - BMKMapViewDelegate
//地图初始化完毕时会调用此接口
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    [self.mapView updateLocationData:EZGDATA.userLocation];
    [self locationButtonClick:self.locationButton];
}
//地图区域改变完成后会调用此接口
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.isLocatationModified = YES;
    if (self.isNeedReSearchByLocation) {
        //选中结果cell后，让其第一个数据显示选中的，不要移动地图
        [self searchByLocationCoordinate:CLLocationCoordinate2DMake(self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude)];
    }
    else {
        self.isNeedReSearchByLocation = YES;
    }
}
#pragma mark - 定位按钮点击事件
- (IBAction)locationButtonClick:(id)sender {
    [self.mapView setCenterCoordinate:EZGDATA.userLocation.location.coordinate animated:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.searchDisplayController.searchResultsTableView) {
        [scrollView setContentInset:UIEdgeInsetsMake(0, 0, AUTOLAYOUT_LENGTH(20), 0)];
        [scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, AUTOLAYOUT_LENGTH(20), 0)];
    }
}

@end
