//
//  Authentication.swift
//  FeedbinKit
//
//  Created by Bill Williams on 11/12/14.
//  Copyright (c) 2014 Velos Mobile. All rights reserved.
//

import Foundation
import Alamofire

public typealias AuthCompletionHandler = (valid: Bool, error: NSError?) -> ()

public func checkCredentials(username: String, password: String, completionHandler: AuthCompletionHandler) -> Request {
    return Alamofire.request(.GET, "https://api.feedbin.com/v2/authentication.json").authenticate(user: username, password: password).responseString { (request, response, responseString, error) in
        if let response = response {
            switch response.statusCode {
            case 200...299:
                completionHandler(valid: true, error: error)
                return
            default:
                break
            }
        }

        completionHandler(valid: false, error: error)
    }
}
