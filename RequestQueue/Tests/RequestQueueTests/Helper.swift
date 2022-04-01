//
//  File.swift
//
//
//  Created by lunkr on 2022/3/30.
//

import Foundation
@testable import RequestQueue

struct WantResponse {
    let delay:TimeInterval
    let result:Result<Any,Error>
}

enum RequestError: Error {
    case noResponse
}

class RequestHelper: RequestProtocol {
    var responseMap:[String:[String:String]] = [:]
    
    func send(request: URLRequest, completion: @escaping RequestCallBack) {
        if let url = request.url?.absoluteString, let response = responseMap[url] {
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                completion(.success(response))
            }
        } else {
            completion(.failure(RequestError.noResponse))
        }
    }
}

class AuthHelper: AuthProtocol {
    
    var isAuthing:Bool = false {
        didSet {
            stateChange?()
        }
    }
    
    var stateChange:(() -> Void)?
    
    func isSessionValidate(result: Result<Any, Error>) -> Bool {
        if case .success(let data) = result {
            if let dic = data as? [String:String], dic["code"] == "FA_INVALIDATE" {
                return false
            }
        }
        return true
    }
    
    func authorize(completion: @escaping RequestCallBack) {
        print(#function)
        isAuthing = true
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            self.isAuthing = false
            completion(.success(["code":"S_OK", "sid":"0987654321"]))
        }
    }
}

extension Result where Success:Any {
    func isEqualToDic(_ dic:[String:String]) -> Bool {
        guard case .success(let any) = self else {
            return false
        }
        guard let dic = any as? [String:String], dic.count == dic.count else {
            return false
        }
        
        for (key, value) in dic {
            if value != dic[key] {
                return false
            }
        }
        return true
    }
}
