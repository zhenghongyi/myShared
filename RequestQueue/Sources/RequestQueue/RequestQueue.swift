import Foundation

typealias RequestCallBack = ((Result<Any,Error>) -> Void)

struct RequestWrapper {
    let request:URLRequest
    
    let resendEnable:Bool
    
    fileprivate var retryTime:Int = 1 // 仅一次重发机会
    
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
    
    let authLock:NSLock = NSLock()
    
    var isAuthing:Bool = false
    
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
        authLock.unlock()
        isAuthing = true
        queue.async(group: nil, qos: .default, flags: .barrier) {
            self.authHelper.authorize {[weak self] result in
                self?.isAuthing = false
            }
        }
    }
}
