//
//  AuthViewModelProtocols.swift
//  doroga
//
//  Created by Bucha Kanstantsin on 7/3/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import Foundation
import FeathersjsClientSwift

typealias AuthError = FeathersError

enum SubmitStatus {
    case steady
    case ready
    case go
    case processing
    case succeesed
}

protocol AuthLogicProtocol: class {
    var viewDelegate: AuthLogic_ViewProtocol? { get set }
    var coordinatorDelegate: AuthLogic_CoordinatorProtocol? { get set}
    var model: AuthLogic_ModelProtocol? { get set }
    
    // Email and Password
    var email: String {get set}
    var password: String {get set}
    
    // Submit
    var submitStatus: SubmitStatus { get }
    
    func submit()
    func signUp()
    
    // Errors
    var errorMessage: String { get }
}

protocol AuthLogic_ViewProtocol: class {
    var authLogic: AuthLogicProtocol? {get set}
    
    func submitStatusDidChange(_ logic: AuthLogicProtocol, status: SubmitStatus)
    func errorMessageDidChange(_ logic: AuthLogicProtocol, message: String)
}

protocol AuthLogic_CoordinatorProtocol: class {
    func authLogicDidLogin(_ logic: AuthLogicProtocol,
                           profileAuth: UserAuthProtocol,
                           userID: Int)
    func authLogicDidSignUp(_ logic: AuthLogicProtocol,
                            profileAuth: UserAuthProtocol,
                            userID: Int)
}

protocol AuthLogic_ModelProtocol: class {
    func authorize(auth: UserAuthProtocol,
                   completion: @escaping (_ error: AuthError?, _ userID: Int?) ->())
    func signUp(auth: UserAuthProtocol,
                completion: @escaping (_ error: AuthError?, _ userID: Int?) ->())
}



