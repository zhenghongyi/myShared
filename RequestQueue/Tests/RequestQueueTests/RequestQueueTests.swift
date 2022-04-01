import XCTest
@testable import RequestQueue

final class RequestQueueTests: XCTestCase {
    var requestQueue:RequestQueue?
    let requestHP:RequestHelper = RequestHelper()
    let authHP:AuthHelper = AuthHelper()
    
    override func setUp() {
        super.setUp()
        
        requestQueue = RequestQueue(authHelper: authHP, requestHelper: requestHP)
    }
    
    func testSimple() {
        requestHP.responseMap = [
            "https://baidu.com":["code":"S_OK"],
        ]
        
        let request = URLRequest(url: URL(string: "https://baidu.com")!)
        let exp:XCTestExpectation? = expectation(description: "1")
        let wrapper = RequestWrapper(request: request) { result in
            exp?.fulfill()
            XCTAssertTrue(result.isEqualToDic(["code":"S_OK"]))
        }
        requestQueue?.enqueue(wrapper)
        
        waitForExpectations(timeout: 60, handler: { error in
            XCTAssertNil(error, "Oh, we got timeout")
        })
    }
    
    func testMulti() {
        requestHP.responseMap = [
            "https://baidu.com":["code":"S_OK"],
            "https://google.com":["code":"S_OK", "uid":"123"],
        ]
        
        let request1 = URLRequest(url: URL(string: "https://baidu.com")!)
        let exp1:XCTestExpectation? = expectation(description: "1")
        let wrapper1 = RequestWrapper(request: request1) { result in
            exp1?.fulfill()
            XCTAssertTrue(result.isEqualToDic(["code":"S_OK"]))
        }
        
        let request2 = URLRequest(url: URL(string: "https://google.com")!)
        let exp2:XCTestExpectation? = expectation(description: "1")
        let wrapper2 = RequestWrapper(request: request2) { result in
            exp2?.fulfill()
            XCTAssertTrue(result.isEqualToDic(["code":"S_OK", "sid":"123456"]))
        }
        
        requestQueue?.enqueue(wrapper1)
        requestQueue?.enqueue(wrapper2)
        
        waitForExpectations(timeout: 60, handler: { error in
            XCTAssertNil(error, "Oh, we got timeout")
        })
    }
    
    func testInvalidate() {
        requestHP.responseMap = [
            "https://baidu.com":["code":"FA_INVALIDATE"],
        ]
        
        let request = URLRequest(url: URL(string: "https://baidu.com")!)
        authHP.stateChange = {[weak self] in
            self?.requestHP.responseMap = [
                "https://baidu.com":["code":"S_OK"],
            ]
        }
        
        let exp:XCTestExpectation? = expectation(description: "1")
        let wrapper = RequestWrapper(request: request) { result in
            exp?.fulfill()
            XCTAssertTrue(result.isEqualToDic(["code":"S_OK"]))
        }
        requestQueue?.enqueue(wrapper)
        
        waitForExpectations(timeout: 60, handler: { error in
            XCTAssertNil(error, "Oh, we got timeout")
        })
    }
    
    func testInvalidateFirst() {
        requestHP.responseMap = [
            "https://baidu.com":["code":"FA_INVALIDATE"],
            "https://google.com":["code":"S_OK", "uid":"123"],
            "https://network.com":["code":"S_OK", "uid":"123", "date":"2020-01-01"]
        ]
        
        authHP.stateChange = {[weak self] in
            self?.requestHP.responseMap = [
                "https://baidu.com":["code":"S_OK"],
                "https://google.com":["code":"S_OK", "uid":"123"],
                "https://network.com":["code":"S_OK", "uid":"123", "date":"2020-01-01"]
            ]
        }
        
        let request = URLRequest(url: URL(string: "https://baidu.com")!)
        let exp:XCTestExpectation? = expectation(description: "1")
        let wrapper = RequestWrapper(request: request) { result in
            exp?.fulfill()
            XCTAssertTrue(result.isEqualToDic(["code":"S_OK"]))
        }
        requestQueue?.enqueue(wrapper)
        
        let request1 = URLRequest(url: URL(string: "https://google.com")!)
        let exp1:XCTestExpectation? = expectation(description: "1")
        let wrapper1 = RequestWrapper(request: request1) { result in
            exp1?.fulfill()
            XCTAssertTrue(result.isEqualToDic(["code":"S_OK"]))
        }

        let request2 = URLRequest(url: URL(string: "https://network.com")!)
        let exp2:XCTestExpectation? = expectation(description: "1")
        let wrapper2 = RequestWrapper(request: request2) { result in
            exp2?.fulfill()
            XCTAssertTrue(result.isEqualToDic(["code":"S_OK", "sid":"123456"]))
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + 4) {
            self.requestQueue?.enqueue(wrapper1)
            self.requestQueue?.enqueue(wrapper2)
        }
        
        waitForExpectations(timeout: 60, handler: { error in
            XCTAssertNil(error, "Oh, we got timeout")
        })
    }
    
    func testTwoInvalidateFirst() {
        requestHP.responseMap = [
            "https://baidu.com":["code":"FA_INVALIDATE"],
            "https://google.com":["code":"FA_INVALIDATE"],
            "https://network.com":["code":"S_OK", "uid":"123", "date":"2020-01-01"]
        ]
        
        authHP.stateChange = {[weak self] in
            self?.requestHP.responseMap = [
                "https://baidu.com":["code":"S_OK"],
                "https://google.com":["code":"S_OK", "uid":"123"],
                "https://network.com":["code":"S_OK", "uid":"123", "date":"2020-01-01"]
            ]
        }
        
        let request = URLRequest(url: URL(string: "https://baidu.com")!)
        let exp:XCTestExpectation? = expectation(description: "1")
        let wrapper = RequestWrapper(request: request) { result in
            exp?.fulfill()
            XCTAssertTrue(result.isEqualToDic(["code":"S_OK"]))
        }
        requestQueue?.enqueue(wrapper)
        
        let request1 = URLRequest(url: URL(string: "https://google.com")!)
        let exp1:XCTestExpectation? = expectation(description: "1")
        let wrapper1 = RequestWrapper(request: request1) { result in
            exp1?.fulfill()
            XCTAssertTrue(result.isEqualToDic(["code":"S_OK"]))
        }
        self.requestQueue?.enqueue(wrapper1)

        let request2 = URLRequest(url: URL(string: "https://network.com")!)
        let exp2:XCTestExpectation? = expectation(description: "1")
        let wrapper2 = RequestWrapper(request: request2) { result in
            exp2?.fulfill()
            XCTAssertTrue(result.isEqualToDic(["code":"S_OK", "sid":"123456"]))
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + 4) {
            self.requestQueue?.enqueue(wrapper2)
        }
        
        waitForExpectations(timeout: 60, handler: { error in
            XCTAssertNil(error, "Oh, we got timeout")
        })
    }
}
