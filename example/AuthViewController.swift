//
//  AuthViewController.swift
//  doroga
//
//  Created by Bucha Kanstantsin on 7/3/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import UIKit
import SVProgressHUD


class AuthViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var authLogic: AuthLogicProtocol? {
        willSet {
            authLogic?.viewDelegate = nil
        }
        didSet {
            authLogic?.viewDelegate = self
            refreshDisplay()
        }
    }
    
    private var isLoaded: Bool = false
    
    override func viewDidLoad() {
        title = "Login"
        isLoaded = true;
        
        loginButton.isEnabled = false
        signUpButton.isEnabled = false
        loginButton.isHighlighted = false
        signUpButton.isHighlighted = false
        
        errorMessageLabel.text = authLogic?.errorMessage
    
        emailField.addTarget(self,
                             action: #selector(emailFieldDidChange(_:)),
                             for: UIControlEvents.editingChanged)
        emailField.delegate = self
        passwordField.addTarget(self,
                                action: #selector(passwordFieldDidChange(_:)),
                                for: UIControlEvents.editingChanged)
        passwordField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
            self?.refreshDisplay()
        #if (DEBUG)
            self?.authLogic?.email = "truebucha@gmail.com"
            self?.authLogic?.password = "bucha"
        #endif
        
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SVProgressHUD.dismiss()
    }
    
    func refreshDisplay() {
        guard isLoaded else { return }
        UIView.animate(withDuration: 0.7, animations: {
            self.refreshFields()
            self.view.layoutIfNeeded()
        })
    }
    
    private func refreshFields() {
        if let authLogic = authLogic {
            emailField.text = authLogic.email
            passwordField.text = authLogic.password
            refreshButtons(usingSubmitStatus: authLogic.submitStatus)
        } else {
            emailField.text = ""
            passwordField.text = ""
            refreshButtons(usingSubmitStatus: .steady)
        }
    }
    
    func refreshButtons(usingSubmitStatus status: SubmitStatus) {
        loginButton.isEnabled = false
        signUpButton.isEnabled = false
        SVProgressHUD.dismiss()
        
        switch status {
        case .steady:
            setButtonsTitleColor(UIColor.red)
        case .ready:
            setButtonsTitleColor(UIColor.yellow)
        case .go:
            setButtonsTitleColor(UIColor.green)
            loginButton.isEnabled = true
            signUpButton.isEnabled = true
        case .processing:
            SVProgressHUD.show()
        case .succeesed:
            SVProgressHUD.dismiss()
        }
    }
    
    func setButtonsTitleColor(_ color: UIColor) {
        loginButton.setTitleColor(color,
                                  for: UIControlState.normal)
        signUpButton.setTitleColor(color,
                                   for: UIControlState.normal)

    }
    
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        guard loginButton.isEnabled else { return }
        authLogic?.submit()
    }
    
    @IBAction func signUpButtonPressed(_ sender: AnyObject) {
        guard signUpButton.isEnabled else { return }
        authLogic?.signUp()
    }
    
    func emailFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            authLogic?.email = text
        }
    }
    
    func passwordFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            authLogic?.password = text
        }
    }
}

extension AuthViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        if textField == passwordField {
            loginButton.sendActions(for: .touchUpInside)
        }
        return true
    }
}

extension AuthViewController: AuthLogic_ViewProtocol {

    func submitStatusDidChange(_ logic: AuthLogicProtocol, status: SubmitStatus) {
        refreshDisplay()
    }
    
    func errorMessageDidChange(_ logic: AuthLogicProtocol, message: String) {
        errorMessageLabel.text = authLogic?.errorMessage
    }
}
