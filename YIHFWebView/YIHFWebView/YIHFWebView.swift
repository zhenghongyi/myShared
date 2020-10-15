//
//  YIHFWebView.swift
//  YIHFWebView
//
//  Created by zhenghongyi on 2020/10/15.
//

import UIKit
import SnapKit
import WebKit

class YIHFWebView: UIScrollView, UIGestureRecognizerDelegate {
    private var headerView = UIView()
    
    private var webView = WKWebView()
    
    private var footView = UIView()
    
    private var subScrollView:UIScrollView {
        return webView.scrollView
    }
    
    private var subScrollOb:NSKeyValueObservation?
    
    private var anchorY: CGFloat = 0 // 锚点
    public var headHeight:CGFloat {
        set {
            anchorY = newValue
            headerView.snp.updateConstraints { (make) in
                make.height.equalTo(anchorY)
            }
        }
        get {
            return anchorY
        }
    }
    
    private var _footHeight:CGFloat = 0 // 对内属性，用于清除重置
    public var footHeight:CGFloat { // 对外属性
        set {
            _footHeight = newValue
            footView.snp.updateConstraints { (make) in
                make.height.equalTo(_footHeight)
            }
        }
        get {
            return _footHeight
        }
    }
    
    private var mainOffsetY: CGFloat = 0 // 外层主ScrollView的ContentOffset Y轴点
    private var subOffsetY: CGFloat = 0 // 内层子ScrollView的ContentOffset Y轴点
    
    public func config(head:UIView?, web:WKWebView?, foot:UIView?) {
        if let tmp = head {
            headerView = tmp
        }
        
        if let tmp = web {
            webView = tmp
        }
        
        if let tmp = foot {
            footView = tmp
        }
        
        commonInit()
    }
    
    private func commonInit() {
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        showsVerticalScrollIndicator = false
        
        let contentView = UIView()
        addSubview(contentView)
        
        contentView.addSubview(headerView)
        contentView.addSubview(webView)
        
        anchorY = headerView.bounds.size.height
        headerView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(contentView)
            make.height.equalTo(anchorY)
        }
        
        webView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(contentView)
            make.top.equalTo(self.headerView.snp.bottom)
            make.height.equalTo(self.snp.height)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
            make.width.equalTo(self)
        }
        
        for item in subScrollView.subviews where item.ClassName == "WKContentView" {
            _footHeight = footView.bounds.size.height
            
            item.addSubview(footView)
            
            footView.snp.makeConstraints { (make) in
                make.right.left.bottom.equalTo(item)
                make.height.equalTo(_footHeight)
            }
        }
        
        subScrollOb = subScrollView.observe(\.contentOffset, options: [.old, .new]) {[weak self] (_, changeValue) in
            //内层滑动
            if let oldPoint = changeValue.oldValue, let newPoint = changeValue.newValue, oldPoint.y != newPoint.y {
                self?.handleSubScrollView()
            }
        }
    }
    
    private func handleSubScrollView() {
        if mainOffsetY < anchorY {// 外层offset未抵达锚点，内层保持不动
            webView.scrollView.contentOffset = .zero
        }
        // 记录内层offsetY
        subOffsetY = subScrollView.contentOffset.y
    }
    
    override var contentOffset: CGPoint {
        didSet {
            if contentOffset.y != oldValue.y {
                if subOffsetY > 0 {// 外层已抵达锚点，固定到锚点位置不动
                    // 滚动到底部，确保可以自然拖动
                    if subOffsetY + subScrollView.bounds.size.height >= subScrollView.contentSize.height {
                        if isDragging {
                            if contentOffset.y < oldValue.y {// 往上拖动
                                if contentOffset.y < anchorY {
                                    contentOffset.y = anchorY
                                }
                            }
                        }
                    } else {
                        contentOffset.y = anchorY
                    }
                } else {
                    //否则，外层滚动
                }
                //记录外层offsetY
                mainOffsetY = contentOffset.y
            }
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func updateLayout() {
        if #available(iOS 13, *) {
            return
        }
        if footView.frame.origin.y != subScrollView.contentSize.height - _footHeight {
            if let footSuperView = footView.superview {
                footView.snp.remakeConstraints { (make) in
                    make.right.left.equalTo(footSuperView)
                    make.height.equalTo(_footHeight)
                    make.top.equalTo(subScrollView.contentSize.height - _footHeight)
                }
            }
        }
    }
    
    deinit {
        subScrollOb?.invalidate()
    }
}

// MARK: 返回ClassName
extension NSObject {
    var ClassName:String {
        let name = type(of: self).description()
        if name.contains(".") {
            return name.components(separatedBy: ".")[1]
        } else {
            return name
        }
    }
}
