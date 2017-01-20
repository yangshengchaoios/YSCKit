//
//  YSCTextField.swift
//  YSCKit
//
//  Created by 杨胜超 on 17/1/4.
//  Copyright © 2017年 Builder. All rights reserved.
//

import Foundation

public enum YSCTextType: Int {
    case custom = 0                 //自定义(Default)
    case phone = 1                  //电话号码(包括座机、手机号)
    case mobilePhone = 2            //手机号
    case identityCardNumber = 3     //身份证号
    case email = 4                  //email地址
    case url = 5                    //超链接
    case decimal = 6                //带小数点的数字
}

@IBDesignable
public class YSCTextField: UITextField {
    
    //MARK: - Public Properties
    //Content Control
    @IBInspectable public var minLength: Int = 0                //0 means no limit
    @IBInspectable public var maxLength: Int = 20               //-1 means no limit
    @IBInspectable public var customRegex: String = ""          //custom regex by user
    @IBInspectable public var chineseRegex: String = ""         //regex for chinese
    @IBInspectable public var punctuationRegex: String = ""     //regex for punctuation
    @IBInspectable public var emojiRegex: String = ""           //regex for emoji
    @IBInspectable public var allowsEmpty: Bool = false         //is allows empty text
    @IBInspectable public var allowsEmoji: Bool = false         //is allows input emojis
    @IBInspectable public var allowsChinese: Bool = false        //is allows input chinese
    @IBInspectable public var allowsPunctuation: Bool = false    //is allows input punctuations
    @IBInspectable public var allowsKeyboardDismiss: Bool = true//is allows dismiss when press done of keyboard
    @IBInspectable public var allowsLetter: Bool = true         //is allows input english letters
    @IBInspectable public var allowsNumber: Bool = true         //is allows input numbers
    public var textType: YSCTextType = .custom {                   //defined serval types
        didSet {
            if textType == .phone {
                maxLength = 15
            } else if textType == .mobilePhone {
                maxLength = 11
            } else if textType == .identityCardNumber {
                maxLength = 18
            }
        }
    }
    
    //UI Control
    //圆角弧度
    @IBInspectable public var cornerRadius: Float! {
        didSet {
            layer.cornerRadius = CGFloat(cornerRadius)
            layer.masksToBounds = cornerRadius > 0
        }
    }
    //边框颜色
    @IBInspectable public var borderColor: UIColor! {
        didSet {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 0.5
        }
    }
    //占位文本颜色
    @IBInspectable public var placeholderColor: UIColor! {
        didSet {
            if placeholder != nil {
                attributedPlaceholder = NSAttributedString(string: placeholder!,
                                                           attributes: [NSForegroundColorAttributeName: placeholderColor])
            }
        }
    }
    //文字水平方向的间隙
    @IBInspectable public var textHorMargin: Float = 4
    //文字垂直方向的间隙
    @IBInspectable public var textVerMargin: Float = 4
    
    //Callbacks
    public var beginEditingBlock:((_ text: String) -> Void)?
    
    public var didChangedBlock:((_ text: String) -> Void)?
    
    public var keyboardReturnBlock:((_ text: String) -> Void)?
    
    //MARK: - Private Properties
    private var oldString: String = ""
    
    //MARK: - Public Methods
    public func isValid() -> Bool {
        let tempString = textString()
        if textType == .custom {
            if !customRegex.isEmpty {
                return NSString.ysc_isMatchRegex(customRegex, with: tempString)
            }
            if tempString.isEmpty {
                return allowsEmpty
            }
            if minLength > 0 && textLength() < minLength {
                return false
            }
            return isValidByProperty()
        } else {
            if textType == .phone {
                return NSString.ysc_isMatchRegex("^\\d{1,3}[-]+\\d{3,10}$", with: tempString)
            } else if textType == .mobilePhone {
                return NSString.ysc_isMatchRegex("^(01|1)\\d{10}$", with: tempString)
            } else if textType == .identityCardNumber {
                return NSString.ysc_verifyIDCardNumber(tempString)
            } else if textType == .email {
                return NSString.ysc_isMatchRegex("^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$", with: tempString)
            } else if textType == .url {
                return NSString.ysc_isWebUrl(by: tempString)
            } else if textType == .decimal {
                return NSString.ysc_isMatchRegex("^\\d*[.]?\\d*$", with: tempString)
            }
        }
        
        return true
    }
    
    public func textString() -> String {
        if text == nil {
            return ""
        }
        return self.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    public func textLength() -> Int {
        return textString().characters.count
    }
    
    public func set(text: String, notify: Bool = true) {
        self.text = text
        if notify {
            NotificationCenter.default.post(name: NSNotification.Name.UITextFieldTextDidChange, object: self)
        }
    }
    
    //MARK: - Private Methods
    private func setup() {
        cornerRadius = 4
        borderColor = UIColor(red: CGFloat(220) / 255.0, green: CGFloat(220) / 255.0, blue: CGFloat(220) / 255.0, alpha: 1)
        placeholderColor = UIColor(red: CGFloat(200) / 255.0, green: CGFloat(200) / 255.0, blue: CGFloat(200) / 255.0, alpha: 1)
        borderStyle = .none
        clearButtonMode = .whileEditing
        if backgroundColor == nil {
            backgroundColor = UIColor.white
        }
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldChanged), name: NSNotification.Name.UITextFieldTextDidChange, object: self)
    }
    
    @objc private func textFieldChanged(notification: NSNotification) {
        guard let textField = notification.object as? UITextField else {
            return
        }
        if textField.markedTextRange != nil {
            //有高亮选择的字符串，则暂不对文字进行统计和限制
            return
        }
        if "emoji" == textInputMode?.primaryLanguage && !allowsEmoji {
            //针对emoji键盘控制是否可以输入
            textField.text = oldString
        } else {
            if isValidByProperty() {
                oldString = textString()
            } else {
                textField.text = oldString
            }
        }
        if didChangedBlock != nil {
            didChangedBlock!(textString())
        }
    }
    
    private func isValidByProperty() -> Bool {
        if maxLength > 0 && textLength() > maxLength {
            return false
        }
        if textLength() == 0 {
            return true     //永远可以删除所有输入的内容
        }
        
        //校验各种属性的设置
        let tempString = textString()
        var tempRegex = "^[ "
        
        //简单emoji表情判断
        if allowsEmoji && !emojiRegex.isEmpty {
            tempRegex.append(emojiRegex)
        }
        
        //如果为特殊类型则需要放开相应的字符输入控制
        if textType == .email || textType == .url {
            allowsPunctuation = true
            allowsLetter = true
            allowsNumber = true
        } else if textType == .decimal || textType == .phone || textType == .mobilePhone || textType == .identityCardNumber {
            if textType == .decimal {
                tempRegex.append(".")
            } else if textType == .phone {
                tempRegex.append("-")
            } else if textType == .identityCardNumber {
                tempRegex.append("Xx")
            }
            allowsEmoji = false
            allowsChinese = false
            allowsPunctuation = false
            allowsLetter = false
            allowsNumber = true
        }
        
        //标点符号判断
        if allowsPunctuation {
            if !punctuationRegex.isEmpty {
                tempRegex.append(punctuationRegex)
            } else {//只是常用特殊符号
                //参考：http://blog.csdn.net/yuan892173701/article/details/8731490
                tempRegex.append("/,!<>\\{\\}'~•£€¥\\$%@\\*&#_\\+\\?\\^\\|\\.=\\-\\(\\)\\[\\]\\\\")
                tempRegex.append("\u{3002}\u{FF1F}\u{FF01}\u{FF0C}\u{3001}\u{FF1A}\u{FF1B}\u{300C}\u{300D}\u{300E}\u{300F}\u{2018}\u{2019}\u{201C}\u{201D}\u{FF08}\u{FF09}")
                tempRegex.append("\u{3014}\u{3015}\u{3010}\u{3011}\u{2014}\u{2026}\u{2013}\u{FF0E}\u{300A}\u{300B}\u{3008}\u{3009}")
                tempRegex.append("｝｛·～")
                
                //参考：http://blog.csdn.net/monitor1394/article/details/7255767
                //\u{3000}-\u{303F} CJK标点符号
                //\u{FE10}-\u{FE1F} 中文竖排标点
                //\u{FE30}-\u{FE4F} CJK兼容符号（竖排变体、下划线、顿号）
                //\u{FE50}-\u{FE6F} 中文标点
                //\u{FF00}-\u{FFEF} 全角ASCII、全角中英文标点、半宽片假名、半宽平假名、半宽韩文字母
            }
        }
        
        //中文判断
        if allowsChinese {
            if !chineseRegex.isEmpty {
                tempRegex.append(chineseRegex)
            } else {//只是常用汉字
                tempRegex.append("\u{4E00}-\u{9FBB}")   //CJK统一汉字(20924)常用
                tempRegex.append("\u{3400}-\u{4DB5}")   //CJK统一汉字扩充A(6582)
                tempRegex.append("\u{20000}-\u{2A6D6}") //CJK统一汉字扩充B(42711)
                tempRegex.append("\u{F900}-\u{FA2D}")   //CJK兼容汉字(302)
                tempRegex.append("\u{FA30}-\u{FA6A}")   //CJK兼容汉字(59)
                tempRegex.append("\u{FA70}-\u{FAD9}")   //CJK兼容汉字(106)
                tempRegex.append("\u{2F800}-\u{2FA1D}") //CJK兼容汉字补充(542)
            }
        }
        
        //字母判断
        if allowsLetter {
            tempRegex.append("a-zA-Z")
        }
        
        //数字判断
        if allowsNumber {
            tempRegex.append("0-9")
        }
        
        tempRegex.append("]+$")
        return NSString.ysc_isMatchRegex(tempRegex, with: tempString)
    }
    
    private func resetKeyboardType() {
        keyboardType = .asciiCapable
        if textType == .phone || textType == .mobilePhone {
            keyboardType = .numberPad
        } else if textType == .identityCardNumber {
            keyboardType = .numbersAndPunctuation
        } else if textType == .decimal {
            keyboardType = .decimalPad
        } else {
            if allowsNumber {
                keyboardType = .numberPad
            }
            if allowsLetter || allowsPunctuation {
                keyboardType = .asciiCapable
            }
            if allowsEmoji || allowsChinese {
                keyboardType = .default
            }
        }
    }
    
    //MARK: - Override And Init Methods
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        resetKeyboardType()
        layoutIfNeeded()
    }
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: CGFloat(textHorMargin), dy: CGFloat(textVerMargin));
    }
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: CGFloat(textHorMargin), dy: CGFloat(textVerMargin));
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}


extension YSCTextField: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if beginEditingBlock != nil {
            beginEditingBlock!(textString())
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true // 主要是为了放开删除功能
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isFirstResponder {
            if keyboardReturnBlock != nil {
                keyboardReturnBlock!(textString())
            }
            if allowsKeyboardDismiss {
                resignFirstResponder()
                return false
            }
        }
        return true
    }
    
}


