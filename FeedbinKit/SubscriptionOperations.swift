//
//  SubscriptionOperations.swift
//  FeedbinKit
//
//  Created by Bill Williams on 11/12/14.
//  Copyright (c) 2014 Velos Mobile. All rights reserved.
//

import Foundation

import Alamofire
import BrightFutures
import ObjectMapper


// TODO: support since parameter
public func getSubscriptions(username: String, password: String) -> Future<[Subscription]> {
    let promise = Promise<[Subscription]>()
    Alamofire.request(.GET, "https://api.feedbin.com/v2/subscriptions.json").authenticate(user: username, password: password).responseString { (request, response, responseString, error) in
        if let responseString = responseString {
            if let subscriptions: [Subscription] = Mapper().map(responseString, to: Subscription.self) {
                promise.success(subscriptions)
                return
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
