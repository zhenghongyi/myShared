//
//  AutoTestIDHP.swift
//  TestDemo
//
//  Created by 郑洪益 on 2020/8/16.
//  Copyright © 2020 郑洪益. All rights reserved.
//

import UIKit

@objcMembers class AutoTestIDHP: NSObject {
    public static func setupTestID(for obj:AnyObject) {
        guard obj is UIView || obj is UIViewController else {
            return
        }
        
        let className = NSStringFromClass(type(of: obj))
        // 剔除系统类和其他干扰类
        if className.hasPrefix("UI") || className.hasPrefix("_") || className.hasPrefix("WK") || className.hasPrefix("TUI") {
            return
        }
        
        // Mirror只适用swift，runtime只适用oc，双重保证
        let mirror = Mirror(reflecting: obj)
        for child in mirror.children {
            if let itemView = child.value as? UIView, itemView.accessibilityIdentifier == nil {
                itemView.accessibilityIdentifier = child.label
            }
        }
        
        var count:UInt32 = 0
        if let propertys = class_copyPropertyList(type(of: obj), &count) {
            for i in 0..<count {
                let p = propertys[Int(i)]
                let name = String(cString:property_getName(p))
                
                let value = obj.value(forKey: name)
                if let itemView = value as? UIView, itemView.accessibilityIdentifier == nil {
                    itemView.accessibilityIdentifier = name
                }
            }
        }
    }
}

// 建议在debug模式下手动调用此方法
extension UIView {
    @objc public static func swizzleMoveToSuperview() {
        let originSEL = #selector(didMoveToSuperview)
        let customSEL = #selector(customDidMoveToSuperview)
        
        if let originMethod = class_getInstanceMethod(self, originSEL), let customMethod = class_getInstanceMethod(self, customSEL) {
            method_exchangeImplementations(originMethod, customMethod)
        }
    }
    
    @objc func customDidMoveToSuperview() {
        customDidMoveToSuperview()
        AutoTestIDHP.setupTestID(for: self)
    }
    
}
