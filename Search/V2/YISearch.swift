//
//  YISearch.swift
//  SearchDemo
//
//  Created by 郑洪益 on 2020/9/2.
//  Copyright © 2020 郑洪益. All rights reserved.
//

import UIKit

// MARK: Responder
protocol YISearchResponder {
    func search(key:String?, other:Any?, finish:((Result<Any, Error>) -> Void)?)
}

// MARK: ResultVC
protocol YISearchResultVC {
    func updateResults(keyWord:String?, other:Any?, result:Result<Any, Error>)
    
    func willPresent(searchController:UISearchController)
    func didPresent(searchController:UISearchController)
    func willDismiss(searchController:UISearchController)
    func didDismiss(searchController:UISearchController)
    func presentSearchController(_ searchController: UISearchController)
}

extension YISearchResultVC {
    func willPresent(searchController:UISearchController) {}
    func didPresent(searchController:UISearchController) {}
    func willDismiss(searchController:UISearchController) {}
    func didDismiss(searchController:UISearchController) {}
    func presentSearchController(_ searchController: UISearchController) {}
}

// MARK: SearchVC
private var YISearchResponderKey = "YISearchResponderKey"
private var YIOldSearchHashKey = "YIOldSearchHashKey"

extension UISearchController {
    convenience init(resultVC:(UIViewController & YISearchResultVC)?, responder:YISearchResponder) {
        self.init(searchResultsController: resultVC)
        self.responder = responder
    }
    
    var responder:YISearchResponder? {
        get {
            return objc_getAssociatedObject(self, &YISearchResponderKey) as? YISearchResponder
        }
        set(newValue) {
            objc_setAssociatedObject(self, &YISearchResponderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var oldSearchHash:String? {
        get {
            return objc_getAssociatedObject(self, &YIOldSearchHashKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &YIOldSearchHashKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }
    
    var otherInfo:Any? {
        return nil
    }
    
    var searchDelay:TimeInterval {
        return 2.0
    }
    
    // 针对多个搜索条件情况，作为搜索的uuid，过滤掉和最后搜索相同的搜索条件，也防止pop回来导致的触发搜索
    var searchHash:String {
        return searchBar.text ?? ""
    }
    
    var resultVC:YISearchResultVC? {
        if let resultVC = searchResultsController as? YISearchResultVC {
            return resultVC
        }
        if let resultVC = self as? YISearchResultVC {
            return resultVC
        }
        return nil
    }
    
    @objc func startSearch() {
        if let oldHash = oldSearchHash, oldHash == searchHash {
            return
        }
        oldSearchHash = searchHash
        
        let key = searchBar.text
        
        responder?.search(key: key, other: otherInfo, finish: {[weak self] (result) in
            self?.resultVC?.updateResults(keyWord: key, other: self?.otherInfo, result: result)
        })
    }
}

extension UISearchController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(startSearch), object: nil)
        perform(#selector(startSearch), with: nil, afterDelay: searchDelay)
    }
}

extension UISearchController: UISearchControllerDelegate {
    public func willPresentSearchController(_ searchController: UISearchController) {
        resultVC?.willPresent(searchController: searchController)
    }

    public func didPresentSearchController(_ searchController: UISearchController) {
        resultVC?.didPresent(searchController: searchController)
    }

    public func willDismissSearchController(_ searchController: UISearchController) {
        resultVC?.willDismiss(searchController: searchController)
    }

    public func didDismissSearchController(_ searchController: UISearchController) {
        resultVC?.didDismiss(searchController: searchController)
    }

    public func presentSearchController(_ searchController: UISearchController) {
        resultVC?.presentSearchController(searchController)
    }
}
