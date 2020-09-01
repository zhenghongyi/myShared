//
//  UITableView+Empty.swift
//  LunkrAppstore
//
//  Created by 郑洪益 on 2018/4/25.
//  Copyright © 2018年 Coremail. All rights reserved.
//

import UIKit

private var YITableOldScrollEnabledKey = "YITableOldScrollEnabledKey"
private var YITableScrollEnableWhenEmptyKey = "YITableScrollEnableWhenEmptyKey"
private var YITableEmptyInsetValueKey = "YITableEmptyInsetValueKey"

let YITableEmptyViewTag = 95278

public extension UITableView {
    private var oldScrollEnable:Bool? {
        get {
            return objc_getAssociatedObject(self, &YITableOldScrollEnabledKey) as? Bool
        }
        set(newValue) {
            objc_setAssociatedObject(self, &YITableOldScrollEnabledKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    private var scrollEnabelWhenEmpty:Bool? {
        get {
            return objc_getAssociatedObject(self, &YITableScrollEnableWhenEmptyKey) as? Bool
        }
        set(newValue) {
            objc_setAssociatedObject(self, &YITableScrollEnableWhenEmptyKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    private var emptyInsetValue:NSValue? {
        get {
            return objc_getAssociatedObject(self, &YITableEmptyInsetValueKey) as? NSValue
        }
        set(newValue) {
            objc_setAssociatedObject(self, &YITableEmptyInsetValueKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func configEmptyView(_ view:UIView, scrollWhenEmpty:Bool = false, emptyInset:UIEdgeInsets = .zero) {
        if let lastEmptyView = self.viewWithTag(YITableEmptyViewTag) {
            lastEmptyView.removeFromSuperview()
        }
        
        view.tag = YITableEmptyViewTag
        view.isHidden = true
        addSubview(view)
        
        self.scrollEnabelWhenEmpty = scrollWhenEmpty
        self.emptyInsetValue = NSValue(uiEdgeInsets: emptyInset)
    }
    
    func reloadAndCheckEmpty() {
        self.reloadData()
        // 异步执行原因：
        // 1.reloadData是异步操作；
        // 2.确保tableView已被layout到界面上
        DispatchQueue.main.async {
            self.checkEmpty()
        }
    }
    
    func hideEmptyView(_ scrollEnable:Bool = true) {
        guard let emptyView = self.viewWithTag(YITableEmptyViewTag) else {
            print("没有调用configEmptyView配置过或者已被移除")
            return
        }
        emptyView.isHidden = true
        
        self.isScrollEnabled = scrollEnable
    }
    
    private func checkEmpty() {
        guard let dataSource = self.dataSource else {
            return
        }

        var isEmpty = true

        let sections = dataSource.numberOfSections?(in: self) ?? 1

        for index in 0..<sections {
            if dataSource.tableView(self, numberOfRowsInSection: index) > 0 {
                isEmpty = false
            }
        }
        
        if isEmpty == true {
            guard let emptyView = self.viewWithTag(YITableEmptyViewTag) else {
                print("没有调用configEmptyView配置过或者已被移除")
                return
            }
            
            let emptyInset = emptyInsetValue?.uiEdgeInsetsValue ?? UIEdgeInsets.zero
            remakeConstraints(to: emptyView, inset: emptyInset)
            
            if emptyView.isHidden == false {
                self.bringSubviewToFront(emptyView)
                return
            }
            
            self.oldScrollEnable = self.isScrollEnabled
            self.isScrollEnabled = self.scrollEnabelWhenEmpty ?? false
            
            emptyView.isHidden = false
            self.bringSubviewToFront(emptyView)
        } else {
            self.isScrollEnabled = self.oldScrollEnable ?? true
            if let emptyView = self.viewWithTag(YITableEmptyViewTag) {
                emptyView.isHidden = true
            }
        }
    }
    
    private func remakeConstraints(to emptyView:UIView, inset:UIEdgeInsets) {
        // remove old constraints
        var oldConstraints = constraints.filter { (item) -> Bool in
            return (item.firstItem as? UIView) == emptyView && (item.secondItem as? UIView) == self
        }
        removeConstraints(oldConstraints)
        
        oldConstraints = emptyView.constraints.filter { (item) -> Bool in
            return (item.firstItem as? UIView) == emptyView && item.secondItem == nil
        }
        emptyView.removeConstraints(oldConstraints)
        
        // add new constraints
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            NSLayoutConstraint(item: emptyView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: inset.left),
            NSLayoutConstraint(item: emptyView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: inset.top)
        ])
        
        let emptyW = bounds.size.width - inset.left - inset.right
        let emptyH = bounds.size.height - inset.top - inset.bottom
        emptyView.addConstraints([
            NSLayoutConstraint(item: emptyView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: emptyW),
            NSLayoutConstraint(item: emptyView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: emptyH)
        ])
        
    }
}
