//
//  FeedbinClient.swift
//  FeedbinKit
//
//  Created by Bill Williams on 11/13/14.
//  Copyright (c) 2014 Velos Mobile. All rights reserved.
//

import Foundation
import Alamofire
import BrightFutures


public class FeedbinClient: Alamofire.Manager {
    let configuration: NSURLSessionConfiguration
    var credential: NSURLCredential?

    required public init () {
        configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        super.init(configuration: configuration)
    }

    required public init(configuration: NSURLSessionConfiguration?) {
        fatalError("init(configuration:) has not been implemented")
    }

    public func authenticate(username: String, password: String) -> Future<Void> {
        let promise = Promise<Void>()
        credential = NSURLCredential(user: username, password: password, persistence: .ForSession)
        request(.GET, "https://api.feedbin.com/v2/authentication.json").authenticate(usingCredential: credential!).responseString { (request, response, responseString, error) in
            if let response = response {
                switch response.statusCode {
                case 200...299:
                    promise.success()
                    return
                default:
                    break
                }
            }

            self.credential = nil
            if let error = error {
                promise.error(error)
            } else {
                promise.error(NSError())
            }
        }
        return promise.future
    }

}
