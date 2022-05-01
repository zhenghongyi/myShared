//
//  File.swift
//  
//
//  Created by 郑洪益 on 2022/4/27.
//

@testable import CommonDB

enum Gender:Int {
    case female = 0
    case male
}

struct User: DataBaseTable {
    let id:String
    let name:String
    let age:UInt
    let gender:Gender
}
