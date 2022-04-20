//
//  DataBaseProtocol.swift
//  CustomDBProtocol
//
//  Created by zhenghongyi on 2022/4/19.
//

import Foundation

// 字段名包裹结构
struct Column {
    let name:String
    init(_ name:String) {
        self.name = name
    }
}

indirect enum SQLCondition {
    case condition(column:String, action:QueryAction, value:Any?)
    case expression(left:SQLCondition, action:QueryAction, right:SQLCondition)
    
    var SQLStr:String {
        switch self {
        case .condition(let column, let action, let value):
            return "\(column) \(action.description) \(value ?? "Null")"
        case .expression(let left, let action, let right):
            return "(\(left.SQLStr) \(action.description) \(right.SQLStr))"
        }
    }
}

// 查询相关操作
enum QueryAction: CustomStringConvertible {
    case equal
    case notEqual
    case moreThan
    case moreOrEqual
    case lessThan
    case lessOrEqual
    case contain
    case and
    case or
    // 待处理
    case orderBy
    case limit(count:Int)
    
    var description: String {
        switch self {
        case .equal:
            return "=="
        case .notEqual:
            return "!="
        case .moreThan:
            return ">"
        case .moreOrEqual:
            return ">="
        case .lessThan:
            return "<"
        case .lessOrEqual:
            return "<="
        case .contain:
            return "Contain"
        case .and:
            return "&&"
        case .or:
            return "||"
        default:
            return "unknow"
        }
    }
}

/// 字段值查询操作
/// 相等
func ==(column:Column, value:Any?) -> SQLCondition {
    return SQLCondition.condition(column: column.name, action: .equal, value: value)
}

/// 小于
func <(column: Column, value: Any?) -> SQLCondition {
    return SQLCondition.condition(column: column.name, action: .lessThan, value: value)
}

/// 小于或等于
func <=(column: Column, value: Any?) -> SQLCondition {
    return SQLCondition.condition(column: column.name, action: .lessOrEqual, value: value)
}

/// 大于
func >(column: Column, value: Any?) -> SQLCondition {
    return SQLCondition.condition(column: column.name, action: .moreThan, value: value)
}

/// 大于或等于
func >=(column: Column, value: Any?) -> SQLCondition {
    return SQLCondition.condition(column: column.name, action: .moreOrEqual, value: value)
}

/// 不等于
func !=(column: Column, value: Any?) -> SQLCondition {
    return SQLCondition.condition(column: column.name, action: .notEqual, value: value)
}

/// 条件表达式间联合操作
/// 与
func &&(left:SQLCondition, right:SQLCondition) -> SQLCondition {
    return SQLCondition.expression(left: left, action: .and, right: right)
}

/// 或
func ||(left:SQLCondition, right:SQLCondition) -> SQLCondition {
    return SQLCondition.expression(left: left, action: .or, right: right)
}

protocol DataBaseTable {}

protocol DataBaseProtocol {
    func setup() throws // 创建数据库连接,创建表,处理表的新增列
    func insert<T>(in table:DataBaseTable, datas:[T]) throws // 创建新表,并插入数据
    
    // SELECT * FROM table_name WHERE [condition];
    func query<T>(in table:DataBaseTable, condition:SQLCondition?) throws -> [T]

    // UPDATE table_name SET column1 = value1, column2 = value2...., columnN = valueN WHERE [condition];
    func update(in table:DataBaseTable, values:[(String, Any?)], condition:SQLCondition?) throws
    
    // DELETE FROM table_name WHERE [condition];
    func delete(in table:DataBaseTable, condition:SQLCondition) throws
}
