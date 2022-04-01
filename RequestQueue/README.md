# RequestQueue

用来管理请求队列，并利用GCD barrier实现过期重登并重发请求

```
class RequestHelper: RequestProtocol {
    func send(request: URLRequest, completion: @escaping RequestCallBack) {
		// completion回调
    }
}

class AuthHelper: AuthProtocol {
    func isSessionValidate(result: Result<Any, Error>) -> Bool {
        return true
    }
    
    func authorize(completion: @escaping RequestCallBack) {
        // completion回调
    }
}


let requestHP:RequestHelper = RequestHelper()
let authHP:AuthHelper = AuthHelper()
let requestQueue: RequestQueue = RequestQueue(authHelper: authHP, requestHelper: requestHP)
let request = URLRequest(url: URL(string: "https://baidu.com")!)
let wrapper = RequestWrapper(request: request) { result in
     // ...
}
requestQueue.enqueue(wrapper)
```