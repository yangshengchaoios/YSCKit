//
//  YSCTextView.swift
//  YSCKit
//
//  Created by 杨胜超 on 12/1/16.
//  Copyright © 2016年 Builder. All rights reserved.
//

import UIKit

@IBDesignable
public class YSCTextView: UITextView {
    
    //MARK: - Public Properties
    //Content Control
    @IBInspectable public var maxLength: Int = 400              //-1 means no limit
    @IBInspectable public var customRegex: String = ""          //custom regex by user
    @IBInspectable public var chineseRegex: String = ""         //regex for chinese
    @IBInspectable public var punctuationRegex: String = ""     //regex for punctuation
    @IBInspectable public var emojiRegex: String = ""           //regex for emoji
    @IBInspectable public var allowsEmpty: Bool = false         //is allows empty text
    @IBInspectable public var allowsEmoji: Bool = false         //is allows input emojis
    @IBInspectable public var allowsChinese: Bool = true        //is allows input chinese
    @IBInspectable public var allowsPunctuation: Bool = true    //is allows input punctuations
    @IBInspectable public var allowsKeyboardDismiss: Bool = true//is allows dismiss when press done of keyboard
    @IBInspectable public var allowsLetter: Bool = true         //is allows input english letters
    @IBInspectable public var allowsNumber: Bool = true         //is allows input numbers
    
    //UI Control
    //占位文本label
    public let placeholderLabel: UILabel = UILabel()
    //剩余字符数
    public var remainingCount: Int = 400 {
        didSet {
            placeholderLabel.isHidden = remainingCount < maxLength
        }
    }
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
    //占位文本
    @IBInspectable public var placeholder: String! {
        didSet {
            placeholderLabel.text = placeholder
            let placeholderMaxSize = CGSize(width: frame.width - 2 * 8, height: frame.height - 2 * 8)
            placeholderLabel.frame.origin = CGPoint(x: 8, y: 8)
            placeholderLabel.frame.size = placeholder.boundingRect(with: placeholderMaxSize,
                                                                   options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                   attributes: [NSFontAttributeName: placeholderLabel.font],
                                                                   context: nil).size
        }
    }
    //占位文本颜色
    @IBInspectable public var placeholderColor: UIColor! {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    @IBInspectable public var useInputAccessory: Bool = false {
        didSet{
            if useInputAccessory && inputAccessoryView == nil {
                inputAccessoryView = createInputAccessoryView()
            }
        }
    }
    
    //Callbacks
    public var beginEditingBlock:((_ text: String) -> Void)?
    
    public var didChangedBlock:((_ text: String) -> Void)?
    
    public var keyboardReturnBlock:((_ text: String) -> Void)?
    
    //MARK: - Private Properties
    private var oldString: String = ""
    
    //MARK: - Public Methods
    public func isValid() -> Bool {
        let tempString = textString()
        if !customRegex.isEmpty {
            return NSString.ysc_isMatchRegex(customRegex, with: tempString)
        }
        if tempString.isEmpty {
            return allowsEmpty
        }
        return isValidByProperty()
    }
    
    public func textString() -> String {
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    public func textLength() -> Int {
        return textString().characters.count
    }
    
    public func set(text: String, notify: Bool = true) {
        self.text = text
        if notify {
            NotificationCenter.default.post(name: NSNotification.Name.UITextViewTextDidChange, object: self)
        }
    }
    
    //MARK: - Private Methods
    private func setup() {
        cornerRadius = 8
        borderColor = UIColor(red: CGFloat(220) / 255.0, green: CGFloat(220) / 255.0, blue: CGFloat(220) / 255.0, alpha: 1)
        placeholder = ""
        placeholderColor = UIColor(red: CGFloat(200) / 255.0, green: CGFloat(200) / 255.0, blue: CGFloat(200) / 255.0, alpha: 1)
        
        if font != nil {
            placeholderLabel.font = font!
        } else {
            placeholderLabel.font = UIFont.systemFont(ofSize: 14)
        }
        placeholderLabel.isHidden = !text.isEmpty
        placeholderLabel.numberOfLines = 0
        addSubview(placeholderLabel)
        
        if backgroundColor == nil {
            backgroundColor = UIColor.white
        }
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(textViewChanged), name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
    
    @objc private func textViewChanged(notification: NSNotification) {
        guard let textView = notification.object as? UITextView else {
            return
        }
        if textView.markedTextRange != nil { //有高亮选择的字符串，则暂不对文字进行统计和限制
            placeholderLabel.isHidden = true
            return
        }
        if "emoji" == textInputMode?.primaryLanguage && !allowsEmoji {
            //针对emoji键盘控制是否可以输入
            textView.text = oldString
        } else {
            if isValidByProperty() {
                oldString = textString()
            } else {
                textView.text = oldString
            }
        }
        
        remainingCount = maxLength - textLength()
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
    
    private func createInputAccessoryView() -> UIView {
        let accessoryView = UIView()
        accessoryView.bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: 40)
        accessoryView.backgroundColor = UIColor(hex: 0xf8f8f8)
        
        accessoryView.addLineWithSide(.inTop, color: UIColor(hex: 0x666666), thickness: 0.5, margin1: 0, margin2: 0)
        
        let doneButton: UIButton = {
            let button = UIButton(type: .custom)
            accessoryView.addSubview(button)
            button.setTitle(NSLocalizedString("Done", comment: "完成"), for: .normal)
            button.setTitleColor(KColorTintColor, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 10)
            button.addTarget(self, action: #selector(didDoneBtnClick(_:)), for: .touchUpInside)
            button.snp.makeConstraints { (make) in
                make.centerY.equalTo(accessoryView)
                make.right.equalTo(accessoryView).offset(-5)
            }
            return button
        }()
        doneButton.backgroundColor = UIColor.clear
        
        return accessoryView
    }
    
    @objc private func didDoneBtnClick(_ button: UIButton) -> Void {
        resignFirstResponder()
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
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    public init(frame: CGRect) {
        super.init(frame: frame, textContainer: nil)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
}

extension YSCTextView: UITextViewDelegate {
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if beginEditingBlock != nil {
            beginEditingBlock!(textString())
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if isFirstResponder {
            if keyboardReturnBlock != nil {
                keyboardReturnBlock!(textString())
            }
            if allowsKeyboardDismiss && text == "\n" {
                resignFirstResponder()
                return false
            }
        }
        return true
    }
    
}
