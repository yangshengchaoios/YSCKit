//
//  String+Extension.swift
//  QianJiWang
//
//  Created by Pisen on 2016/10/18.
//  Copyright © 2016年 nijiang. All rights reserved.
//

import UIKit
import Foundation


func emptyPorcess(_ str: String?) -> String {
    return (nil == str) ? "" : str!
}

//==============================================================================
//
//  基本功能
//
//==============================================================================
extension String {
    subscript (r: Range<Int>) -> String {
        get {
            return substring(with: r)
        }
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
    
    func substringOfBytesUtf8(to length: Int) -> String {
        let lengthBytes = lengthOfBytes(using: .utf8)
        if length <= 0 || lengthBytes <= length {
            return self
        }
        if lengthBytes <= characters.count {
            return substring(to: length)
        }
        var lengthN = 0
        var count = 0
        for char in characters {
            let str = String(char)
            let length_ = str.lengthOfBytes(using: .utf8)
            if length_ + lengthN > length {
                break
            }
            lengthN += length_
            count += 1
        }
        return substring(to: count)
    }
    
    func trimString() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func sizeRect(size: CGSize,font: UIFont) -> CGSize {
        let str = self as NSString
        let size = str.boundingRect(with: size,options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin),attributes: [NSFontAttributeName:font], context: nil).size
        return size
    }
    
    func size(_ maxSize: CGSize, _ font: UIFont, _ lineMargin: CGFloat) -> CGSize {
        let options: NSStringDrawingOptions = NSStringDrawingOptions.usesLineFragmentOrigin
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineMargin // 行间距
        var attributes = [String : Any]()
        attributes[NSFontAttributeName] = font
        attributes[NSParagraphStyleAttributeName] = paragraphStyle
        let str = self as NSString
        let textBounds = str.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
        return textBounds.size
    }
    
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
    func toUInt64() -> UInt64? {
        return NumberFormatter().number(from: self)?.uint64Value
    }
    
    func scalarsCount() -> Int {
        return self.unicodeScalars.count
    }
    
    func charactersCount() -> Int {
        return self.characters.count
    }
    
    func parametersFromQueryString() -> Dictionary<String, String> {
        var parameters = Dictionary<String, String>()
        let scanner = Scanner(string: self)
        var key: NSString?
        var value: NSString?
        while !scanner.isAtEnd {
            key = nil
            scanner.scanUpTo("=", into: &key)
            scanner.scanString("=", into: nil)
            
            value = nil
            scanner.scanUpTo("&", into: &value)
            scanner.scanString("&", into: nil)
            
            if (key != nil && value != nil) {
                parameters.updateValue(value! as String, forKey: key! as String)
            }
        }
        return parameters
    }
    
    func getParamsInQuery() -> [String: AnyObject] {
        let scanner = Scanner(string: self)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "&?")
        if !contains("?") {
            scanner.scanUpTo("?", into: nil)
        }
        var params: [String: AnyObject] = [:]
        var tmpStr: NSString?
        while scanner.scanUpTo("&", into: &tmpStr) {
            if let components = tmpStr?.components(separatedBy: "="),
                components.count > 0,
                let key = components[0].removingPercentEncoding,
                let value = components[1].removingPercentEncoding {
                params[key] = value as AnyObject
            }
        }
        return params
    }
    
    func pinYin() -> String {
        let mutableString = NSMutableString(string: self)
        if CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false) {
            if CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false) {
                return String(mutableString)
            }
        }
        return ""
    }
}



//==============================================================================
//
//  合法性校验（正则相关）
//
//==============================================================================
extension String {
    // 返回匹配了正则表达式的内容数组
    func matchesArray(_ regex: String, options: NSRegularExpression.Options = .caseInsensitive) -> Array<String>? {
        var expression: NSRegularExpression?
        do {
            expression = try NSRegularExpression(pattern: regex, options: options)
        } catch _ {
            return nil
        }
        var array = Array<String>()
        expression!.enumerateMatches(in: self,
                                     options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                     range: NSMakeRange(0, self.characters.count)) { (result, flags, stop) in
                                        if result != nil {
                                            let start = self.index(startIndex, offsetBy: result!.range.location)
                                            let end = self.index(startIndex, offsetBy: result!.range.location + result!.range.length)
                                            let subString = self.substring(with: start..<end)
                                            array.append(subString)
                                        }
        }
        if array.isEmpty {
            return nil
        } else {
            return array
        }
    }
    
    // 判断字符串中是否包含regex表示的字符串
    func isContainRegex(_ regex: String) -> Bool {
        if self.matchesArray(regex) != nil {
            return true
        } else {
            return false
        }
    }
    
    // 将字符串中符合regex表达式的内容替换成toString
    func replaceRegex(_ regex: String, toString: String, options: NSRegularExpression.Options = .caseInsensitive) -> String {
        var expression: NSRegularExpression?
        do {
            expression = try NSRegularExpression(pattern: regex, options: options)
        } catch _ {
            return self
        }
        
        return expression!.stringByReplacingMatches(in: self,
                                                    options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                                    range: NSMakeRange(0, self.characters.count),
                                                    withTemplate: toString)
    }
    
    // 正则匹配判断
    func isMatchRegex(_ regex: String) -> Bool {
        let predicate =  NSPredicate(format: "SELF MATCHES %@" , regex)
        return predicate.evaluate(with: self)
    }
    
    // 是否是电话号码
    func isPhoneNum() -> Bool {
        //let regex = "^((13[0-9])|(15[^4,\\D]) |(17[0,0-9])|(18[0,0-9]))\\d{8}$"
        let regex = "^1\\d{10}$"
        return self.isMatchRegex(regex)
    }
    
    // 是否是url地址(http|ftp|https)开头的
    func isWebUrl() -> Bool {
        let regex = "((http|ftp|https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?"
        return self.isMatchRegex(regex)
    }
    
    // 是否是合法身份证号码
//    func isIDCardNumber() -> Bool {
//    
//    }
//    
//    // 是否是合法的军官证号码
//    func isSoldierCardNumber() -> Bool {
//    
//    }
    
    
}


//==============================================================================
//
//  加解密
//
//==============================================================================
extension String {
    var md5: String {
        let str = cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deallocate(capacity: digestLen)
        return String(format: hash as String)
    }
    
    func hmacSHA1(key: String) -> String {
        let str = cString(using: String.Encoding.utf8)
        let strLen = Int(lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_SHA1_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), keyStr!, keyLen, str!, strLen, result)
        let encryptData = NSData(bytes: result, length: digestLen)
        let encryptBase64Data = encryptData.base64EncodedData(options: .endLineWithLineFeed)
        return String(bytes: encryptBase64Data, encoding: .utf8)!
    }
    
    func decodedFromBase64() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }
    
    func encodedToBase64() -> String {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        } else {
            return ""
        }
        //return Data(self.utf8).base64EncodedString() //这种方法一定不为nil？
    }
    
    func urlEncode(_ base64Encoded: Bool = false) -> String {
        var sourceString = self
        if base64Encoded {
            sourceString = encodedToBase64()
        }
        let charactersToReplace = "=&?!@#$^%*+,:;'\"`<>()[]{}/\\| "//定义需要被替换的特殊字符
        let characterSet = NSCharacterSet(charactersIn: charactersToReplace).inverted
        if let str = sourceString.addingPercentEncoding(withAllowedCharacters: characterSet) {
            return str
        } else {
            return ""
        }
    }
    
    func urlDecode() -> String {
        if let str = self.replacingOccurrences(of: "+", with: " ").removingPercentEncoding {
            return str
        } else {
            return ""
        }
    }
}




