//
//  File.swift
//  
//
//  Created by zhenghongyi on 2021/2/26.
//

import Foundation

typealias QueryBlock = (Result<[[String:Any]], Error>) -> Void

class XmlReader: NSObject, XMLParserDelegate {
    static let kXMLTextNodeKey = "text"
    
    let parser:XMLParser
    
    var dictStack:[[String:Any]] = []
    
    var result:[[String:Any]] = []
    var parseErr:Error?
    
    var queryBlock:QueryBlock?
    
    enum ParseState {
        case unParsed
        case parsing
        case parsed
    }
    var state:ParseState = .unParsed
    
    init(data:Data) {
        parser = XMLParser(data: data)
        super.init()
        parser.delegate = self
    }
    
    public func query(completion:@escaping QueryBlock) {
        if state == .parsed {
            if let error = parseErr {
                completion(.failure(error))
            } else {
                completion(.success(result))
            }
            return
        }
        
        if state == .unParsed {
            queryBlock = completion
            parser.parse()
            state = .parsing
        }
    }
    
    // MARK: - XMLParserDelegate
    func parserDidStartDocument(_ parser: XMLParser) {
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        /// 缓存新节点
        dictStack.append([elementName: attributeDict])
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard var lastDict = dictStack.last, let elementName = lastDict.nodeName, string.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else {
            return
        }
        guard var elementValue = lastDict[elementName] as? [String:Any] else {
            return
        }
        if elementValue.isEmpty {
            lastDict[elementName] = string
        } else {
            elementValue[XmlReader.kXMLTextNodeKey] = string
            lastDict[elementName] = elementValue
        }

        dictStack.updateLast(element: lastDict)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard let lastDict = dictStack.last, lastDict.nodeName == elementName else {
            return
        }

        dictStack.removeLast()
        /// 将当前已处理完毕节点的数据，塞进上一个未处理完毕的节点子级中（上一个未处理完毕的节点是父节点）
        if var parentDict = dictStack.last {
            if let key = parentDict.nodeName, var contentDict = parentDict[key] as? [String:Any] {
                if contentDict[elementName] == nil {
                    contentDict.merge(lastDict) { (current, new) -> Any in
                        return current
                    }
                } else {
                    let existed = contentDict[elementName]
                    var allValues:[Any] = []
                    if let temp = existed as? [String:Any] {
                        for (_, value) in temp {
                            allValues.append(value)
                        }
                        for (_, value) in lastDict {
                            allValues.append(value)
                        }
                    } else if let temp = existed as? [Any] {
                        allValues = temp
                        for (_, value) in lastDict {
                            allValues.append(value)
                        }
                    } else if let text = existed as? String {
                        allValues.append(text)
                        if let newValue = lastDict[elementName] {
                            allValues.append(newValue)
                        }
                    }
                    contentDict[elementName] = allValues
                }
                
                parentDict[key] = contentDict
            }

            dictStack.updateLast(element: parentDict)
        }

        if dictStack.count == 0 {
            result.append(lastDict)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        state = .parsed
        parseErr = parseError
        queryBlock?(.failure(parseError))
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        state = .parsed
        queryBlock?(.success(result))
    }
}

extension Array {
    mutating func updateLast(element:Element) {
        removeLast()
        append(element)
    }
}

extension Dictionary {
    var nodeName:String? {
        if count == 1 {
            return self.keys.first as? String
        }
        return nil
    }
}
