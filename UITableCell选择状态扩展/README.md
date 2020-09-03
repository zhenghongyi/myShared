有的列表会有要求可选的需求，选择框刚好在左边，很像UITableView的选择样式。为此去改动我们原有的cell样式，不是太值，并且当类似这样的需求多了，改起来很崩溃。所以考虑扩展一下UITableCell的编辑状态来实现选择功能，省去对已有的cell进行改动以增加选择功能，并且代码无侵入。

>[代码](https://github.com/zhenghongyi/myShared/UITableCell选择状态扩展/UITable+Selection.swift)
>
> 注意点：
> 
> 
1. 设置Cell的sectionImg样式，会依赖于Cell的初始化和渲染，所以建议放到tableView.delegate的willDisplay方法里
2. 需要设置selectionStyle = .none，屏蔽系统原有Selection响应点击逻辑
3. hideSelection()是在某些混合可选cell和普通cell的场景下，为普通cell隐藏可选模式，建议放在layoutSubview方法里

### 用法

```
var selectionIndex:[Int] = []

override func viewDidLoad() {
    super.viewDidLoad()
    
    ......
    tableView.showSelection()
}

......
override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    ......
    
    cell.selectionStyle = .none

    return cell
}
    
override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.selectedImg = UIImage(named: "Selected")
    cell.unselectedImg = UIImage(named: "UnSelected")
    cell.isDataSelected = selectionIndex.contains(indexPath.row)
}
    
override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if selectionIndex.contains(indexPath.row) == false {
        selectionIndex.append(indexPath.row)
    } else {
        selectionIndex.removeAll(where: { $0 == indexPath.row })
    }
    tableView.reloadRows(at: [indexPath], with: .none)
}
```