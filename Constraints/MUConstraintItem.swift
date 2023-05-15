//
//  MUConstraintItem.swift
//  MailUI
//
//  Created by hyzheng on 2023/4/25.
//
/// 约束对象与约束的属性和方法

import UIKit

class MUConstraintItem: MUContraintExtendable {
    
    let source:any MUCSource
    
    init(source: any MUCSource) {
        self.source = source
    }
    
    var attributes:[NSLayoutConstraint.Attribute] = []
    
    var left: MUContraintExtendable {
        attributes.append(.left)
        return self
    }
    var top: MUContraintExtendable {
        attributes.append(.top)
        return self
    }
    var right: MUContraintExtendable {
        attributes.append(.right)
        return self
    }
    var bottom: MUContraintExtendable {
        attributes.append(.bottom)
        return self
    }
    var leading: MUContraintExtendable {
        attributes.append(.leading)
        return self
    }
    var trailing: MUContraintExtendable {
        attributes.append(.trailing)
        return self
    }
    var width: MUContraintExtendable {
        attributes.append(.width)
        return self
    }
    var height: MUContraintExtendable {
        attributes.append(.height)
        return self
    }
    var centerX: MUContraintExtendable {
        attributes.append(.centerX)
        return self
    }
    var centerY: MUContraintExtendable {
        attributes.append(.centerY)
        return self
    }
    var edges: MUContraintExtendable {
        attributes.append(contentsOf: [.top, .left, .bottom, .right])
        return self
    }
    var center: MUContraintExtendable {
        attributes.append(contentsOf: [.centerX, .centerY])
        return self
    }
    
    func equalTo(_ target: MUContraintable) -> MUContraintRelation {
        return self
    }
    
    func equalToSuperview() -> MUContraintRelation {
        return self
    }
    
    func lessThanOrEqualTo(_ target: MUContraintable) -> MUContraintRelation {
        return self
    }
    
    func greaterThanOrEqualTo(_ target: MUContraintable) -> MUContraintRelation {
        return self
    }
    
    func offset(_ constant: MUContraintConstant) {
        
    }
}
