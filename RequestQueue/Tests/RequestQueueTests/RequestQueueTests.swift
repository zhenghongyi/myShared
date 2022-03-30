import XCTest
@testable import RequestQueue

enum TestError: Error {
    case url
    case result
}

final class RequestQueueTests: XCTestCase {
    var requestQueue:RequestQueue?
    let requestHP:RequestHelper = RequestHelper()
    let authHP:AuthHelper = AuthHelper()
    
    override func setUp() {
        super.setUp()
        
        requestQueue = RequestQueue(authHelper: authHP, requestHelper: requestHP)
    }
    
    func testSimple() throws {
        guard let url = URL(string: "https://baidu.com") else {
            throw TestError.url
        }
        let request = URLRequest(url: url)
        let wantResult:Result<Any,Error> = .success(["code":"S_OK"])
        let reponse = WantResponse(delay: 10, result: wantResult)
        requestHP.responseMap[request] = reponse
        
        let exp:XCTestExpectation? = expectation(description: "1")
        let wrapper = RequestWrapper(request: request) { result in
            exp?.fulfill()
            
            XCTAssertTrue(RequestQueueTests.isResultEqual(result: result, success: ["code":"S_OK"]))
        }
        requestQueue?.enqueue(wrapper)
        
        waitForExpectations(timeout: 60, handler: { error in
            XCTAssertNil(error, "Oh, we got timeout")
        })
    }
    
    static func isResultEqual(result:Result<Any,Error>, success:[String:String]) -> Bool {
        guard case .success(let any) = result else {
            return false
        }
        guard let dic = any as? [String:String], dic.count == success.count else {
            return false
        }
        
        for (key, value) in dic {
            if value != success[key] {
                return false
            }
        }
        return true
    }
}
