import Foundation

typealias RequestCallBack = ((Result<Any,Error>) -> Void)

struct RequestWrapper {
    let request:URLRequest
    
    let resendEnable:Bool
    
    fileprivate var retryTime:Int = 1 // 仅一次重发机会
    
//    fileprivate let uuid:String = UUID().uuidString
    
    fileprivate let completion:RequestCallBack
    
    init(request:URLRequest, needCache:Bool = true, completion:@escaping RequestCallBack) {
        self.request = request
        self.resendEnable = needCache
        self.completion = completion
    }
}

protocol RequestProtocol {
    func send(request:URLRequest, completion:@escaping RequestCallBack)
}

protocol AuthProtocol {
    func isSessionValidate(result:Result<Any, Error>) -> Bool
    func authorize(completion:@escaping RequestCallBack)
}

class RequestQueue {
    let queue = DispatchQueue(label: "ReqeustQueue", attributes: .concurrent)
    
//    let cacheLock:NSLock = NSLock()
    let authLock:NSLock = NSLock()
    
    var isAuthing:Bool = true
    
//    var caches:[RequestWrapper] = []
    
    let requestHelper:RequestProtocol
    let authHelper:AuthProtocol
    
    init(authHelper:AuthProtocol, requestHelper:RequestProtocol) {
        self.authHelper = authHelper
        self.requestHelper = requestHelper
    }
    
    func enqueue(_ wrapper:RequestWrapper) {
        queue.async {
            self.requestHelper.send(request: wrapper.request) {[weak self] result in
                let isValidate = self?.authHelper.isSessionValidate(result: result)
                if isValidate == true || wrapper.retryTime == 0 || wrapper.resendEnable == false {
                    wrapper.completion(result)
                } else {
                    var temp = wrapper
                    temp.retryTime = 0
                    self?.reAuthorize()
                    self?.enqueue(temp)
                }
            }
        }
    }
    
    func reAuthorize() {
        authLock.lock()
        if isAuthing == true {
            authLock.unlock()
            return
        }
        isAuthing = true
        queue.async(group: nil, qos: .default, flags: .barrier) {
            self.authHelper.authorize {[weak self] result in
                self?.isAuthing = false
            }
        }
    }
    
//    func enqueue(_ wrapper:RequestWrapper) {
//        if isAuthing == false {
//            requestHelper.send(request: wrapper.request) {[weak self] result in
//                let isValidate = self?.authHelper.isSessionValidate(result: result)
//                if isValidate == true {
//                    wrapper.completion(result)
//                } else {
//                    self?.reAuthorize()
//                }
//            }
//        }
//
//        cacheLock.lock()
//        caches.append(wrapper)
//        cacheLock.unlock()
//    }
//
//    func reAuthorize() {
//        authLock.lock()
//        if isAuthing == true {
//            authLock.unlock()
//            return
//        }
//
//        isAuthing = true
//        authHelper.authorize {[weak self] result in
//            self?.isAuthing = false
//            switch result {
//            case .success(_):
//                self?.handleCaches(error: nil)
//            case .failure(let error):
//                self?.handleCaches(error: error)
//            }
//        }
//    }
//
//    func handleCaches(error:Error?) {
//        cacheLock.lock()
//        let temp = caches
//        caches.removeAll()
//        if let error = error {
//            for item in temp {
//                item.completion(.failure(error))
//            }
//        } else {
//            for item in temp {
//                enqueue(item)
//            }
//        }
//        cacheLock.unlock()
//    }
}
