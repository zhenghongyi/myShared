//
//  MUCSource.swift
//  MailUI
//
//  Created by hyzheng on 2023/4/25.
//
/// 约束的原始来源对象

import UIKit

protocol MUConstraintSource {
    var constraints: [NSLayoutConstraint] { get }
    var translatesAutoresizingMaskIntoConstraints:Bool { get set }
    func removeConstraints(_ constraints:[NSLayoutConstraint])
}

extension MUConstraintSource where Self: Equatable {
    func isEqualTo(_ other: MUConstraintSource) -> Bool {
        guard let o = other as? Self else { return false }
        return self == o
    }
}

typealias MUCSource = MUConstraintSource & Equatable

extension UIView: MUConstraintSource {}
extension UILayoutGuide: MUConstraintSource {
    var constraints: [NSLayoutConstraint] {
        return owningView?.constraints ?? []
    }
    
    var translatesAutoresizingMaskIntoConstraints: Bool {
        get {
            return owningView?.translatesAutoresizingMaskIntoConstraints ?? false
        }
        set(newValue) {
            owningView?.translatesAutoresizingMaskIntoConstraints = newValue
        }
    }
    
    func removeConstraints(_ constraints: [NSLayoutConstraint]) {
        owningView?.removeConstraints(constraints)
    }
}
