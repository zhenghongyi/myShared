//
//  SearchHelper.swift
//  TestDemo
//
//  Created by 郑洪益 on 2020/7/26.
//  Copyright © 2020 郑洪益. All rights reserved.
//

import UIKit

public protocol SearchPtl {
    func search(key:String?, finish:((Bool, Any?, Error?) -> Void)?)
}

public protocol SearchVCPtl {
     var updateBlock:((String?) -> Void)? { get set }
     
    var willPresent:((UISearchController?) -> Void)? { get set }
    
    var willDismiss:((UISearchController?) -> Void)? { get set }
}

public protocol SearchResultPtl {
    func willSearch(keyWord:String?)
    
    func update(success:Bool, result:Any?, keyWord:String?, error:Error?)
    
    func present(_ searchVC:UISearchController?)
    func dismiss(_ searchVC:UISearchController?)
    
    var selectBlock:((Any?, IndexPath?) -> Void)? { get set }
}

public class SearchHelper: NSObject {
    var responder:SearchPtl?
    
    var resulter:SearchResultPtl?
    
    var searchVC:SearchVCPtl?
    
    public var delay:TimeInterval = 2.0
    
    var selectBlock:((Any?, IndexPath?) -> Void)? {
        get {
            return self.resulter?.selectBlock
        }
        set(newValue) {
            self.resulter?.selectBlock = newValue
        }
    }
    
    public init(searchPtl:SearchPtl?, resultPtl:SearchResultPtl?, searchVCPtl:SearchVCPtl? = nil) {
        responder = searchPtl
        resulter = resultPtl
        searchVC = searchVCPtl
        
        super.init()
        configure()
    }
    
    private func configure() {
        searchVC?.willPresent = {[weak self] (searchController) in
            self?.resulter?.present(searchController)
        }

        searchVC?.willDismiss = {[weak self] (searchController) in
            self?.deliverToResulter(searchController)
        }

        searchVC?.updateBlock = {[weak self] (keyWord) in
            self?.search(keyWord: keyWord)
        }
    }
    
    private var lastKeyWord:String?
    private var oldKeyWord:String?
    
    func deliverToResulter(_ searchVC:UISearchController?) {
        resulter?.dismiss(searchVC)
        oldKeyWord = nil
    }
    
    func search(keyWord:String?) {
        // pop返回UISearchVC的时候，会调用一次updateSearchResults，加入oldKeyWord判断优化体验
        if oldKeyWord == keyWord {
            return
        }
        
        oldKeyWord = keyWord
        guard let keyWord = keyWord else {
            return
        }
        if keyWord.isEmpty == true {
            return
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(startSearch(keyWord:)), object: lastKeyWord)
        lastKeyWord = keyWord
        self.perform(#selector(startSearch(keyWord:)), with: lastKeyWord, afterDelay: delay)
    }
    
    @objc func startSearch(keyWord:String?) {
        resulter?.willSearch(keyWord: keyWord)
        
        responder?.search(key: keyWord, finish: { [weak self] (success, result, error) in
            self?.resulter?.update(success: success, result: result, keyWord: keyWord, error: error)
        })
    }
}



extension SearchHelper : UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        self.search(keyWord: searchController.searchBar.text)
    }
}

extension SearchHelper : UISearchControllerDelegate {
    public func willPresentSearchController(_ searchController: UISearchController) {
        resulter?.present(searchController)
    }
    
    public func willDismissSearchController(_ searchController: UISearchController) {
        resulter?.dismiss(searchController)
    }
}
