//
//  UIScrollView+HeadFooter.swift
//  iOSMailKit
//
//  Created by hyzheng on 2020/10/14.
//  Copyright © 2020 hyzheng. All rights reserved.
//

import Foundation

// MARK: UIScrollView Refresh Header
extension UIScrollView {
    func addHeaderRefresh(attributedTitle: NSAttributedString? = nil, block: @escaping () -> Void) {
        let refresh = UIRefreshControl()
        refresh.attributedTitle = attributedTitle
        refresh.eAddAction(block: { _ in
            block()
        }, controlEvents: .valueChanged)
        refreshControl = refresh
    }

    func endHeaderRefesh() {
        refreshControl?.endRefreshing()
    }

    func beginHeaderRefresh() {
        // UIRefreshControl的两个坑：
        // 2. 调用-beginRefreshing方法不会自动显示进度圈，需要手动设置ContentOffset露出UIRefreshControl
        // 2. 调用-beginRefreshing方法不会触发UIControlEventValueChanged事件，需要手动调用
        setContentOffset(CGPoint(x: 0, y: contentOffset.y - (refreshControl?.bounds.size.height ?? 0)), animated: true)
        refreshControl?.beginRefreshing()
        refreshControl?.sendActions(for: .valueChanged)
    }

    func removeRefreshHeader() {
        endHeaderRefesh()
        DispatchQueue.main.async {
            self.refreshControl = nil
        }
    }
}

// MARK: UIScrollView Refresh Footer
private var ScrollFooterKey = "ScrollFooterKey"
private var ScrollContentSizeOBKey = "ScrollContentSizeOBKey"
private var ScrollContentOffsetOBKey = "ScrollContentOffsetOBKey"
extension UIScrollView {
    var refreshFooter:RefreshFooter? {
        get {
            return objc_getAssociatedObject(self, &ScrollFooterKey) as? RefreshFooter
        }
        set(newvalue) {
            objc_setAssociatedObject(self, &ScrollFooterKey, newvalue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var contentSizeOB:NSKeyValueObservation? {
        get {
            return objc_getAssociatedObject(self, &ScrollContentSizeOBKey) as? NSKeyValueObservation
        }
        set(newvalue) {
            objc_setAssociatedObject(self, &ScrollContentSizeOBKey, newvalue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    private var contentOffsetOB:NSKeyValueObservation? {
        get {
            return objc_getAssociatedObject(self, &ScrollContentOffsetOBKey) as? NSKeyValueObservation
        }
        set(newvalue) {
            objc_setAssociatedObject(self, &ScrollContentOffsetOBKey, newvalue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func addFooterRefresh(_ block:(() -> Void)?) {
        reset()
        
        if refreshFooter == nil {
            refreshFooter = LoadingFooter(frame: CGRect(x: 0, y: contentSize.height, width: bounds.size.width, height: 50))
        }
        
        guard let refreshFooter = refreshFooter else {
            return
        }
        let footerH = refreshFooter.bounds.size.height
        addSubview(refreshFooter)
        contentInset.bottom += footerH
        
        contentSizeOB = observe(\.contentSize, options: [.new, .old], changeHandler: { _, change in
            if let newContentSize = change.newValue {
                refreshFooter.frame = CGRect(x: 0, y: newContentSize.height, width: newContentSize.width, height: footerH)
            }
        })
        contentOffsetOB = observe(\.contentOffset, options: [.new, .old], changeHandler: {[weak self] _, change in
            guard let strongSelf = self else { return }
            if let newOffset = change.newValue, newOffset.y + strongSelf.bounds.size.height > refreshFooter.frame.origin.y && refreshFooter.isRefreshing == false && refreshFooter.bounds.size.width > 0 {
                refreshFooter.isRefreshing = true
                block?()
            }
        })
    }
    
    func endFooterRefresh() {
        refreshFooter?.isRefreshing = false
    }
    
    func reset() {
        refreshFooter?.removeFromSuperview()
        refreshFooter?.isRefreshing = false
        contentSizeOB?.invalidate()
        contentSizeOB = nil
        contentOffsetOB?.invalidate()
        contentOffsetOB = nil
        if let footerH = refreshFooter?.bounds.size.height {
            contentInset.bottom -= footerH
        }
    }
    
    func removeRefreshFooter() {
        reset()
        refreshFooter?.removeFromSuperview()
        refreshFooter = nil
    }
    
    func endFooterRefreshNoMore() {
        refreshFooter?.removeFromSuperview()
        refreshFooter = RefreshFooter(frame: .zero)
        addFooterRefresh({})
    }
    
    var isNoMoreFooter:Bool {
        return !(refreshFooter is LoadingFooter)
    }
}

class RefreshFooter: UIView {
    var isRefreshing:Bool = false
}

private class LoadingFooter: RefreshFooter {
    override var isRefreshing:Bool {
        didSet {
            isRefreshing ? loadingView.startAnimating() : loadingView.stopAnimating()
        }
    }
    let loadingView = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        addSubview(loadingView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        loadingView.frame = CGRect(x: bounds.size.width / 2 - 15, y: bounds.size.height / 2 - 15, width: 30, height: 30)
    }
}
