//
//  YSCShare.m
//  MicroVideo
//
//  Created by 杨胜超 on 16/12/21.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCShare.h"

static YSCShareCompletion shareCompletion;
static NSMutableDictionary *appKeys;

@implementation YSCShareMessage
- (NSString *)title {
    if (_title) {
        return _title;
    } else {
        return @"";
    }
}
- (NSString *)content {
    if (_content) {
        return _content;
    } else {
        return self.title;
    }
}
- (NSString *)link {
    if (_link) {
        return _link;
    } else {
        return @"";
    }
}
- (NSString *)extraInfo {
    if (_extraInfo) {
        return _extraInfo;
    } else {
        return @"";
    }
}
- (NSString *)mediaDataUrl {
    if (_mediaDataUrl) {
        return _mediaDataUrl;
    } else {
        return @"";
    }
}
- (NSString *)fileExtention {
    if (_fileExtention) {
        return _fileExtention;
    } else {
        return @"";
    }
}

- (NSData *)fullImageData {
    if (self.fullImage) {
        return UIImageJPEGRepresentation(self.fullImage, 1);
    } else {
        return nil;
    }
}
- (NSString *)titleBase64 {
    if ( ! _titleBase64) {
        _titleBase64 = self.title.ysc_Base64EncryptString;
    }
    return _titleBase64;
}
- (NSString *)contentBase64 {
    if ( ! _contentBase64) {
        _contentBase64 = self.content.ysc_Base64EncryptString;
    }
    return _contentBase64;
}
- (NSString *)linkBase64 {
    if ( ! _linkBase64) {
        _linkBase64 = self.link.ysc_Base64EncryptString;
    }
    return _linkBase64;
}
- (NSData *)thumbImageDataWithSize:(CGSize)size {
    if (self.thumbImage) {
        return UIImageJPEGRepresentation(self.thumbImage, 1);
    } else {
        return [self _dataWithImage:self.fullImage scale:size];
    }
}
- (NSData *)_dataWithImage:(UIImage *)image scale:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImageJPEGRepresentation(scaledImage, 1);
}
@end

@implementation YSCShare

+ (void)registerAppKey:(NSString *)appKey forPlatform:(YSCSharePlatform)platform {
    if ( ! appKey) {
        return;
    }
    if ( ! appKeys) {
        appKeys = [NSMutableDictionary dictionary];
    }
    appKeys[@(platform)] = appKey;
}
+ (BOOL)isInstalled:(YSCSharePlatform)platform {
    if (platform == YSCSharePlatformWeiXin) {
        return [self _canOpen:@"weixin://"];
    } else if (platform == YSCSharePlatformQQ) {
        return [self _canOpen:@"mqqapi://"];
    } else if (platform == YSCSharePlatformSinaWeibo) {
        return [self _canOpen:@"weibosdk://request"];
    } else if (platform == YSCSharePlatformAlipay) {
        return [self _canOpen:@"alipay://"];
    }
    return NO;
}
+ (void)authOn:(YSCSharePlatform)platform redirectURI:(NSString *)redirectURI completion:(YSCShareCompletion)completion; {
    NSString *url = nil;
    NSError *error = nil;
    if (platform == YSCSharePlatformWeiXin) {
        NSString *appKey = appKeys[@(YSCSharePlatformWeiXin)];
        if ([self _isEmpty:appKey]) {
            error = [self _createError:@"没有设置微信的AppId"];
        } else {
            if ( ! [self isInstalled:YSCSharePlatformWeiXin]) {
                error = [self _createError:@"没有安装微信App"];
            } else {
                url = [NSString stringWithFormat:@"weixin://app/%@/auth/?scope=%@&state=Weixinauth", appKey, @"snsapi_userinfo"];
            }
        }
    } else if (platform == YSCSharePlatformSinaWeibo) {
        NSString *appKey = appKeys[@(YSCSharePlatformSinaWeibo)];
        if ([self _isEmpty:appKey]) {
            error = [self _createError:@"没有设置新浪微博的AppId"];
        } else {
            if ( ! [self isInstalled:YSCSharePlatformSinaWeibo]) {
                error = [self _createError:@"没有安装新浪微博"];
            } else {
                NSString *bundleName = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] infoDictionary][@"CFBundleName"]];
                NSString *bundleIdentifier = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"]];
                NSString *requestId = [[NSUUID UUID] UUIDString];
                NSDictionary *transferDict = @{@"__class" : @"WBAuthorizeRequest",
                                               @"scope" : @"all",
                                               @"requestID" : requestId,
                                               @"redirectURI" : redirectURI ?: @""};
                NSDictionary *userInfoDict = @{@"myKey" : @"user's id of my app",
                                               @"SSO_From" : @"SendMessageToWeiboViewController"};
                NSData *transferData = [NSKeyedArchiver archivedDataWithRootObject:transferDict];
                NSData *userInfoData = [NSKeyedArchiver archivedDataWithRootObject:userInfoDict];
                NSData *appData = [NSKeyedArchiver archivedDataWithRootObject:@{@"appKey" : appKey, @"bundleID" : bundleIdentifier, @"name" : bundleName}];
                [UIPasteboard generalPasteboard].items = @[@{@"transferObject" : transferData}, @{@"userInfo" : userInfoData}, @{@"app" : appData}];
                url = [NSString stringWithFormat:@"weibosdk://request?id=%@&sdkversion=003013000", requestId];
            }
        }
    } else {
        error = [self _createError:@"未定义操作"];
    }
    
    if (error) {
        if (completion) {
            completion(nil, error);
        }
        return;
    }
    if ( ! url) {
        if (completion) {
            completion(nil, [self _createError:@"登录的url为空"]);
        }
        return;
    }
    shareCompletion = completion;//等待处理后再回调
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}
+ (void)shareMessage:(YSCShareMessage *)message type:(YSCShareType)type completion:(YSCShareCompletion)completion {
    NSString *url = nil;
    NSError *error = [self _createError:@"暂不支持该平台"];
    if (type == YSCShareTypeWeiXinSession || type == YSCShareTypeWeiXinTimeline || type == YSCShareTypeWeiXinFavorite) {
        url = [self _handleMessageToWeiXin:message type:type error:&error];
    } else if (type == YSCShareTypeQQFriends || type == YSCShareTypeQQZone || type == YSCShareTypeQQFavorite || type == YSCShareTypeQQDataline) {
        url = [self _handleMessageToQQ:message type:type error:&error];
    } else if (type == YSCShareTypeSinaWeibo) {
        url = [self _handleMessageToSinaWeibo:message type:type error:&error];
    } else {
        error = [self _createError:@"未定义操作"];
    }
    
    if (error) {
        if (completion) {
            completion(nil, error);
        }
        return;
    }
    if ( ! url) {
        if (completion) {
            completion(nil, [self _createError:@"分享的url为空"]);
        }
        return;
    }
    shareCompletion = completion;//等待处理后再回调
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}


#pragma mark - 公共方法
+ (NSError *)setValue:(NSDictionary *)dict forPasteboardType:(NSString*)key encoding:(YSCSharePasteboardEncodingType)encoding {
    if (dict && key) {
        NSData *data = nil;
        NSError *error = nil;
        if (YSCSharePasteboardEncodingTypeKeyedArchiver == encoding) {
            data = [NSKeyedArchiver archivedDataWithRootObject:dict];
        } else if (YSCSharePasteboardEncodingTypeListSerialization == encoding) {
            data = [NSPropertyListSerialization dataWithPropertyList:dict format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
        }
        [[UIPasteboard generalPasteboard] setData:data forPasteboardType:key];
        return error;
    } else {
        return [self _createError:@"剪贴板中不能存放空数据"];
    }
}
+ (NSDictionary *)getValueByKey:(NSString*)key encoding:(YSCSharePasteboardEncodingType)encoding {
    NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:key];
    NSDictionary *dict = nil;
    if (data) {
        NSError *err;
        if (YSCSharePasteboardEncodingTypeKeyedArchiver == encoding) {
            dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        } else if (YSCSharePasteboardEncodingTypeListSerialization == encoding) {
            dict = [NSPropertyListSerialization propertyListWithData:data options:0 format:0 error:&err];
        }
    }
    return dict;
}
+ (void)handleOpenURL:(NSURL *)url {
    if ([url.scheme hasPrefix:@"wx"]) {
        [self _handleWeiXinOpenURL:url];
    } else if ([url.scheme hasPrefix:@"QQ"] || [url.scheme hasPrefix:@"tencent"]) {
        [self _handleQQOpenURL:url];
    } else if ([url.scheme hasPrefix:@"wb"]) {
        [self _handleSinaWeiboOpenURL:url];
    } else {
        [self _customHandleOpenURL:url];
    }
}

#pragma mark - 私有方法
+ (void)_customHandleOpenURL:(NSURL *)url {
    // 扩展用
}
+ (BOOL)_canOpen:(NSString*)url {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]];
}
+ (NSError *)_createError:(NSString *)errorMessage {
    return [NSError errorWithDomain:@"YSCShare" code:0 userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
}
+ (NSError *)_createError:(NSString *)errorMessage code:(NSInteger)code {
    return [NSError errorWithDomain:@"YSCShare" code:code userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
}
+ (NSError *)_createErrorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:@"YSCShare" code:code userInfo:userInfo];
}
+ (BOOL)_isEmpty:(NSObject *)object {
    return (object == nil
            || [object isKindOfClass:[NSNull class]]
            || ([object respondsToSelector:@selector(length)] && [(NSData *)object length] == 0)
            || ([object respondsToSelector:@selector(count)]  && [(NSArray *)object count] == 0));
}
+ (BOOL)_isNotEmpty:(NSObject *)object {
    return ! [self _isEmpty:object];
}

#pragma mark - 处理微信数据
+ (NSString *)_handleMessageToWeiXin:(YSCShareMessage *)message type:(YSCShareType)type error:(out NSError **)error {
    // 0. 检查appid是否设置
    NSString *appKey = appKeys[@(YSCSharePlatformWeiXin)];
    if ([self _isEmpty:appKey]) {
        *error = [self _createError:@"没有设置微信的AppId"];
        return @"";
    }
    if ( ! [self isInstalled:YSCSharePlatformWeiXin]) {
        *error = [self _createError:@"没有安装微信App"];
        return @"";
    }
    
    // 1. TODO: 进一步检查info.plist中设置的合法性！
    
    // 2. 根据message的shareMessageType属性组装对应的参数
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (type == YSCShareTypeWeiXinSession) {
        dict[@"scene"] = @"0";
    } else if (type == YSCShareTypeWeiXinTimeline) {
        dict[@"scene"] = @"1";
    } else if (type == YSCShareTypeWeiXinFavorite) {
        dict[@"scene"] = @"2";
    } else {
        *error = [self _createError:@"share type is undefined"];
        return @"";
    }
    dict[@"result"] = @"1";
    dict[@"returnFromApp"] = @"0";
    dict[@"sdkver"] = @"1.5";
    dict[@"command"] = @"1010";
    NSData *fullImageData = [message fullImageData];
    NSData *thumbImageData = [message thumbImageDataWithSize:CGSizeMake(100, 100)];
    if (YSCShareMessageTypeAudio == message.shareMessageType) {
        dict[@"objectType"] = @"3";
        dict[@"title"] = message.title;
        dict[@"description"] = message.content;
        dict[@"mediaUrl"] = message.link;
        dict[@"mediaDataUrl"] = message.mediaDataUrl;
        if ( ! thumbImageData) {
            *error = [self _createError:@"缩略图不能为空"];
            return @"";
        }
        dict[@"thumbData"] = thumbImageData;
    } else if (YSCShareMessageTypeVideo == message.shareMessageType) {
        dict[@"objectType"] = @"4";
        dict[@"title"] = message.title;
        dict[@"description"] = message.content;
        dict[@"mediaUrl"] = message.link;
        if ( ! thumbImageData) {
            *error = [self _createError:@"缩略图不能为空"];
            return @"";
        }
        dict[@"thumbData"] = thumbImageData;
        
    } else if (YSCShareMessageTypeApp == message.shareMessageType) {
        dict[@"objectType"] = @"7";
        dict[@"title"] = message.title;
        dict[@"description"] = message.content;
        dict[@"mediaUrl"] = message.link;
        if (message.extraInfo.length > 0) {
            dict[@"extInfo"] = message.extraInfo;
        }
        if ( ! fullImageData) {
            *error = [self _createError:@"APP图片不能为空"];
            return @"";
        }
        dict[@"fileData"] = fullImageData;
        if ( ! thumbImageData) {
            *error = [self _createError:@"缩略图不能为空"];
            return @"";
        }
        dict[@"thumbData"] = thumbImageData;
    } else if (YSCShareMessageTypeFile == message.shareMessageType) {
        dict[@"objectType"] = @"6";
        dict[@"title"] = message.title;
        dict[@"description"] = message.content;
        dict[@"fileExt"] = message.fileExtention;
        if ( ! message.fileData) {
            *error = [self _createError:@"文件不能为空"];
            return @"";
        }
        dict[@"fileData"] = message.fileData;
        if ( ! thumbImageData) {
            *error = [self _createError:@"缩略图不能为空"];
            return @"";
        }
        dict[@"thumbData"] = thumbImageData;
    } else {
        // 3. 自动检测需要组装的数据
        if ( ! message.fullImage && message.link.length == 0 && ! message.fileData &&
            message.title.length > 0) {// 文本
            dict[@"command"] = @"1020";
            dict[@"title"] = message.title;
        } else if (message.link.length == 0 && fullImageData) { // 图片
            dict[@"objectType"] = @"2";
            dict[@"title"] = message.title;
            dict[@"fileData"] = fullImageData;
            if (thumbImageData) {
                dict[@"thumbData"] = thumbImageData;
            }
        } else if (message.link.length > 0 && message.title.length > 0 && fullImageData) { // 链接
            dict[@"objectType"] = @"5";
            dict[@"title"] = message.title;
            dict[@"description"] = message.content;
            dict[@"mediaUrl"] = message.link;
            if (thumbImageData) {
                dict[@"thumbData"] = thumbImageData;
            }
        } else if (message.link.length == 0 && message.fileData) { // 文件
            dict[@"objectType"] = @"8";
            dict[@"fileData"] = message.fileData;
            if (thumbImageData) {
                dict[@"thumbData"] = thumbImageData;
            }
        }
    }
    
    // 4. 将组装好的数据写入剪贴板
    *error = [self setValue:@{appKey : dict} forPasteboardType:@"content" encoding:YSCSharePasteboardEncodingTypeListSerialization];
    if ( ! *error) {
        return [NSString stringWithFormat:@"weixin://app/%@/sendreq/?", appKey];
    }
    return @"";
}
+ (void)_handleWeiXinOpenURL:(NSURL *)url {
    NSString *appKey = appKeys[@(YSCSharePlatformWeiXin)];
    NSObject *completionResult = nil;
    NSError *error = nil;
    if ([self _isEmpty:appKey]) {
        error = [self _createError:@"没有设置微信的AppId"];
        return ;
    } else {
        NSDictionary *pasteboardDict = [self getValueByKey:@"content" encoding:YSCSharePasteboardEncodingTypeListSerialization][appKey];
        NSDictionary *parseUrlDict = [YSCGeneral getParamsInNSURL:url];
        NSInteger code = parseUrlDict[@"ret"] ? [parseUrlDict[@"ret"] integerValue] : -1;
        if ([url.absoluteString rangeOfString:@"://oauth"].location != NSNotFound) { // login success
            completionResult = parseUrlDict;
        } else if ([url.absoluteString rangeOfString:@"://pay/"].location != NSNotFound) { // pay result
            completionResult = parseUrlDict;
            if (code == 0) {
                // pay success
            } else { // pay failed
                error = [self _createErrorWithCode:code userInfo:pasteboardDict];
            }
        } else {
            code = [pasteboardDict[@"result"] integerValue];
            NSString *state = [NSString stringWithFormat:@"%@", pasteboardDict[@"state"]];
            if ([@"Weixinauth" isEqualToString:state]) {
                if (code != 0) { // login failed
                    error = [self _createErrorWithCode:code userInfo:pasteboardDict];
                } else { // login success
                    completionResult = pasteboardDict;
                }
            } else if (code == 0) { // share success
                completionResult = pasteboardDict;
            } else { // share failed
                error = [self _createErrorWithCode:code userInfo:pasteboardDict];
            }
        }
    }
    
    // 回传结果
    if (shareCompletion) {
        shareCompletion(completionResult, error);
    }
}

#pragma mark - 处理QQ数据
+ (NSString *)_handleMessageToQQ:(YSCShareMessage *)message type:(YSCShareType)type error:(out NSError **)error {
    // 0. 检查appid是否设置
    NSString *appKey = appKeys[@(YSCSharePlatformQQ)];
    if ([self _isEmpty:appKey]) {
        *error = [self _createError:@"没有设置QQ的AppId"];
        return @"";
    }
    if ( ! [self isInstalled:YSCSharePlatformQQ]) {
        *error = [self _createError:@"没有安装QQ"];
        return @"";
    }
    
    // 1. TODO: 进一步检查info.plist中设置的合法性！
    NSString *callbackName = [NSString stringWithFormat:@"QQ%08llx",[appKey longLongValue]];
    
    // 2. 根据message的shareMessageType属性组装对应的参数
    NSString *bundleName = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] infoDictionary][@"CFBundleName"]];
    NSData *fullImageData = [message fullImageData];
    NSData *thumbImageData = [message thumbImageDataWithSize:CGSizeMake(36, 36)];
    
    NSMutableString *ret = [[NSMutableString alloc] initWithString:@"mqqapi://share/to_fri?thirdAppDisplayName="];
    [ret appendString:bundleName.ysc_Base64EncryptString];
    [ret appendString:@"&version=1&cflag="];
    if (type == YSCShareTypeQQFriends) {
        [ret appendFormat:@"%d", 0x00];
    } else if (type == YSCShareTypeQQZone) {
        [ret appendFormat:@"%d", 0x01];
    } else if (type == YSCShareTypeQQFavorite) {
        [ret appendFormat:@"%d", 0x08];
    } else if (type == YSCShareTypeQQDataline) {
        [ret appendFormat:@"%d", 0x10];
    } else {
        *error = [self _createError:@"share type is undefined"];
        return @"";
    }
    [ret appendString:@"&callback_type=scheme&generalpastboard=1"];
    [ret appendFormat:@"&callback_name=%@", callbackName];
    [ret appendString:@"&src_type=app&shareType=0&file_type="];
    if (message.link.length == 0 && ! fullImageData &&
        message.title.length > 0) { // 文本
        [ret appendFormat:@"text&file_data=%@", message.titleBase64];
    } else if (message.link.length == 0 &&
               message.title.length > 0 && fullImageData && message.content.length > 0 ) { // 图片
        [ret appendFormat:@"img&title=%@", message.titleBase64];
        [ret appendFormat:@"&objectlocation=pasteboard&description=%@", message.contentBase64];
        // 图片存入剪贴板
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"file_data" : fullImageData}];
        if (thumbImageData) {
            dict[@"previewimagedata"] = thumbImageData;
        }
        [self setValue:dict forPasteboardType:@"com.tencent.mqq.api.apiLargeData" encoding:YSCSharePasteboardEncodingTypeKeyedArchiver];
    } else if (message.title.length > 0 && message.content.length > 0 && fullImageData && message.link.length > 0) {
        //新闻／多媒体分享（图片加链接）发送新闻消息 预览图像数据，最大1M字节 URL地址,必填，最长512个字符 via QQApiInterfaceObject.h
        NSString *fileType = @"news";
        if (YSCShareMessageTypeAudio == message.shareMessageType) {
            fileType = @"audio";
        } else if (YSCShareMessageTypeVideo == message.shareMessageType) {
            //fileType = @"video"; // QQ没有video类型。客户端会自动判断
        }
        [ret appendFormat:@"%@&title=%@&url=%@&description=%@&objectlocation=pasteboard",
         fileType, message.titleBase64, message.linkBase64, message.contentBase64];
        // 图片存入剪贴板
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"file_data" : fullImageData}];
        if (thumbImageData) {
            dict[@"previewimagedata"] = thumbImageData;
        }
        [self setValue:dict forPasteboardType:@"com.tencent.mqq.api.apiLargeData" encoding:YSCSharePasteboardEncodingTypeKeyedArchiver];
    } else {
        *error = [self _createError:@"分享的数据不合法"];
    }
    return ret;
}
+ (void)_handleQQOpenURL:(NSURL *)url {
    NSString *appKey = appKeys[@(YSCSharePlatformQQ)];
    NSObject *completionResult = nil;
    NSError *error = nil;
    if ([self _isEmpty:appKey]) {
        error = [self _createError:@"没有设置QQ的AppId"];
        return ;
    } else {
        if ([url.scheme hasPrefix:@"QQ"]) { // 处理QQ分享结果
            NSDictionary *parseUrlDict = [YSCGeneral getParamsInNSURL:url];
            if (parseUrlDict[@"error_description"]) {
                NSString *errorDesc = [NSString stringWithFormat:@"%@", parseUrlDict[@"error_description"]];
                [parseUrlDict setValue:errorDesc.ysc_Base64DecryptString forKey:@"error_description"];
            }
            NSInteger code = parseUrlDict[@"error"] ? [parseUrlDict[@"error"] integerValue] : -1;
            if (code != 0) {
                error = [self _createErrorWithCode:code userInfo:parseUrlDict];
            } else {
                completionResult = parseUrlDict;
            }
        } else if ([url.scheme hasPrefix:@"tencent"]) { // 处理QQ登录结果
            NSDictionary *pasteboardDict = [self getValueByKey:@"com.tencent.tencent" encoding:YSCSharePasteboardEncodingTypeListSerialization][appKey];
            NSInteger code = pasteboardDict[@"ret"] ? [pasteboardDict[@"ret"] integerValue] : -1;
            if (code != 0) {
                error = [self _createErrorWithCode:code userInfo:pasteboardDict];
            } else {
                completionResult = pasteboardDict;
            }
        } else {
            error = [self _createError:@"无法处理返回结果"];
        }
    }
    
    // 回传结果
    if (shareCompletion) {
        shareCompletion(completionResult, error);
    }
}

#pragma mark - 处理新浪微博数据
+ (NSString *)_handleMessageToSinaWeibo:(YSCShareMessage *)message type:(YSCShareType)type error:(out NSError **)error {
    // 0. 检查appid是否设置
    NSString *appKey = appKeys[@(YSCSharePlatformSinaWeibo)];
    if ([self _isEmpty:appKey]) {
        *error = [self _createError:@"没有设置新浪微博的AppId"];
        return @"";
    }
    if ( ! [self isInstalled:YSCSharePlatformSinaWeibo]) {
        *error = [self _createError:@"没有安装新浪微博"];
        return @"";
    }
    
    // 1. TODO: 进一步检查info.plist中设置的合法性！
    
    // 2. 根据message的shareMessageType属性组装对应的参数
    NSString *bundleName = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] infoDictionary][@"CFBundleName"]];
    NSString *bundleIdentifier = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"]];
    NSData *fullImageData = [message fullImageData];
    NSData *thumbImageData = [message thumbImageDataWithSize:CGSizeMake(100, 100)];
    NSMutableDictionary *transferDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionary];
    if (type == YSCShareTypeSinaWeibo) {
        NSDictionary *dict;
        if (message.link.length == 0 && ! fullImageData &&
            message.title.length > 0) { // 文本
            dict = @{@"__class" : @"WBMessageObject",
                     @"text" : message.title};
        } else if (message.link.length == 0 && message.title.length > 0 && fullImageData) { // 图片
            dict = @{@"__class" : @"WBMessageObject",
                     @"imageObject" : @{@"imageData" : fullImageData},
                     @"text" : message.title};
            
        } else if (message.title.length > 0 && message.link.length > 0 && thumbImageData) { // 链接
            dict = @{@"__class" : @"WBMessageObject",
                     @"mediaObject":@{@"__class" : @"WBWebpageObject",
                                      @"objectID" : @"identifier1",
                                      @"description": message.content,
                                      @"thumbnailData" : thumbImageData,
                                      @"title": message.title,
                                      @"webpageUrl":message.link}
                     };
        }
        if (dict) {
            transferDict[@"__class"] = @"WBSendMessageToWeiboRequest";
            transferDict[@"message"] = dict;
        } else {
            *error = [self _createError:@"分享的数据不合法"];
            return @"";
        }
    } else {
        *error = [self _createError:@"share type is undefined"];
        return @"";
    }
    NSString *requestId = [[NSUUID UUID] UUIDString];
    transferDict[@"requestID"] = requestId;
    NSData *transferData = [NSKeyedArchiver archivedDataWithRootObject:transferDict];
    NSData *userInfoData = [NSKeyedArchiver archivedDataWithRootObject:userInfoDict];
    NSData *appData = [NSKeyedArchiver archivedDataWithRootObject:@{@"appKey" : appKey, @"bundleID" : bundleIdentifier, @"name" : bundleName}];
    [UIPasteboard generalPasteboard].items = @[@{@"transferObject" : transferData}, @{@"userInfo" : userInfoData}, @{@"app" : appData}];
    return [NSString stringWithFormat:@"weibosdk://request?id=%@&sdkversion=003013000", requestId];
}
+ (void)_handleSinaWeiboOpenURL:(NSURL *)url {
    NSString *appKey = appKeys[@(YSCSharePlatformSinaWeibo)];
    NSObject *completionResult = nil;
    NSError *error = nil;
    if ([self _isEmpty:appKey]) {
        error = [self _createError:@"没有设置新浪微博的AppId"];
        return ;
    } else {
        NSArray *items = [UIPasteboard generalPasteboard].items;
        NSMutableDictionary *pasteboardDict = [NSMutableDictionary dictionaryWithCapacity:items.count];
        for (NSDictionary *item in items) {
            for (NSString *k in item) {
                pasteboardDict[k] = [k isEqualToString:@"transferObject"] ? [NSKeyedUnarchiver unarchiveObjectWithData:item[k]] : item[k];
            }
        }
        NSDictionary *transferDict = pasteboardDict[@"transferObject"];
        NSInteger code = [transferDict[@"statusCode"] intValue];
        if (code != 0) {
            error = [self _createErrorWithCode:code userInfo:transferDict];
        } else {
            completionResult = transferDict;
        }
    }
    
    // 回传结果
    if (shareCompletion) {
        shareCompletion(completionResult, error);
    }
}
@end
