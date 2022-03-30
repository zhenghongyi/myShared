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
    var responseMap:[URLRequest:WantResponse] = [:]
    
    func send(request: URLRequest, completion: @escaping RequestCallBack) {
        if let response = responseMap[request] {
            DispatchQueue.global().asyncAfter(deadline: .now() + response.delay) {
                completion(response.result)
            }
        } else {
            completion(.failure(RequestError.noResponse))
        }
    }
}

class AuthHelper: AuthProtocol {
    func isSessionValidate(result: Result<Any, Error>) -> Bool {
        return true
    }
    
    func authorize(completion: @escaping RequestCallBack) {
        
    }
}
