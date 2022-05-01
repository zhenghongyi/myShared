import XCTest
@testable import CommonDB

final class CommonDBTests: XCTestCase {
    func testConditions() {
        var condition = (Column("id") == "10086")
        XCTAssertTrue(condition.SQLStr == "id == 10086")
        
        condition = (Column("id") == 10086)
        XCTAssertTrue(condition.SQLStr == "id == 10086")
        
        condition = (Column("age") <= 10)
        XCTAssertTrue(condition.SQLStr == "age <= 10")
        
        condition = (Column("age") < 25) && (Column("gender") == Gender.female.rawValue)
        XCTAssertTrue(condition.SQLStr == "age < 25 AND gender == 0")
        
        condition = (Column("gender") == Gender.female.rawValue) && ((Column("age") > 25) || (Column("age") < 10))
        XCTAssertTrue(condition.SQLStr == "gender == 0 AND (age > 25 OR age < 10)")
    }
}
