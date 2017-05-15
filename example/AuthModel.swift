//
//  AuthModel.swift
//  doroga
//
//  Created by truebucha on 8/17/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import Foundation
import FeathersjsClientSwift

class AuthModel {
    
    unowned let feathers: FeathersClient
    
    init(feathers: FeathersClient) {
        self.feathers = feathers
    }
}

extension AuthModel: AuthLogic_ModelProtocol {
    
    func authorize(auth: UserAuthProtocol,
                   completion: @escaping (_ error: AuthError?, _ userID: Int?) ->()) {
        do { try feathers.authorize(auth) { [unowned self] (response) in
                self.handleResponse(response, completion: completion)
            }
        } catch {
            completion(error as? AuthError, nil)
        }
        
    }
    
    func signUp(auth: UserAuthProtocol,
                completion: @escaping (_ error: AuthError?, _ userID: Int?) ->()) {
        var object = auth.requestObject()
        object["role"] = "user"
        
        let emitter = Emitter(feathers: feathers,
                              event: "users::create",
                              authRequired: false)
        do { try emitter.emitWithAck(object) {  [unowned self] (response) in
            let error = response.extractError()
            guard error == nil else {
                completion(error, nil)
                return
            }
                self.authorize(auth: auth, completion: completion)
            }
        } catch {
            completion(error as? AuthError, nil)
        }
    }
    
    func handleResponse(_ response: FeathersResponse,
                completion: @escaping (_ error: AuthError?, _ userID: Int?) ->()) {
        let error = response.extractError()
        guard error == nil else {
            completion(error, nil)
            return
        }
        
        let object = response.extractDataObject()
        let ID = object?["id"]
        let userID = ID as? Int
        
        guard userID != nil else {
            let reason = NSLocalizedString("INVALID_USER_ID", comment: "")
            completion(FeathersError.authError(reason:reason), nil)
            return
        }
        
        completion(nil, userID)
    }
}
