//
//  ConstraintPtl.swift
//  MailUI
//
//  Created by hyzheng on 2023/4/25.
//
/// 约束基础可用属性和方法

import UIKit

protocol MUContraintable {}
protocol MUContraintConstant {
    var float:CGFloat { get }
}

protocol MUContraintRelation: MUContraintable {
    @discardableResult
    func equalTo(_ target:MUContraintable) -> MUContraintRelation
    @discardableResult
    func equalToSuperview() -> MUContraintRelation
    @discardableResult
    func lessThanOrEqualTo(_ target:MUContraintable) -> MUContraintRelation
    @discardableResult
    func greaterThanOrEqualTo(_ target:MUContraintable) -> MUContraintRelation
    func offset(_ constant:MUContraintConstant)
}

protocol MUContraintExtendable: MUContraintRelation {
    var left:MUContraintExtendable { get }
    var top:MUContraintExtendable { get }
    var right:MUContraintExtendable { get }
    var bottom:MUContraintExtendable { get }
    var leading:MUContraintExtendable { get }
    var trailing:MUContraintExtendable { get }
    var width:MUContraintExtendable { get }
    var height:MUContraintExtendable { get }
    var centerX:MUContraintExtendable { get }
    var centerY:MUContraintExtendable { get }
    var edges:MUContraintExtendable { get }
    var center:MUContraintExtendable { get }
}

extension UIView: MUContraintable {}
extension Int: MUContraintable, MUContraintConstant {
    var float: CGFloat {
        return CGFloat(self)
    }
}
extension Double: MUContraintable, MUContraintConstant {
    var float: CGFloat {
        return CGFloat(self)
    }
}
extension CGFloat: MUContraintable, MUContraintConstant {
    var float: CGFloat {
        return self
    }
}
