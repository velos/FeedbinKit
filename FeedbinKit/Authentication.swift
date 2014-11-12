//
//  Authentication.swift
//  FeedbinKit
//
//  Created by Bill Williams on 11/12/14.
//  Copyright (c) 2014 Velos Mobile. All rights reserved.
//

import Foundation
import Alamofire
import BrightFutures


public typealias AuthCompletionHandler = (valid: Bool, error: NSError?) -> ()


public func checkCredentials(username: String, password: String) -> Future<Void> {
    let promise = Promise<Void>()
    Alamofire.request(.GET, "https://api.feedbin.com/v2/authentication.json").authenticate(user: username, password: password).responseString { (request, response, responseString, error) in
        if let response = response {
            switch response.statusCode {
            case 200...299:
                promise.success()
                return
            default:
                break
            }
        }

        if let error = error {
            promise.error(error)
        } else {
            promise.error(NSError())
        }
    }
    return promise.future
}
