## 背景

项目里的UITest，都是由QA通过自动化去完成。大部分情况下是通过XPath来定位到元素，但XPath相对来说不是一个好的方式，特别是一旦某个功能或者界面重构，又得重新找定位路径，相较来说元素id更靠谱。但一般来说，我们开发过程中很少用到accessibilityIdentifier这个属性。

所以，面临的问题是，项目已经开展很久，许多界面上没有元素id；另外，由于没有使用到，也没有养成习惯，新开发出来的界面，也经常忘记添加元素id，导致经常需要QA来提要求添加id。

最终的想法是，一般情况下，我们界面上有意义的控件元素，都会是代码里的一个属性，而属性名字在同个界面里是不会有重复的，那么属性字符串，就可以作为这个控件的定位元素id。而借助继承和runtime，我们可以实现accessibilityIdentifier的自动添加。

> [代码](https://github.com/zhenghongyi/myShared/自动添加TestID/AutoTestIDHP.swift)

> class_copyPropertyList是无法用在swift文件上的，除非swift文件声明了@objc，但我不可能把所有的swift文件都去改一遍；而Mirror是swift的属性，也无法用在oc文件上；最终我采用了一个偷懒的办法，那就是两个方法都用上，毕竟一个个的判断是oc还是swift文件太费力。

>当然对于那些不是属性的控件，需要额外手动添加，这个解决方法是处理大部分场景。

## 添加到项目中

1. 一般来说，大家的项目，都有用自定义的通用父类UIViewController，所以AutoTestIDHP.setupTestID可以放在父类的UIViewController中；
2. 如果有自定义的父类UIView，也可以像上面一样的做法。但我的项目里没有这样的，所以通过runtime去修改掉`didMoveToSuperview`的实现，把AutoTestIDHP.setupTestID给添加进去。


## 注意

1. 建议在debug模式下使用AutoTestIDHP.setupTestID。因为TestID对release包无意义，并且在个人的使用过程中发现，某些属性的使用不规范，也会由此暴露出来。
2. 尽可能的剔除掉系统类。系统类里添加定位元素无意义，并且拖慢速度，最要紧的是可能会引起崩溃。
3. 可以根据自己需要，剔除其他类。比如第三方库的控件，像YYKit，不需要再去遍历YYKit控件里面内部的控件。

