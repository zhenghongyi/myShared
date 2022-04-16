# YITheme

## 特点

1. 使用简单
2. 基于扩展而来，对现有代码无侵入性
3. 支持xib设置
4. 可针对所需，对指定控件扩展主题支持

## 示例

1 设置主题编号对应主题值

```
YIThemeCenter.shared.theme = [MainThemeColor:UIColor.systemBlue,
                              MainTextColor:UIColor.black,
                              MainTextFont:UIFont.systemFont(ofSize: 22),
                              SubTextColor: UIColor.gray,
                              SubTextFont: UIFont.systemFont(ofSize: 15),
                              AlertTextColor:UIColor.red]
```

2 扩展指定控件

```
extension UILabel {
    @IBInspectable var t_textColorKey:String? {
        set {
            if let tKey = newValue, let tColor = YIThemeCenter.shared.theme[tKey] as? UIColor {
                textColor = tColor
                YIThemeCenter.shared.addItem(view: self, position: .textColor, t_key: tKey)
            }
        }
        get {
            return nil
        }
    }
    
    @IBInspectable var t_fontKey:String? {
        set {
            if let tKey = newValue, let tFont = YIThemeCenter.shared.theme[tKey] as? UIFont {
                font = tFont
                YIThemeCenter.shared.addItem(view: self, position: .font, t_key: tKey)
            }
        }
        get {
            return nil
        }
    }
    
    override func updateTheme(value: YIThemeValue, position: YIThemePosition) {
        switch position {
        case .textColor:
            textColor = value as? UIColor
        case .font:
            font = value as? UIFont
        default:
            super.updateTheme(value: value, position: position)
        }
    }
}
```

3 使用

```
subTitleLabel.t_textColorKey = SubTextColor
subTitleLabel.t_fontKey = SubTextFont
```