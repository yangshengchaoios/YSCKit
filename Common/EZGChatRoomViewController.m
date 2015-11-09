//
//  EZGChatRoomViewController.m
//  EZGoal
//
//  Created by yangshengchao on 15/7/14.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "EZGChatRoomViewController.h"
#import "CDConversationStore.h"
#import "YSCPhotoBrowseViewController.h"
#import "TOCropViewController.h"

@interface EZGChatRoomViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,
ZYQAssetPickerControllerDelegate, TOCropViewControllerDelegate>

@end

@implementation EZGChatRoomViewController

- (void)dealloc {
    NSLog(@"EZGChatRoomViewController deallocing...");
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [AppConfigManager sharedInstance].currentViewController = self;
    APPDATA.chatUser = [[ChatUserModel alloc] initWithString:self.conv.attributes[OtherUserInfo] error:nil];
    self.title = Trim(APPDATA.chatUser.realName);
    if (NO == IsAppTypeC) {//B端才需要更新用户信息
        [self refreshUserInfo];
    }
    
    WEAKSELF
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:DefaultNaviBarArrowBackImage style:UIBarButtonItemStylePlain handler:^(id sender) {
        if (weakSelf.messageInputView.isRecording) {
            return ;//正在录音中
        }
        [weakSelf.view endEditing:YES];
        if (weakSelf.navigationController) {
            NSInteger index = [self.navigationController.viewControllers indexOfObject:weakSelf];
            if (index > 0) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else {
                [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
        else {
            [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"icon_phone_white"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        if (weakSelf.messageInputView.isRecording) {
            return ;//正在录音中
        }
        [YSCCommonUtils MakeCall:APPDATA.chatUser.phoneNumber success:^{
            [EZGUtils FunctionStatisticsByOperaCode:@"khgn" type:@"3"];
        }];
    }];
}

#pragma mark - 刷新对方用户信息
//刷新聊天对方用户的个人信息(主要是解决头像和昵称不同步的问题)
- (void)refreshUserInfo {
    WEAKSELF
    [ChatUserModel GetByMethod:kResPathGetUserInfo
                        params:@{kParamUserId : Trim(APPDATA.chatUser.userId)}
                         block:^(NSObject *object, NSError *error) {
                             ChatUserModel *chatUser = (ChatUserModel *)object;
                             if (isEmpty(error) && [chatUser isKindOfClass:[ChatUserModel class]] &&
                                 isNotEmpty(chatUser.avatarUrl) && isNotEmpty(chatUser.realName)) {
                                 //判断是否需要保存用户信息
                                 if (![chatUser.phoneNumber isEqualToString:APPDATA.chatUser.phoneNumber] ||
                                     ![chatUser.avatarUrl isEqualToString:APPDATA.chatUser.avatarUrl] ||
                                     ![chatUser.realName isEqualToString:APPDATA.chatUser.realName]) {
                                     APPDATA.chatUser = chatUser;
                                     weakSelf.title = Trim(chatUser.realName);
                                     [weakSelf updateUserInfo:[chatUser toJSONString]];//保存修改信息
                                     [weakSelf.messageTableView reloadData];//刷新本页列表
                                 }
                             }
                         }];
}
//更新会话对象里的用户信息 FIXME:应该本地缓存用户信息而不是去更新会话对象！
- (void)updateUserInfo:(NSString *)userInfo {
    WEAKSELF
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
    [tempDict addEntriesFromDictionary:self.conv.attributes];
    tempDict[OtherUserInfo] = Trim(userInfo);
    //更新会话属性,内存对象已经更新！数据库里之所以更新了是因为父类清空了未读数
    AVIMConversationUpdateBuilder *updateBuilder = [self.conv newUpdateBuilder];
    updateBuilder.attributes = tempDict;
    [self.conv update:[updateBuilder dictionary] callback:^(BOOL succeeded, NSError *error) {
        if (isEmpty(error)) {
            [[CDConversationStore store] updateConversation:weakSelf.conv];
            if (weakSelf.refreshCellBlock) {//已经是最新的会话了，直接刷新cell，更新头像和昵称
                weakSelf.refreshCellBlock(nil);
            }
        }
        else {
            [[CDConversationStore store] updateConversation:weakSelf.conv];
        }
    }];
}

#pragma mark - XHMessageTableViewCellDelegate
- (void)multiMediaMessageDidSelectedOnMessage:(id <XHMessageModel> )message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(EZGMessageBaseCell *)messageTableViewCell {
    if (self.messageInputView.isRecording) {
        return;
    }
    if (XHBubbleMessageMediaTypePhoto == message.messageMediaType) {//点击图片进入图片浏览器
        YSCPhotoBrowseViewController *photoDetail = (YSCPhotoBrowseViewController *)[UIResponder createBaseViewController:@"YSCPhotoBrowseViewController"];
        if (isNotEmpty(message.thumbnailUrl)) {
            photoDetail.params = @{kParamImageUrls : @[Trim(message.thumbnailUrl)]};
            [self.navigationController pushViewController:photoDetail animated:NO];
        }
        else if (isNotEmpty(message.photo)) {
            photoDetail.params = @{kParamImages : @[message.photo]};
            [self.navigationController pushViewController:photoDetail animated:NO];
        }
    }
    else if (XHBubbleMessageMediaTypeLocalPosition == message.messageMediaType) {
        //FIXME: 打开百度地图
        XHDisplayLocationViewController *displayLocationViewController = [[XHDisplayLocationViewController alloc] init];
        displayLocationViewController.message = message;
        [self.navigationController pushViewController:displayLocationViewController animated:YES];
    }
    else {
//        [super multiMediaMessageDidSelectedOnMessage:message atIndexPath:indexPath onMessageTableViewCell:messageTableViewCell];
    }
}

#pragma mark - XHShareMenuViewDelegate
- (void)didSelecteShareMenuItem:(XHShareMenuItem *)shareMenuItem atIndex:(NSInteger)index {
    DLog(@"title : %@   index:%ld", shareMenuItem.title, (long)index);
    if (0 == index) {
        if ([UIDevice isPhotoLibraryAvailable]) { //打开多图选择器
            ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
            picker.delegate = self;
            picker.maximumNumberOfSelection = 9;
            picker.assetsFilter = [ALAssetsFilter allPhotos];
            picker.showEmptyGroups = NO;
            picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
                    NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
                    return duration >= 5;
                }
                else {
                    return YES;
                }
            }];
            [self presentViewController:picker animated:YES completion:NULL];
        }
        else {
            [UIView showAlertVieWithMessage:@"请在设置->隐私->照片,打开本应用的权限"];
        }
    }
    else if (1 == index) {
        if ([UIDevice isCanUseCamera]) { //打开摄像头，获取的图片要保存到自定义相册EZGoal
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = NO;
            imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
        else {
            [UIView showAlertVieWithMessage:@"请在设置->隐私->相机,打开本应用的权限"];
        }
    }
    else if (2 == index) {//FIXME: 发送百度地图的位置信息
        if ([UIDevice isLocationAvaible]) {
            WEAKSELF
            [UIView showHUDLoadingOnWindow:@"正在发送位置"];
            [self.locationHelper getCurrentGeolocationsCompled:^(NSArray *placemarks) {
                CLPlacemark *placemark = [placemarks lastObject];
                if (placemark) {
                    [UIView hideHUDLoadingOnWindow];
                    NSDictionary *addressDictionary = placemark.addressDictionary;
                    NSArray *formattedAddressLines = [addressDictionary valueForKey:@"FormattedAddressLines"];
                    NSString *geoLocations = [formattedAddressLines lastObject];
                    if (geoLocations) {
                        [weakSelf didSendGeolocationsMessageWithGeolocaltions:geoLocations location:placemark.location];
                    }
                }
                else {
                    [UIView hideHUDLoadingOnWindow];
                    [UIView showAlertVieWithMessage:@"发送位置信息出错，请检查系统设置中是否打开位置服务"];
                }
            }];
        }
        else {
            [YSCCommonUtils OpenPrivacyOfSetting];
        }
    }
    else {
        [super didSelecteShareMenuItem:shareMenuItem atIndex:index];
    }
}


//----------------------------------------
//
// 图片选择器 + 拍照
//
//----------------------------------------
#pragma mark - ZYQAssetPickerControllerDelegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    for (int i = 0; i<assets.count; i++) {
        ALAsset *asset = assets[i];
        UIImage *pickedImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        UIImage *sendImage = [self resizeImage:pickedImage];
        [self didSendMessageWithPhoto:sendImage];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    WEAKSELF
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *pickedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        if ( ! pickedImage) {
            pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        //处理获得的图片对象
        if (pickedImage) {
            [weakSelf didSendMessageWithPhoto:[weakSelf resizeImage:pickedImage]];
            [[ALAssetsLibrary new] saveImage:pickedImage toAlbum:@"EZGoal" completion:nil failure:nil];
            
            //裁剪图片
            //            TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:pickedImage];
            //            cropController.delegate = weakSelf;
            //            [weakSelf presentViewController:cropController animated:YES completion:nil];
        }
        else {
            [UIView showResultThenHideOnWindow:@"未选择图片"];
        }
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TOCropViewControllerDelegate
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle {
    WEAKSELF
    [cropViewController dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf didSendMessageWithPhoto:[weakSelf resizeImage:image]];
        });
    }];
    
}
- (void)cropViewController:(TOCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled {
    [cropViewController dismissViewControllerAnimated:YES completion:nil];
}
//压缩图片大小
- (UIImage *)resizeImage:(UIImage *)image {
    CGFloat width = SCREEN_WIDTH_SCALE;
    CGFloat height = width * (image.size.height / image.size.width);
    return [YSCImageUtils resizeImage:image toSize:CGSizeMake(width, height)];
}

@end
