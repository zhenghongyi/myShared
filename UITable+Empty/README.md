## UITableView+Empty

一行代码配置空内容提示图，自动检测展示空提示图，代码无侵入，可扩展性强，支持autoLayout和设置位置

## 特点

| _  | 特点  | 解释 |
|:-- |:------:|:------------- |
| 1  | 轻量级  |  实现原理简单 |
| 2  | 无侵入  |  基于UITableView扩展，使用UIView作为空提示图 |
| 3  | 使用简单 | 一行代码完成，自动检测是否添加空提示图 |
| 4  | 支持约束 | 已支持autoLayout，可以设置空提示图的位置 |
| 5  | 扩展性强 | 使用UIView作为空提示图，在UIView上可根据自己所需做各种扩展 |

## 使用

### 基本使用方式

```
let emptyView = UIView()
emptyView.backgroundColor = .blue
tableView.configEmptyView(emptyView)

...

tableView.reloadAndCheckEmpty()
```

### 建议使用方式

一般每个项目里，空提示图的类型是有限的几种，所以建议可以扩展UITableView，预设下这几种空提示图类型，例如：

```
import SnapKit

extension UITableView {
    // 置于顶部的空提示语
    func showEmptyTopTip(_ tip:String, offSetY:CGFloat = 20) {
        let containView = UIView()
        containView.backgroundColor = self.backgroundColor
        
        let tipLabel = UILabel()
        tipLabel.text = tip
        tipLabel.textAlignment = .center
        containView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(offSetY)
            make.width.equalToSuperview()
            make.height.equalTo(30)
        }
        
        configEmptyView(containView)
    }
    // tableHeader下的空提示语
    func showEmptyBelowHeader(tip:String) {
        let headerHeight = tableHeaderView?.height ?? 0
        let containView = UIView()
        containView.backgroundColor = self.backgroundColor
        
        let tipLabel = UILabel()
        tipLabel.text = tip
        tipLabel.textAlignment = .center
        containView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(52)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        
        configEmptyView(containView, emptyInset: UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0))
    }
    // 带图片的空提示视图
    func showEmptyImg(tip:String) {
        let containView = UIView()
        containView.backgroundColor = .white
        
        let imgView = UIImageView(image: UIImage(named: "content_empty"))
        containView.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(containView.snp.centerY)
        }
        
        let tipLabel = UILabel()
        tipLabel.text = tip
        containView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imgView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        
        configEmptyView(containView)
    }
}

```

### 后记

参考了大神的[设计](https://github.com/ChenYilong/CYLTableViewPlaceHolder)，从自己的想法出发，自己做的一套方案，主要是想简化调用方式和增加约束，也补上原设计里不能设置空提示图位置的问题。