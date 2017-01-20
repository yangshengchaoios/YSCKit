//
//  YSCShare.swift
//  YSCKit
//
//  Created by 杨胜超 on 17/1/6.
//  Copyright © 2017年 Builder. All rights reserved.
//

import UIKit

/** suported apps */
public enum YSCSharePlatform {
    case unSupported
    case weixin
    case qq
    case sinaWeibo
    case alipay
}

/** define share types for each app */
public enum YSCShareType {
    case weixinSession      //微信会话（好友）
    case weixinTimeline     //微信朋友圈
    case weixinFavorite     //微信收藏
    case qqFriends          //QQ好友
    case qqZone             //QQ空间
    case qqFavorite         //QQ收藏
    case qqDataline         //QQ数据线
    case sinaTimeline       //新浪微博
}

/** define share message types */
public enum YSCShareMessageType {
    case autoDetect
    case news
    case audio
    case video
    case app
    case file
}

/** define encoding type of pasteboard */
public enum YSCSharePasteboardEncoding {
    case keyedArchiver
    case listSerialization
}

/** define message model */
public class YSCShareMessage: NSObject {
    var title: String = ""
    var content: String = ""
    var link: String = ""
    var fullImage: UIImage?
    var thumbImage: UIImage?
    var type: YSCShareMessageType = .autoDetect
    var extraInfo: String = ""
    var mediaDataUrl: String = ""
    var fileData: Data?
    var fileExtention: String = ""
    
    var fullImageData: Data? {
        if fullImage != nil {
            return UIImageJPEGRepresentation(fullImage!, 1)
        }
        return nil
    }
    
    func thumbImageData(size: CGSize) -> Data? {
        if thumbImage != nil {
            return UIImageJPEGRepresentation(thumbImage!, 1)
        } else if fullImage != nil {
            UIGraphicsBeginImageContext(size)
            fullImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if scaledImage != nil {
                return UIImageJPEGRepresentation(scaledImage!, 1)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

/** define two callbacks */
public typealias YSCShareSuccess = (_ result: AnyObject) -> ()
public typealias YSCShareFailure = (_ errorCode: Int, _ errorMessage: String) -> ()

public class YSCShare: NSObject {
    
    //MARK: - Private vars
    private static var registeredAppKeys = Dictionary<YSCSharePlatform, Dictionary<String, String>>()
    fileprivate static var successBlock: YSCShareSuccess?
    fileprivate static var failureBlock: YSCShareFailure?
    
    //MARK: - Public Methods
    public static func register(platform: YSCSharePlatform,
                                appKey: String,
                                appSecret: String? = nil,
                                redirectUrl: String? = nil) {
        var dict = ["AppKey": appKey]
        if let secret = appSecret {
            dict["AppSecret"] = secret
        }
        if let url = redirectUrl {
            dict["RedirectUrl"] = url
        }
        registeredAppKeys[platform] = dict
    }
    
    public static func getAppKey(platform: YSCSharePlatform) -> String? {
        if let dict = registeredAppKeys[platform] {
            return dict["AppKey"]
        }
        return nil
    }
    
    public static func getAppSecret(platform: YSCSharePlatform) -> String? {
        if let dict = registeredAppKeys[platform] {
            return dict["AppSecret"]
        }
        return nil
    }
    
    public static func getRedirectUrl(platform: YSCSharePlatform) -> String? {
        if let dict = registeredAppKeys[platform] {
            return dict["RedirectUrl"]
        }
        return nil
    }
    
    public static func isInstalled(platform: YSCSharePlatform) -> Bool {
        if platform == .weixin {
            return UIApplication.shared.canOpenURL(URL(string: "weixin://")!)
        } else if platform == .qq {
            return UIApplication.shared.canOpenURL(URL(string: "mqqapi://")!)
        } else if platform == .sinaWeibo {
            return UIApplication.shared.canOpenURL(URL(string: "weibosdk://request")!)
        } else if platform == .alipay {
            return UIApplication.shared.canOpenURL(URL(string: "alipay://")!)
        }
        return false
    }
    
    /// 第三方APP授权登录
    ///
    /// - Parameters:
    ///   - platform: 第三方平台类型
    ///   - success: 登录成功的回调
    ///   - failure: 登录失败的回调
    public static func authLogin(platform: YSCSharePlatform,
                                 success: YSCShareSuccess?,
                                 failure: YSCShareFailure?) {
        successBlock = success
        failureBlock = failure
        if checkPlatform(platform) {
            var url: String?
            if platform == .weixin {
                url = authByWeixin()
            } else if platform == .qq {
                url = authByQQ()
            } else if platform == .sinaWeibo {
                url = authBySinaWeibo()
            } else {
                callFailureBlock("The platform: \(platform) is unsupported!")
            }
            
            if url != nil {
                open(url!)
            }
        }
    }
    
    /// 分享数据
    ///
    /// - Parameters:
    ///   - message: 要分享的消息模型
    ///   - type: 分享方式
    ///   - success: 分享成功的回调
    ///   - failure: 分享失败的回调
    public static func share(message: YSCShareMessage,
                             type: YSCShareType,
                             success: YSCShareSuccess?,
                             failure: YSCShareFailure?) {
        successBlock = success
        failureBlock = failure
        let (platform_, isCheckPast) = checkShareType(type)
        if let platform = platform_, isCheckPast {
            var url: String?
            if platform == .weixin {
                url = shareByWeixin(message, type)
            } else if platform == .qq {
                url = shareByQQ(message, type)
            } else if platform == .sinaWeibo {
                url = shareBySinaWeibo(message, type)
            } else if platform == .alipay {
                url = shareByAlipay(message, type)
            } else {
                callFailureBlock("The platform: \(platform) is unsupported!")
            }
            
            if url != nil {
                open(url!)
            }
        }
    }
    
    /// 处理AppDelegate中application传入的URL
    ///
    /// - parameter openUrl: URL
    ///
    /// - returns: 能否处理URL
    public static func handle(openUrl: URL) -> Bool {
        guard let scheme = openUrl.scheme else {
            return false
        }
        let schemeLowercased = scheme.lowercased()
        if schemeLowercased.hasPrefix("wx") {
            handleWeixinOpenURL(openUrl)
            return true
        } else if schemeLowercased.hasPrefix("qq") || schemeLowercased.hasPrefix("tencent") {
            handleQQOpenURL(openUrl)
            return true
        } else if schemeLowercased.hasPrefix("wb") {
            handleSinaWeiboOpenURL(openUrl)
            return true
        } else if schemeLowercased.range(of: "//safepay/") != nil {
            handleAlipayOpenURL(openUrl)
            return true
        }
        return false
    }
    
    /// 将结构化的数据存入剪贴板
    ///
    /// - parameter value:    字典(value可以是任何Data类型的数据)
    /// - parameter key:      数据的唯一标识符
    /// - parameter encoding: 编码方式
    ///
    /// - returns: 存储是否成功
    public static func saveToPasteboard(value: Dictionary<String, AnyObject>, key: String, encoding: YSCSharePasteboardEncoding) -> Bool {
        var data: Data?
        if encoding == .keyedArchiver {
            data = NSKeyedArchiver.archivedData(withRootObject: value)
        } else if encoding == .listSerialization {
            data = try? PropertyListSerialization.data(fromPropertyList: value, format: .binary, options: 0)
        }
        if data != nil {
            UIPasteboard.general.setData(data!, forPasteboardType: key)
            return true
        } else {
            return false
        }
    }
    
    /// 从剪贴板中获取数据
    ///
    /// - parameter key:      数据的唯一标识符
    /// - parameter encoding: 编码方式
    ///
    /// - returns: 字典
    public static func getFromPasteboard(key: String, encoding: YSCSharePasteboardEncoding) -> Dictionary<String, AnyObject> {
        var dict = Dictionary<String, AnyObject>()
        if let data = UIPasteboard.general.data(forPasteboardType: key) {
            if encoding == .keyedArchiver {
                if let temp = NSKeyedUnarchiver.unarchiveObject(with: data) as? Dictionary<String, AnyObject> {
                    dict = temp
                }
            } else if encoding == .listSerialization {
                if let propertyList = (try? PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.ReadOptions(rawValue: UInt(0)), format: UnsafeMutablePointer<PropertyListSerialization.PropertyListFormat>.allocate(capacity: 0))) as? Dictionary<String, AnyObject> {
                    dict = propertyList
                }
            }
        }
        return dict
    }
    
    
    //MARK: - Private Methods
    fileprivate static func callFailureBlock(_ message: String, _ code: Int = -1) {
        if failureBlock != nil {
            failureBlock!(code, message)
        }
    }
    
    fileprivate static func checkPlatform(_ platform: YSCSharePlatform,
                                          _ checkAppKey: Bool = true,
                                          _ checkAppSecret: Bool = false,
                                          _ checkRedirectUrl: Bool = false) -> Bool {
        if !isInstalled(platform: platform) {
            callFailureBlock("The platform: \(platform) is not installed!")
            return false
        }
        
        if checkAppKey {
            if getAppKey(platform: platform) == nil {
                callFailureBlock("The appKey of platform: \(platform) is not registered!")
                return false
            }
        }
        
        if checkAppSecret {
            if getAppSecret(platform: platform) == nil {
                callFailureBlock("The appSecret of platform: \(platform) is not registered!")
                return false
            }
        }
        
        if checkRedirectUrl {
            if getRedirectUrl(platform: platform) == nil {
                callFailureBlock("The redirectUrl of platform: \(platform) is not registered!")
                return false
            }
        }
        
        return true
    }
    
    fileprivate static func checkShareType(_ type: YSCShareType) -> (YSCSharePlatform?, Bool) {
        if type == .weixinSession || type == .weixinTimeline || type == .weixinFavorite {
            return (.weixin, checkPlatform(.weixin))
        } else if type == .qqFriends || type == .qqZone || type == .qqFavorite || type == .qqDataline {
            return (.qq, checkPlatform(.qq))
        } else if type == .sinaTimeline {
            return (.sinaWeibo, checkPlatform(.sinaWeibo))
        } else {
            callFailureBlock("The share type: \(type) is unsupported!")
            return (nil, false)
        }
    }
    
    fileprivate static func open(_ url: String) {
        if url.isEmpty {
            return
        }
        if let openURL = URL(string: url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(openURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(openURL)
            }
        } else {
            callFailureBlock("The url is invalid!")
        }
    }
    
    fileprivate static func getBundleName() -> String {
        if let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return bundleName
        } else {
            return ""
        }
    }
    
    fileprivate static func getBundleIdentifier() -> String {
        if let bundleIdentifier = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String {
            return bundleIdentifier
        } else {
            return ""
        }
    }
    
    fileprivate static func getCodeFrom(_ object: AnyObject?) -> Int? {
        if object == nil {
            return nil
        }
        
        if let code = (object as? NSNumber)?.intValue {
            return code
        } else if let temp = object as? String, let code = Int(temp) {
            return code
        }
        
        return nil
    }
}

//处理微信分享、支付及回调
extension YSCShare {
    //MARK: - Public Methods
    
    /// 调用微信APP进行支付
    ///
    /// - Parameters:
    ///   - appId: 应用id（服务器返回或者本地获取的appKey）
    ///   - partnerId: 商家id（服务器返回）
    ///   - prepayId: 预支付id（服务器返回）
    ///   - package: 固定值“Sign%%3DWXPay”（服务器返回）
    ///   - nonceStr: 当前请求的唯一编号（服务器返回）
    ///   - timeStamp: 当前服务器时间戳（服务器返回）
    ///   - sign: 传入参数的签名（服务器返回）
    ///   - success: 支付成功的回调
    ///   - failure: 支付失败的回调
    public static func payByWeixin(appId: String,
                                   partnerId: String,
                                   prepayId: String,
                                   package: String,
                                   nonceStr: String,
                                   timeStamp: String,
                                   sign: String,
                                   success: YSCShareSuccess?,
                                   failure: YSCShareFailure?) {
        successBlock = success
        failureBlock = failure
        if !checkPlatform(.weixin) {
            return
        }
        
        //兼容appId为空的情况
        var newAppId = appId
        if newAppId.isEmpty {
            newAppId = getAppKey(platform: .weixin)!
        }
        
        //组装打开微信客户端要传入的url
        var url = "weixin://app"
        url.append("/\(newAppId)/pay/?signType=SHA1")
        url.append("&partnerId=\(partnerId)")
        url.append("&prepayId=\(prepayId)")
        url.append("&package=\(package)")
        url.append("&nonceStr=\(nonceStr)")
        url.append("&timeStamp=\(timeStamp)")
        url.append("&sign=\(sign)")
        
        //打开微信客户端
        open(url)
    }
    
    //MARK: - Private Methods
    fileprivate static func authByWeixin() -> String? {
        let appKey = getAppKey(platform: .weixin)!
        return "weixin://app/\(appKey)/auth/?scope=snsapi_userinfo&state=Weixinauth"
    }
    fileprivate static func shareByWeixin(_ message: YSCShareMessage, _ type: YSCShareType) -> String? {
        var dict = Dictionary<String, AnyObject>()
        dict = ["result": "1" as AnyObject,
                "returnFromApp": "0" as AnyObject,
                "sdkver": "1.5" as AnyObject,
                "command": "1010" as AnyObject]
        if type == .weixinSession {
            dict["scene"] = "0" as AnyObject
        } else if type == .weixinTimeline {
            dict["scene"] = "1" as AnyObject
        } else if type == .weixinFavorite {
            dict["scene"] = "2" as AnyObject
        } else {
            callFailureBlock("The share type: \(type) is unsupported!")
            return nil
        }
        
        let fullImageData = message.fullImageData
        let thumbImageData = message.thumbImageData(size: CGSize(width: 100, height: 100))
        if message.type == .audio {
            dict["objectType"] = "3" as AnyObject
            dict["title"] = message.title as AnyObject
            dict["description"] = message.content as AnyObject
            dict["mediaUrl"] = message.link as AnyObject
            dict["mediaDataUrl"] = message.mediaDataUrl as AnyObject
            if thumbImageData == nil {
                callFailureBlock("The thumb image is empty!")
                return nil
            }
            dict["thumbData"] = thumbImageData as AnyObject
        } else if message.type == .video {
            dict["objectType"] = "4" as AnyObject
            dict["title"] = message.title as AnyObject
            dict["description"] = message.content as AnyObject
            dict["mediaUrl"] = message.link as AnyObject
            if thumbImageData == nil {
                callFailureBlock("The thumb image is empty!")
                return nil
            }
            dict["thumbData"] = thumbImageData as AnyObject
        } else if message.type == .app {
            dict["objectType"] = "7" as AnyObject
            dict["title"] = message.title as AnyObject
            dict["description"] = message.content as AnyObject
            dict["mediaUrl"] = message.link as AnyObject
            if !message.extraInfo.isEmpty {
                dict["extInfo"] = message.extraInfo as AnyObject
            }
            if fullImageData == nil {
                callFailureBlock("The app icon is empty!")
                return nil;
            }
            dict["fileData"] = fullImageData as AnyObject
            if thumbImageData == nil {
                callFailureBlock("The thumb image is empty!")
                return nil
            }
            dict["thumbData"] = thumbImageData as AnyObject
        } else if message.type == .file {
            dict["objectType"] = "6" as AnyObject
            dict["title"] = message.title as AnyObject
            dict["description"] = message.content as AnyObject
            dict["fileExt"] = message.fileExtention as AnyObject
            if message.fileData == nil {
                callFailureBlock("The file data is empty!")
                return nil
            }
            dict["fileData"] = message.fileData as AnyObject
            if thumbImageData == nil {
                callFailureBlock("The thumb image is empty!")
                return nil
            }
            dict["thumbData"] = thumbImageData as AnyObject
        } else {
            if message.fullImage == nil &&
                message.link.isEmpty &&
                message.fileData == nil &&
                !message.title.isEmpty { //文本
                dict["command"] = "1020" as AnyObject
                dict["title"] = message.title as AnyObject
            } else if message.link.isEmpty &&
                fullImageData != nil { //图片
                dict["objectType"] = "2" as AnyObject
                dict["title"] = message.title as AnyObject
                dict["fileData"] = fullImageData as AnyObject
                if thumbImageData != nil {
                    dict["thumbData"] = thumbImageData as AnyObject
                }
            } else if !message.link.isEmpty &&
                !message.title.isEmpty &&
                fullImageData != nil { //链接
                dict["objectType"] = "5" as AnyObject
                dict["title"] = message.title as AnyObject
                dict["description"] = message.content as AnyObject
                dict["mediaUrl"] = message.link as AnyObject
                if thumbImageData != nil {
                    dict["thumbData"] = thumbImageData as AnyObject
                }
            } else if message.link.isEmpty &&
                message.fileData != nil { //文件
                dict["objectType"] = "8" as AnyObject
                dict["fileData"] = message.fileData as AnyObject
                if thumbImageData != nil {
                    dict["thumbData"] = thumbImageData as AnyObject
                }
            } else {
                callFailureBlock("The share message is invalid!")
                return nil
            }
        }
        
        if saveToPasteboard(value: dict, key: "content", encoding: .listSerialization) {
            return "weixin://app/\(getAppKey(platform: .weixin)!)/sendreq/?"
        } else {
            return nil
        }
    }
    fileprivate static func handleWeixinOpenURL(_ url: URL) {
        var code = -1
        var errorMessage = ""
        var result: AnyObject = "" as AnyObject
        let parseUrlDict = (url.query ?? "").parametersFromQueryString()
        if let ret = parseUrlDict["ret"], let ret_ = Int(ret) {
            code = ret_
        }
        if url.absoluteString.range(of: "://oauth") != nil { //login success
            result = parseUrlDict as AnyObject
        } else if url.absoluteString.range(of: "://pay/") != nil { //pay result
            if code == 0 {
                result = parseUrlDict as AnyObject
            } else {
                errorMessage = "WeixinPay failed!"
            }
        } else { //share result
            if let appKey = getAppKey(platform: .weixin),
                let pasteboardDict = getFromPasteboard(key: "content", encoding: .listSerialization)[appKey] as? Dictionary<String, AnyObject> {
                if let code_ = getCodeFrom(pasteboardDict["result"]) {
                    code = code_
                }
                if code == 0 {
                    result = pasteboardDict as AnyObject
                } else {
                    if let state_ = pasteboardDict["state"] as? String {
                        errorMessage = state_
                    }
                }
            }
        }
        
        //call back
        if code == 0 {
            if successBlock != nil {
                successBlock!(result)
            }
        } else {
            callFailureBlock(errorMessage, code)
        }
    }
}

//处理QQ分享、支付及回调
extension YSCShare {
    //MARK: - Public Methods
    
    /// 与指定QQ号（非好友也行）聊天
    ///
    /// - Parameter number: 个人qq号
    public static func chatWithQQ(number: String) {
        var url = "mqqwpa://im/chat?src_type=app&version=1&chat_type=wpa&callback_type=scheme"
        url.append("&uin=\(number)")
        url.append("&thirdAppDisplayName=\(getBundleName().urlEncode(true))")
        url.append("&callback_name=\(getCallbackName())")
        
        open(url)
    }
    
    /// 在QQ群里发言（必须是已加入的群才行）
    ///
    /// - Parameter number: qq群号
    public static func chatInQQGroup(number: String) {
        var url = "mqqwpa://im/chat?src_type=app&version=1&chat_type=group&callback_type=scheme"
        url.append("&uin=\(number)")
        url.append("&thirdAppDisplayName=\(getBundleName().urlEncode(true))")
        url.append("&callback_name=\(getCallbackName())")
        
        open(url)
    }
    
    //MARK: - Private Methods
    fileprivate static func authByQQ() -> String? {
        let appKey = getAppKey(platform: .qq)!
        let dict = ["app_id": appKey,
                    "app_name": getBundleName(),
                    "bundleid": getBundleIdentifier(),//必须和后台一致，可以为空
            "client_id": appKey,
            "response_type": "token",
            "scope": "get_user_info",
            "sdkp": "i",
            "sdkv": "2.9",
            "status_machine": UIDevice.current.model,
            "status_os": UIDevice.current.systemVersion,
            "status_version" : UIDevice.current.systemVersion]
        let contentKey = "com.tencent.tencent\(appKey)"
        if saveToPasteboard(value: dict as Dictionary<String, AnyObject>,
                            key: contentKey,
                            encoding: .keyedArchiver) {
            return "mqqOpensdkSSoLogin://SSoLogin/tencent\(appKey)/\(contentKey)?generalpastboard=1"
        } else {
            callFailureBlock("Save data to pasteboard failed!")
            return nil
        }
    }
    fileprivate static func shareByQQ(_ message: YSCShareMessage, _ type: YSCShareType) -> String? {
        var url = "mqqapi://share/to_fri?version=1&callback_type=scheme&generalpastboard=1&src_type=app&shareType=0"
        let fullImageData = message.fullImageData
        let thumbImageData = message.thumbImageData(size: CGSize(width: 36, height: 36))
        
        url.append("&thirdAppDisplayName=\(getBundleName().urlEncode(true))")
        url.append("&callback_name=\(getCallbackName())")
        
        //组装cflag
        if type == .qqFriends {
            url.append("&cflag=\(String(format: "%d", 0x00))")
        } else if type == .qqZone {
            url.append("&cflag=\(String(format: "%d", 0x01))")
        } else if type == .qqFavorite {
            url.append("&cflag=\(String(format: "%d", 0x08))")
        } else if type == .qqDataline {
            url.append("&cflag=\(String(format: "%d", 0x10))")
        } else {
            callFailureBlock("The share type: \(type) is unsupported!")
            return nil
        }
        
        //图片存入剪贴板
        func saveFullImageData() {
            if fullImageData != nil {
                url.append("&objectlocation=pasteboard")
                var dict = Dictionary<String, AnyObject>()
                dict["file_data"] = fullImageData as AnyObject
                if thumbImageData != nil {
                    dict["previewimagedata"] = thumbImageData as AnyObject
                }
                _ = saveToPasteboard(value: dict, key: "com.tencent.mqq.api.apiLargeData", encoding: .keyedArchiver)
            }
        }
        
        //组装file_type
        if message.link.isEmpty && fullImageData == nil &&
            !message.title.isEmpty { //文本
            url.append("&file_type=text")
            url.append("&title=\(message.title.urlEncode(true))")
        } else if message.link.isEmpty &&
            !message.title.isEmpty && fullImageData != nil && !message.content.isEmpty { //图片
            url.append("&file_type=img")
            url.append("&title=\(message.title.urlEncode(true))")
            url.append("&description=\(message.content.urlEncode(true))")
            saveFullImageData()
        } else if !message.title.isEmpty && !message.content.isEmpty && !message.link.isEmpty && fullImageData != nil {
            if message.type == .audio {
                url.append("&file_type=audio")
            } else {
                url.append("&file_type=news")
            }
            url.append("&title=\(message.title.urlEncode(true))")
            url.append("&url=\(message.link.urlEncode(true))")
            url.append("&description=\(message.content.urlEncode(true))")
            saveFullImageData()
        } else {
            callFailureBlock("The share message is invalid!")
            return nil
        }
        return url
    }
    fileprivate static func handleQQOpenURL(_ url: URL) {
        var code = -1
        var errorMessage = ""
        var result: AnyObject = "" as AnyObject
        
        let schemeLowercased = url.scheme!.lowercased()
        if schemeLowercased.hasPrefix("qq") { //处理qq分享结果
            var parseUrlDict = (url.query ?? "").parametersFromQueryString()
            if let error = parseUrlDict["error"], let error_ = Int(error) {
                code = error_
            }
            //将错误描述从base64解码成字符串
            if let desc = parseUrlDict["error_description"]?.decodedFromBase64() {
                parseUrlDict["error_description"] = desc
                errorMessage = desc
            }
            if code == 0 {
                result = parseUrlDict as AnyObject
            }
        } else if schemeLowercased.hasPrefix("tencent") { //处理qq登录结果
            if let appKey = getAppKey(platform: .qq) {
                let contentKey = "com.tencent.tencent\(appKey)"
                let pasteboardDict = getFromPasteboard(key: contentKey, encoding: .keyedArchiver)
                if let code_ = getCodeFrom(pasteboardDict["ret"]) {
                    code = code_
                }
                if code == 0 {
                    result = pasteboardDict as AnyObject
                }
            }
        }
        
        //call back
        if code == 0 {
            /**
             *  登录成功后返回内容：
             *
             *  "access_token" = 47BD5C764ABA05638E241C17219C8208;
             *  encrytoken = 14bf88d6f02358dd30cf7f4827bc5ecd;
             *  "expires_in" = 7776000;
             *  msg = "";
             *  openid = 99205F3BDBDC158E05B822FAF00B1EDA;
             *  "pay_token" = 5D5FA79E9978191B27F757F80A671FC0;
             *  pf = "openmobile_ios";
             *  pfkey = 4ea623ac2795cc8192e412241bd91ec8;
             *  ret = 0;
             *  "user_cancelled" = NO;
             */
            if successBlock != nil {
                successBlock!(result)
            }
        } else {
            callFailureBlock(errorMessage, code)
        }
    }
    private static func getCallbackName() -> String {
        if let appKey = getAppKey(platform: .qq), let appKeyLong = Int(appKey) {
            return String(format: "QQ%08llx", appKeyLong)
        } else {
            return ""
        }
    }
}

//处理新浪微博分享、支付及回调
extension YSCShare {
    //MARK: - Private Methods
    fileprivate static func authBySinaWeibo() -> String? {
        guard let redirectUrl = getRedirectUrl(platform: .sinaWeibo) else {
            callFailureBlock("The redirectUrl of platform: \(YSCSharePlatform.sinaWeibo) is not registered!")
            return nil
        }
        
        let requestId = NSUUID().uuidString
        let transferData = NSKeyedArchiver.archivedData(withRootObject: ["__class": "WBAuthorizeRequest",
                                                                         "scope": "all",
                                                                         "requestID": requestId,
                                                                         "redirectURI": redirectUrl])
        let userInfoData = NSKeyedArchiver.archivedData(withRootObject: ["mykey": "user's id of my app",
                                                                         "SSO_From": "SendMessageToWeiboViewController"])
        let appData = NSKeyedArchiver.archivedData(withRootObject: ["appKey" : getAppKey(platform: .sinaWeibo)!,
                                                                    "bundleID" : getBundleIdentifier(),
                                                                    "name" : getBundleName()])
        UIPasteboard.general.items = [["transferObject" : transferData], ["userInfo": userInfoData], ["app": appData]]
        return "weibosdk://request?id=\(requestId)&sdkversion=003013000"
    }
    fileprivate static func shareBySinaWeibo(_ message: YSCShareMessage, _ type: YSCShareType) -> String? {
        let fullImageData = message.fullImageData
        let thumbImageData = message.thumbImageData(size: CGSize(width: 36, height: 36))
        if type == .sinaTimeline {
            var dict = Dictionary<String, AnyObject>()
            dict["__class"] = "WBMessageObject" as AnyObject
            if message.link.isEmpty && fullImageData == nil &&
                !message.title.isEmpty { //文本
                dict["text"] = message.title as AnyObject
            } else if message.link.isEmpty &&
                fullImageData != nil && !message.title.isEmpty { //图片
                dict["text"] = message.title as AnyObject
                dict["imageObject"] = ["imageData": fullImageData!] as AnyObject
            } else if !message.title.isEmpty && thumbImageData != nil && !message.title.isEmpty { //链接
                dict["mediaObject"] = ["__class": "WBWebpageObject",
                                       "objectID" : "identifier1",
                                       "description": message.content,
                                       "thumbnailData" : thumbImageData!,
                                       "title": message.title,
                                       "webpageUrl":message.link] as AnyObject
            } else {
                callFailureBlock("The share message is invalid!")
                return nil
            }
            
            //组装数据
            let requestId = NSUUID().uuidString
            let transferData = NSKeyedArchiver.archivedData(withRootObject: ["__class": "WBSendMessageToWeiboRequest" as AnyObject,
                                                                             "message": dict as AnyObject,
                                                                             "requestID": requestId as AnyObject])
            let userInfoData = NSKeyedArchiver.archivedData(withRootObject: [:])
            let appData = NSKeyedArchiver.archivedData(withRootObject: ["appKey" : getAppKey(platform: .sinaWeibo)!,
                                                                        "bundleID" : getBundleIdentifier(),
                                                                        "name" : getBundleName()])
            UIPasteboard.general.items = [["transferObject" : transferData], ["userInfo": userInfoData], ["app": appData]]
            
            //返回url
            return "weibosdk://request?id=\(requestId)&sdkversion=003013000"
        } else {
            callFailureBlock("The share type: \(type) is unsupported!")
            return nil
        }
    }
    fileprivate static func handleSinaWeiboOpenURL(_ url: URL) {
        var itemDict = Dictionary<String, Dictionary<String, AnyObject>>()
        for item in UIPasteboard.general.items {
            for (key, value) in item {
                if let data = value as? Data,
                    let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? Dictionary<String, AnyObject> {
                    itemDict[key] = dict
                }
            }
        }
        var code = -1
        if let transferObject = itemDict["transferObject"],
            let code_ = getCodeFrom(transferObject["statusCode"]) {
            code = code_
        }
        
        //call back
        if code == 0 {
            var userInfo = Dictionary<String, AnyObject>()
            if let dict = itemDict["userInfo"] {
                userInfo = dict
                /**
                 *  登录成功后返回内容：
                 *
                 *  "access_token" = "2.00ilhr4GtQyJaBcc3bff2d1b0iwHMF";
                 *  app = {
                 *         logo = "http://timg.sjs.sinajs.cn/miniblog2style/images/developer/default_50.gif";
                 *         name = "\U888a\U888a\U8fc8\U8ba8\U8888\U8e88\U8888";
                 *        };
                 *  "expires_in" = 148827;
                 *  "refresh_token" = "2.00ilhr4GtQyJaB08b85c1af4gFLfRC";
                 *  "remind_in" = 148827;
                 *  scope = "follow_app_official_microblog";
                 *  uid = 1234567890;
                 */
            }
            
            if successBlock != nil {
                successBlock!(userInfo as AnyObject)
            }
        } else {
            callFailureBlock("Failed!")
        }
    }
}

//处理阿里支付及回调
extension YSCShare {
    //MARK: - Public Methods
    
    
    /// 调用支付宝APP进行支付
    ///
    /// - Parameters:
    ///   - appId: 应用id（服务器返回或者本地获取的appKey）
    ///   - bizContent: 账单信息
    ///     如：{"timeout_express":"最晚付款时间，逾期将关闭交易(一般30m)","seller_id":"收款支付宝用户ID。 如果该值为空，则默认为商户签约账号对应的支付宝用户ID","product_code":"商家和支付宝签约的产品码","total_amount":"支付金额(元)","subject":"商品标题","body":"商品描述","out_trade_no":"订单号"}
    ///   - method: 支付接口名称，如：alipay.trade.app.pay
    ///   - signType: 签名类型，如：RSA or RSA2
    ///   - timestamp: 生成支付请求的时间，格式：yyyy-MM-dd HH:mm:ss
    ///   - version: 请求调用的接口版本，如：1.0
    ///   - sign: 参数校验码
    ///   - appScheme: 唤醒本APP的scheme url
    ///   - success: 支付成功的回调
    ///   - failure: 支付失败的回调
    public static func payByAlipay(appId: String,
                                   bizContent: String,
                                   method: String,
                                   signType: String,
                                   timestamp: String,
                                   version: String,
                                   sign: String,
                                   appScheme: String,
                                   success: YSCShareSuccess?,
                                   failure: YSCShareFailure?) {
        successBlock = success
        failureBlock = failure
        
        //兼容appId为空的情况
        var newAppId = appId
        if newAppId.isEmpty {
            newAppId = getAppKey(platform: .alipay)!
        }
        
        //组装必要的参数
        var dataString = "app_id=\(newAppId.urlEncode())"
        dataString.append("&biz_content=\(bizContent.urlEncode())")
        dataString.append("&charset=utf-8")
        dataString.append("&method=\(method.urlEncode())")
        dataString.append("&sign_type=\(signType.urlEncode())")
        dataString.append("&timestamp=\(timestamp.urlEncode())")
        dataString.append("&version=\(version.urlEncode())")
        dataString.append("&sign=\(sign.urlEncode())")

        //组装要传入支付宝APP的url
        let bizcontext = "{\"av\":\"1.0\",\"ty\":\"ios_lite\",\"appkey\":\"\(newAppId)\",\"sv\":\"h.a.3.2.1\",\"an\":\"\(getBundleIdentifier())\"}"
        dataString.append("&bizcontext=\(bizcontext)")
        let urlContent = "{\"fromAppUrlScheme\":\"\(appScheme)\", \"requestType\":\"SafePay\", \"dataString\":\"\(dataString)\"}"
        let url = "alipay://alipayclient/?\(urlContent.urlEncode())"
        
        open(url)
    }
    
    //MARK: - Private Methods
    fileprivate static func shareByAlipay(_ message: YSCShareMessage, _ type: YSCShareType) -> String? {
        //TODO:
        return nil
    }
    fileprivate static func handleAlipayOpenURL(_ url: URL) {
        var code = -1
        if let urlQueryData = url.query?.urlDecode().data(using: .utf8) {
            if let ret = (try? JSONSerialization.jsonObject(with: urlQueryData, options: .allowFragments)) as? Dictionary<String, AnyObject> {
                if let memo = ret["memo"] as? Dictionary<String, AnyObject>,
                    let code_ = getCodeFrom(memo["ResultStatus"]) {
                    code = code_
                }
                
                //call back
                if code == 9000 {
                    if successBlock != nil {
                        successBlock!(ret as AnyObject)
                    }
                } else {
                    callFailureBlock("Alipay failed!", code)
                }
            } else {
                callFailureBlock("The url.query json data is invalid!")
            }
        } else {
            callFailureBlock("The url is invalid!")
        }
    }
}

