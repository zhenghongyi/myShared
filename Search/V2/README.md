## 背景

[第一套方案](https://github.com/zhenghongyi/myShared/tree/master/Search)有两点问题：

1. SearchHelper 只是作为桥梁，不在使用场景中有其他作用，但却需要强持有属性
2. 只支持传递 keyword 作为搜索条件，不能支持多个搜索条件

--------------
[新方案](https://github.com/zhenghongyi/myShared/tree/master/Search/V2/YISearch.swift)的想法是扩展 UISearchController，用 runtime 创建多一个搜索逻辑的属性，在 UISearchController 内部完成整个搜索调用，在这里也就可以传递其他搜索条件。

要注意的是 searchHash，这个是针对多个搜索条件场景的，用来区分两次相邻搜索是否条件相同。单搜索条件场景下，可以简单的通过两次搜索关键词对比，但多搜索条件场景就比较复杂，所以需要使用者自行制定本次搜索标识。

## 使用

* 单个搜索条件

```
class SearchResponder: NSObject, YISearchResponder {
    func search(key: String?, other: Any?, finish: ((Result<Any, Error>) -> Void)?) {
        finish?(.success("搜索结果"))
    }
}

class SearchResultVC: UIViewController, YISearchResultVC {
    func updateResults(keyWord: String?, other: Any?, result: Result<Any, Error>) {
        switch result {
        case let .success(data):
            print("success:\(data)")
        case let .failure(error):
            print("failure:\(error)")
        }
    }
}
......
let searchVC = UISearchController(resultVC: SearchResultVC(), responder: SearchResponder())
tableView.tableHeaderView = searchVC.searchBar

searchVC.searchResultsUpdater = searchVC
searchVC.delegate = searchVC
    
self.searchVC = searchVC
```

* 对多个搜索条件

```
SearchResponder同上
SearchResultVC同上

class MutliSearchVC: UISearchController {
	......
    override var otherInfo: Any? {
        return ["folderID":"1"]
    }
    
    override var searchHash: String {
        var hash = searchBar.text ?? ""
        if let info = otherInfo as? [String:String], let folderID = info["folderID"] {
            hash += "folderID=" + folderID
        }
        return hash
    }
    ......
}

......
let searchVC = MutliSearchVC(resultVC: SearchResultVC(), responder: SearchResponder())
tableView.tableHeaderView = searchVC.searchBar

searchVC.searchResultsUpdater = searchVC
searchVC.delegate = searchVC
    
self.searchVC = searchVC

```
