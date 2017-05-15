//
//  AuthModel.swift
//  doroga
//
//  Created by Bucha Kanstantsin on 7/3/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import Foundation

class AuthModelStub {
    var validEmails = ["truebucha@gmail.com", "paliakoff@gmail.com", "volkovsa@tut.by"]
    var validPassword = "test1"
}

extension AuthModelStub: AuthLogic_ModelProtocol {

    internal func signUp(auth: ProfileAuthProtocol, completion: @escaping (AuthError?, Int?) -> ()) {
        completion(nil, 1)
    }


    func authorize(auth: ProfileAuthProtocol,
                   completion: @escaping (_ error: AuthError?, _ userID: Int?) ->()) {
        
        let emailValid = isValidEmail(auth.email)
        guard emailValid else {
            let error = AuthError.authError(reason: "Invalid Email Or Password")
            completion(error, nil)
            return
        }
        
        completion(nil, 1)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        for validEmail in validEmails {
            if (email == validEmail) {
                return true
            }
        }
        return false
    }
}
