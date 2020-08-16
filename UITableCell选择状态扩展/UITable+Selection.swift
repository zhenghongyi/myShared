//
//  UITable+Selection.swift
//  LunkrAppstore
//
//  Created by zhenghongyi on 2020/3/11.
//  Copyright © 2020 Coremail. All rights reserved.
//

/**
注意点：
1. 设置Cell的sectionImg样式，会依赖于Cell的初始化和渲染，所以建议放到tableView.delegate的willDisplay方法里
2. 需要设置selectionStyle = .none，屏蔽系统原有Selection响应点击逻辑
*/

import UIKit

private var YITableCellDataSelectedKey = "YITableCell_DataSelected_Key"
private var YITableCellDataSelectedImgKey = "YITableCell_DataSelected_Img_Key"
private var YITableCellDataUnSelectedImgKey = "YITableCell_DataUnSelected_Img_Key"

extension UITableViewCell {
    
    var selectedImg:UIImage? {
        get {
            return objc_getAssociatedObject(self, &YITableCellDataSelectedImgKey) as? UIImage
        }
        set(newValue) {
            objc_setAssociatedObject(self, &YITableCellDataSelectedImgKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var unselectedImg:UIImage? {
        get {
            return objc_getAssociatedObject(self, &YITableCellDataUnSelectedImgKey) as? UIImage
        }
        set(newValue) {
            objc_setAssociatedObject(self, &YITableCellDataUnSelectedImgKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var isDataSelected:Bool {
        get {
            return (objc_getAssociatedObject(self, &YITableCellDataSelectedKey) as? Bool) ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &YITableCellDataSelectedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            isSelected = false
            layoutSelection()
        }
    }
    
    private func layoutSelection() {
        guard selectedImg != nil && unselectedImg != nil else { return }
        guard let editClass = NSClassFromString("UITableViewCellEditControl") else {
            return
        }
        
        for control in subviews where control.isMember(of: editClass) {
            for itemView in control.subviews {
                if let imgView = itemView as? UIImageView {
                    imgView.image = isDataSelected ? selectedImg : unselectedImg
                    break
                }
            }
            break
        }
    }
    
    func hideSelection() {
        contentView.frame = CGRect(x: 0, y: 0, width: width, height: contentView.height)
        bringSubviewToFront(contentView)
    }
}

extension UITableView {
    func showSelection() {
        isEditing = true
        allowsMultipleSelection = true
        allowsMultipleSelectionDuringEditing = true
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
}
