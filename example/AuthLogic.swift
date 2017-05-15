//
//  AuthViewModel.swift
//  doroga
//
//  Created by Bucha Kanstantsin on 7/3/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import Foundation
import FeathersjsClientSwift

class AuthLogic: AuthLogicProtocol {

    weak var viewDelegate: AuthLogic_ViewProtocol?
    weak var coordinatorDelegate: AuthLogic_CoordinatorProtocol?
    var model: AuthLogic_ModelProtocol?
    
    var submitStatus: SubmitStatus = .steady {
        didSet {
            if oldValue != submitStatus {
                viewDelegate?.submitStatusDidChange(self,
                                                    status: submitStatus)
            }
            if submitStatus == .go {
                errorMessage = ""
            }
        }
    }
    
    /// Email
    private var emailIsValidFormat: Bool = false
    var email: String = "" {
        didSet {
            email = email.lowercased()
            if oldValue != email {
                emailIsValidFormat = UserAuth.validateEmailFormat(email)
                if emailIsValidFormat == false {
                    errorMessage = "Please Enter Your Email Address"
                }
                submitStatus = generateSubmitStatus(emailIsValidFormat: emailIsValidFormat,
                                                    passwordIsValidFormat: passwordIsValidFormat)
            }
        }
    }
    
    /// Password
    private var passwordIsValidFormat: Bool = false
    var password: String = "" {
        didSet {
            if oldValue != password {
                passwordIsValidFormat = UserAuth.validatePasswordFormat(password)
                if passwordIsValidFormat == false {
                   errorMessage = "Password Should Be At Least 5 Characters In Length"
                }
                
                submitStatus = generateSubmitStatus(emailIsValidFormat: emailIsValidFormat,
                                                    passwordIsValidFormat: passwordIsValidFormat)
            }
        }
    }
    
    
    
    /// Errors
    private(set) var errorMessage: String = "" {
        didSet {
            if oldValue != errorMessage {
                viewDelegate?.errorMessageDidChange(self, message: errorMessage)
            }
        }
    }
    
    func generateSubmitStatus(emailIsValidFormat: Bool,
                              passwordIsValidFormat: Bool) -> SubmitStatus {
        if emailIsValidFormat && passwordIsValidFormat {
            return .go
        }
        
        if emailIsValidFormat || passwordIsValidFormat {
            return .ready
        }
        
        return .steady
    }
    
    func submit() {
    
        let userAuth = UserAuth(email: email, password: password)
        
        guard model != nil, submitStatus == .go, userAuth != nil else {
            errorMessage = NSLocalizedString("NOT_READY_TO_SUBMIT", comment: "")
            return
        }
        
        submitStatus = .processing
        model!.authorize(auth: userAuth!) { [unowned self] (error, userID) in
            guard error == nil, userID != nil else {
                let message = error?.reason()
                self.submitStatus = self.generateSubmitStatus(emailIsValidFormat: self.emailIsValidFormat,
                                                              passwordIsValidFormat: self.passwordIsValidFormat)
                
                self.errorMessage = message ?? ""
                return
            }
            
            self.errorMessage = ""
            self.submitStatus = .succeesed
            self.coordinatorDelegate?.authLogicDidLogin(self,
                                                        profileAuth: userAuth!,
                                                        userID: userID!)
        }
    }
    
    func signUp() {
        let userAuth = UserAuth(email: email, password: password)
        
        guard model != nil, submitStatus == .go, userAuth != nil else {
            errorMessage = NSLocalizedString("NOT_READY_TO_SUBMIT", comment: "")
            return
        }
        
        submitStatus = .processing
        model!.signUp(auth: userAuth!) { [unowned self] (error, userID) in
            guard error == nil, userID != nil else {
                let message = error?.reason()
                self.submitStatus = self.generateSubmitStatus(emailIsValidFormat: self.emailIsValidFormat,
                                                              passwordIsValidFormat: self.passwordIsValidFormat)
                self.errorMessage = message ?? ""
                return
            }
            
            self.errorMessage = ""
            self.submitStatus = .succeesed
            self.coordinatorDelegate?.authLogicDidSignUp(self,
                                                         profileAuth: userAuth!,
                                                         userID: userID!)
        }

    }
}
