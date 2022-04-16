//
//  YIThemeCenter.swift
//  YIThemeDemo
//
//  Created by zhenghongyi on 2022/4/16.
//

import UIKit

@objc enum YIThemePosition: Int {
    case backgroundColor
    case textColor
    case font
}

@objc protocol YIThemeValue: NSObjectProtocol {}
extension UIColor: YIThemeValue {}
extension UIFont: YIThemeValue {}

class YIThemeCenter: NSObject {
    static let shared:YIThemeCenter = YIThemeCenter()
    
    // key主题编号-位置-view
    private var t_views:[String:[YIThemePosition:NSPointerArray]] = [:]
    
    // key主题编号, value颜色值/字体值
    var theme:[String:YIThemeValue] = [:]
    
    func addItem(view:UIView, position:YIThemePosition, t_key:String) {
        if var temp = t_views[t_key] {
            let pointer = Unmanaged.passUnretained(view).toOpaque()
            if let items = temp[position] {
                items.addPointer(pointer)
            } else {
                let pointerArr = NSPointerArray(options: .weakMemory)
                pointerArr.addPointer(pointer)
                temp[position] = pointerArr
                t_views[t_key] = temp
            }
        } else {
            let pointer = Unmanaged.passUnretained(view).toOpaque()
            let pointerArr = NSPointerArray(options: .weakMemory)
            pointerArr.addPointer(pointer)
            let map:[YIThemePosition:NSPointerArray] = [position:pointerArr]
            t_views[t_key] = map
        }
    }
    
    // 更新主题
    func update() {
        for (key, items) in t_views {
            for (position, views) in items {
                views.compact()
                
                for i in 0..<views.count {
                    if let item = views.pointer(at: i), let value = theme[key] {
                        let pointer = UnsafeRawPointer(item)
                        let view = Unmanaged<UIView>.fromOpaque(pointer).takeUnretainedValue()
                        view.updateTheme(value: value, position: position)
                    }
                }
            }
        }
    }
}

// MARK: UIView
/// 使用方法:
/// 对需要支持设置主题的控件
/// 1. 扩展出对应的key,用于设置主题编号
/// 2. 重写updateTheme(value: YIThemeValue, position: YIThemePosition)方法
extension UIView {
    @IBInspectable var t_bgKey:String? {
        set {
            if let tKey = newValue, let tColor = YIThemeCenter.shared.theme[tKey] as? UIColor {
                backgroundColor = tColor
                YIThemeCenter.shared.addItem(view: self, position: .backgroundColor, t_key: tKey)
            }
        }
        get {
            return nil
        }
    }
    
    @objc func updateTheme(value: YIThemeValue, position: YIThemePosition) {
        switch position {
        case .backgroundColor:
            backgroundColor = value as? UIColor
        default:
            break
        }
    }
}

extension UILabel {
    @IBInspectable var t_textColorKey:String? {
        set {
            if let tKey = newValue, let tColor = YIThemeCenter.shared.theme[tKey] as? UIColor {
                textColor = tColor
                YIThemeCenter.shared.addItem(view: self, position: .textColor, t_key: tKey)
            }
        }
        get {
            return nil
        }
    }
    
    @IBInspectable var t_fontKey:String? {
        set {
            if let tKey = newValue, let tFont = YIThemeCenter.shared.theme[tKey] as? UIFont {
                font = tFont
                YIThemeCenter.shared.addItem(view: self, position: .font, t_key: tKey)
            }
        }
        get {
            return nil
        }
    }
    
    override func updateTheme(value: YIThemeValue, position: YIThemePosition) {
        switch position {
        case .textColor:
            textColor = value as? UIColor
        case .font:
            font = value as? UIFont
        default:
            super.updateTheme(value: value, position: position)
        }
    }
}

extension UIButton {
    @IBInspectable var t_textColorKey:String? {
        set {
            if let tKey = newValue, let tColor = YIThemeCenter.shared.theme[tKey] as? UIColor {
                titleLabel?.textColor = tColor
                YIThemeCenter.shared.addItem(view: self, position: .textColor, t_key: tKey)
            }
        }
        get {
            return nil
        }
    }
    
    @IBInspectable var t_fontKey:String? {
        set {
            if let tKey = newValue, let tFont = YIThemeCenter.shared.theme[tKey] as? UIFont {
                titleLabel?.font = tFont
                YIThemeCenter.shared.addItem(view: self, position: .font, t_key: tKey)
            }
        }
        get {
            return nil
        }
    }
    
    override func updateTheme(value: YIThemeValue, position: YIThemePosition) {
        switch position {
        case .textColor:
            titleLabel?.textColor = value as? UIColor
        case .font:
            titleLabel?.font = value as? UIFont
        default:
            super.updateTheme(value: value, position: position)
        }
    }
}
