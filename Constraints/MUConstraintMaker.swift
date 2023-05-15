//
//  MUConstraintMaker.swift
//  MailUI
//
//  Created by hyzheng on 2023/4/25.
//

import UIKit

class MUConstraintMaker: MUContraintExtendable {
    var source:any MUCSource
    
    var constraints:[MUConstraint] = []
    
    init(source: any MUCSource) {
        self.source = source
    }
    
    private var constraintItem:MUConstraintItem {
        if let item = constraintItem_ {
            return item
        }
        let item = MUConstraintItem(source: self.source)
        constraintItem_ = item
        return item
    }
    private var constraintItem_:MUConstraintItem?
    
    var left: MUContraintExtendable {
        _ = constraintItem.left
        return self
    }
    var top: MUContraintExtendable {
        _ = constraintItem.top
        return self
    }
    var right: MUContraintExtendable {
        _ = constraintItem.right
        return self
    }
    var bottom: MUContraintExtendable {
        _ = constraintItem.bottom
        return self
    }
    var leading: MUContraintExtendable {
        _ = constraintItem.leading
        return self
    }
    var trailing: MUContraintExtendable {
        _ = constraintItem.trailing
        return self
    }
    var width: MUContraintExtendable {
        _ = constraintItem.width
        return self
    }
    var height: MUContraintExtendable {
        _ = constraintItem.height
        return self
    }
    var centerX: MUContraintExtendable {
        _ = constraintItem.centerX
        return self
    }
    var centerY: MUContraintExtendable {
        _ = constraintItem.centerY
        return self
    }
    var edges: MUContraintExtendable {
        _ = constraintItem.edges
        return self
    }
    var center: MUContraintExtendable {
        _ = constraintItem.center
        return self
    }
    
    @discardableResult
    func equalTo(_ target: MUContraintable) -> MUContraintRelation {
        addConstraint(target: target, relation: .equal)
        return self
    }
    
    @discardableResult
    func equalToSuperview() -> MUContraintRelation {
        guard let view = source as? UIView, let superview = view.superview else {
            fatalError("Expected superview but found nil when attempting make constraint `equalToSuperview`.")
        }
        return equalTo(superview)
    }
    
    @discardableResult
    func lessThanOrEqualTo(_ target: MUContraintable) -> MUContraintRelation {
        addConstraint(target: target, relation: .lessThanOrEqual)
        return self
    }
    
    @discardableResult
    func greaterThanOrEqualTo(_ target: MUContraintable) -> MUContraintRelation {
        addConstraint(target: target, relation: .greaterThanOrEqual)
        return self
    }
    
    func offset(_ constant: MUContraintConstant) {
        guard var lastCon = constraints.last else { return }
        lastCon.constant = constant.float
        constraints[constraints.count - 1] = lastCon
    }
    
    private func addConstraint(target:MUContraintable?, relation:NSLayoutConstraint.Relation) {
        var constraint = MUConstraint()
        constraint.source = constraintItem
        if let item = target as? MUConstraintMaker {
            constraint.target = item.constraintItem
            constraint.relation = relation
            constraint.multiplier = 1
            constraint.constant = 0
        } else if let view = target as? UIView {
            let item = MUConstraintItem(source: view)
            item.attributes = constraintItem.attributes
            constraint.target = item
            constraint.relation = relation
            constraint.multiplier = 1
            constraint.constant = 0
        } else if let constantInt = target as? Int {
            constraint.relation = relation
            constraint.constant = CGFloat(constantInt)
        } else if let constantDouble = target as? Double {
            constraint.relation = relation
            constraint.constant = CGFloat(constantDouble)
        } else if let constantCGFloat = target as? CGFloat {
            constraint.relation = relation
            constraint.constant = CGFloat(constantCGFloat)
        } else {// 其他的一律以constant = 0处理
            constraint.relation = .equal
            constraint.multiplier = 0
            constraint.constant = 0
        }
        constraints.append(constraint)
        constraintItem_ = nil
    }
    
    private func addLayoutConstraintsToSource() {
        var layoutConstraints:[NSLayoutConstraint] = []
        for constraint in constraints {
            guard let source = constraint.source else { continue }
            if let target = constraint.target as? MUConstraintItem {
                
                var i:Int = 0
                for att in source.attributes {
                    layoutConstraints.append(NSLayoutConstraint(item: source.source,
                                                                attribute: att,
                                                                relatedBy: constraint.relation,
                                                                toItem: target.source,
                                                                attribute: target.attributes[i],
                                                                multiplier: constraint.multiplier,
                                                                constant: constraint.constant))
                    if i < target.attributes.count - 1 {
                        i += 1
                    }
                }
                NSLayoutConstraint.activate(layoutConstraints)
                layoutConstraints.removeAll() // 添加完就要做一次清理
            } else {
                for att in source.attributes {
                    layoutConstraints.append(NSLayoutConstraint(item: source.source,
                                                                attribute: att,
                                                                relatedBy: constraint.relation,
                                                                toItem: nil,
                                                                attribute: .notAnAttribute,
                                                                multiplier: 0,
                                                                constant: constraint.constant))
                }
                NSLayoutConstraint.activate(layoutConstraints)
                layoutConstraints.removeAll() // 添加完就要做一次清理
            }
        }
    }
    
    func makeConstraints(_ closure:(_ make:MUConstraintMaker) -> Void) {
        source.translatesAutoresizingMaskIntoConstraints = false
        closure(self)
        addLayoutConstraintsToSource()
    }
    
    func remakeConstraints(_ closure:(_ make:MUConstraintMaker) -> Void) {
        if let owningView = source as? UIView, let superView = owningView.superview {
            var existsConstraints:[NSLayoutConstraint] = source.constraints
            var nextView:UIView? = superView
            while nextView != nil {
                let nextCs = nextView?.constraints.filter({ c in
                    return (c.firstItem as? UIView) == owningView || (c.secondItem as? UIView) == owningView
                }) ?? []
                existsConstraints.append(contentsOf: nextCs)
                nextView = nextView?.superview
            }
            let index = superView.subviews.firstIndex(where: { $0 == owningView }) ?? 0
            owningView.removeFromSuperview()
            superView.insertSubview(owningView, at: index)
            
            DispatchQueue.main.async {
                NSLayoutConstraint.activate(existsConstraints)
            }
        }
        
        // 剔除自适应宽高类型的约束
        let maualConstraints = source.constraints.filter({ $0.isMember(of: NSLayoutConstraint.self) == true })
        source.removeConstraints(maualConstraints)
        makeConstraints(closure)
    }
    
    func updateConstraints(_ closure:(_ make:MUConstraintMaker) -> Void) {
        closure(self)
        for constraint in constraints {
            guard let source = constraint.source else { continue }
            if let target = constraint.target as? MUConstraintItem {
                var i:Int = 0
                // 3层遍历，待优化
                for att in source.attributes {
                    _ = target.source.constraints.filter { c in
                        if let firstItem = c.firstItem as? (any MUCSource), let secondItem = c.secondItem as? (any MUCSource),
                           firstItem.isEqualTo(source.source), secondItem.isEqualTo(target.source), c.firstAttribute == att, c.secondAttribute == target.attributes[i],
                            c.relation == constraint.relation {
                            c.constant = constraint.constant
                            return true
                        }
                        return false
                    }
                    if i < target.attributes.count - 1 {
                        i += 1
                    }
                }
            } else {
                for att in source.attributes {
                    _ = source.source.constraints.filter { c in
                        if let firstItem = c.firstItem as? (any MUCSource), firstItem.isEqualTo(source.source), c.firstAttribute == att,
                           c.secondItem == nil, c.secondAttribute == .notAnAttribute, c.relation == constraint.relation {
                            c.constant = constraint.constant
                        }
                        return false
                    }
                }
            }
        }
    }
}

struct MUConstraint {
    var source:MUConstraintItem?
    var target:MUContraintable?
    var relation:NSLayoutConstraint.Relation = .equal
    var multiplier:CGFloat = 0
    var constant:CGFloat = 0
}

extension UIView {
    var muc:MUConstraintMaker {
        return MUConstraintMaker(source: self)
    }
}

extension UILayoutGuide {
    var muc:MUConstraintMaker {
        return MUConstraintMaker(source: self)
    }
}
