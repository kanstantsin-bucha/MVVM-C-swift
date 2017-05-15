//
//  AuthLogicTest.swift
//  doroga
//
//  Created by Bucha Kanstantsin on 7/9/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import XCTest
@testable import doroga


class AuthLogicTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//    
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    var currentExpectaion: XCTestExpectation?
    var expectedCanSubmit: Bool = false
    var expectedErrorMessage: String = ""
    
    
    func testInitialDefaults() {
        let auth = AuthLogic()
        XCTAssertEqual("", auth.email)
        XCTAssertEqual("", auth.password)
        XCTAssertFalse(auth.canSubmit)
        XCTAssertEqual("", auth.errorMessage)
        XCTAssertNil(auth.viewDelegate)
        XCTAssertNil(auth.model)
        XCTAssertNil(auth.coordinatorDelegate)
    }
    
    func testEmail() {
        let auth = AuthLogic()
        auth.email = "test@example.com"
        XCTAssertEqual("test@example.com", auth.email)
    }
    
    func testPassword() {
        let auth = AuthLogic()
        auth.password = "password"
        XCTAssertEqual("password", auth.password)
    }
    
    func testCanSubmit() {
        let auth = AuthLogic()
        XCTAssertFalse(auth.canSubmit)
        
        auth.email = "test@example.com"
        auth.password = ""
        XCTAssertFalse(auth.canSubmit)
        
        auth.email = ""
        auth.password = "password"
        XCTAssertFalse(auth.canSubmit)
        
        auth.email = "test@example.com"
        auth.password = "password"
        XCTAssert(auth.canSubmit)
    }
    
    func testErrorMessageDidChange() {
        let auth = AuthLogic()
        auth.viewDelegate = self
        
        currentExpectaion =  expectation(description: "testErrorMessageDidChange")
        expectedErrorMessage = NSLocalizedString("NOT_READY_TO_SUBMIT", comment: "")
        
        // Call submit with no model set on the viewModel should produce an error message
        auth.submit()
        
        waitForExpectations(withTimeout: 1) { error in
            auth.viewDelegate = nil
        }
    }
    
    func testCoordinatorDelegate() {
        let auth = AuthLogic()
        let modelStub = AuthModelStub()
        auth.model = modelStub
        
        auth.coordinatorDelegate = self
        currentExpectaion =  expectation(description: "testCoordinatorDelegate")
        
        auth.email = modelStub.validEmail
        auth.password = modelStub.validPassword
        
        auth.submit()
        
        waitForExpectations(withTimeout: 1) { error in
            auth.coordinatorDelegate = nil
        }
    }
}

extension AuthLogicTest: AuthLogic_ViewProtocol {

    func canSubmitStatusDidChange(_ logic: AuthLogicProtocol, status: Bool) {
        XCTAssertEqual(expectedCanSubmit, status)
        XCTAssertEqual(expectedCanSubmit, logic.canSubmit)
        currentExpectaion?.fulfill()
    }
    
    func errorMessageDidChange(_ logic: AuthLogicProtocol, message: String) {
        XCTAssertEqual(expectedErrorMessage, message)
        XCTAssertEqual(expectedErrorMessage, logic.errorMessage)
        currentExpectaion?.fulfill()
    }
}

extension AuthLogicTest: AuthLogic_CoordinatorProtocol {

    func authLogicDidLogin(_ logic: AuthLogicProtocol) {
        currentExpectaion?.fulfill()
    }
}
