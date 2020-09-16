//
//  YIThemeCenter.swift
//  ThemeDemo
//
//  Created by zhenghongyi on 2020/9/14.
//  Copyright © 2020 Coremail. All rights reserved.
//

import UIKit

@objc enum YIThemePosition: Int {
    case backgroundColor
    case textColor
    case font
}

class YIThemeCenter: NSObject {
    static let shared:YIThemeCenter = YIThemeCenter()
    
    private var t_views:[String:[YIThemePosition:NSPointerArray]] = [:]
    
    var theme:[String:Any] = [:] {
        didSet {
            for (key, _) in theme {
                if t_views[key] == nil {
                    t_views[key] = [:]
                }
            }
        }
    }
    
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
        }
    }
    
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
    
    @objc func updateTheme(value: Any, position: YIThemePosition) {
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
    
    override func updateTheme(value: Any, position: YIThemePosition) {
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
