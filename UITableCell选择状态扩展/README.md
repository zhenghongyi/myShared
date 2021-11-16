有的列表会有要求可选的需求，选择框刚好在左边，很像UITableView的选择样式。为此去改动我们原有的cell样式，不是太值，并且当类似这样的需求多了，改起来很崩溃。所以考虑扩展一下UITableCell的编辑状态来实现选择功能，省去对已有的cell进行改动以增加选择功能，并且代码无侵入。

>[代码](https://github.com/zhenghongyi/myShared/UITableCell选择状态扩展/UITable+Selection.swift)
>
> 注意点：
> 
> 
1. 设置Cell的sectionImg样式，会依赖于Cell的初始化和渲染，所以建议放到tableView.delegate的willDisplay方法里
2. 需要设置selectionStyle = .none，屏蔽系统原有Selection响应点击逻辑
3. hideSelection()是在某些混合可选cell和普通cell的场景下，为普通cell隐藏可选模式，建议放在layoutSubview方法里

### 例子

```
let tableView:UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ...
        tableView.showSelection()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ...
        cell.textLabel?.text = "\(indexPath.row)"
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let imgs = cellImg(indexPath: indexPath)
        cell.unselectedImg = imgs.0
        cell.selectedImg = imgs.1
        cell.isDataSelected = (indexPath.row % 2) == 0
    }
    
    func cellImg(indexPath:IndexPath) -> (UIImage?, UIImage?) {
        if indexPath.row % 3 == 0 {
            return (UIImage(named: "forbinden"), UIImage(named: "forbinden"))
        } else {
            return (UIImage(named: "uncheck"), UIImage(named: "check"))
        }
    }
```

![image](https://github.com/zhenghongyi/myShared/tree/master/UITableCell选择状态扩展/TableSelection.png)