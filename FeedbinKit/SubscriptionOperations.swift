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


enum Router: URLRequestConvertible {
    static let baseURLString = "https://api.feedbin.com/v2/"
    static var credential: NSURLCredential?

    case ReadSubscriptions()
    case ReadSubscriptionsSince(sinceDate: NSDate)
    case CreateSubscription(NSURL)
    case ReadSubscription(Int)
    case UpdateSubscription(Int)
    case DeleteSubscription(Int)

    var method: Alamofire.Method {
        switch self {
        case .ReadSubscriptions:
            return .GET
        case .ReadSubscriptionsSince:
            return .GET
        case .CreateSubscription:
            return .POST
        case .ReadSubscription:
            return .GET
        case .UpdateSubscription:
            return .PATCH
        case .DeleteSubscription:
            return .DELETE
        }
    }

    var path: String {
        switch self {
        case .ReadSubscriptions:
            return "/subscriptions.json"
        case .ReadSubscriptionsSince(let sinceDate):
            return "/subscriptions.json?since=\(sinceDate)"
        case .CreateSubscription:
            return "/subscriptions.json"
        case .ReadSubscription(let identifier):
            return "/subscriptions/\(identifier).json"
        case .UpdateSubscription(let identifier):
            return "/subscriptions/\(identifier).json"
        case .DeleteSubscription(let identifier):
            return "/subscriptions/\(identifier).json"
        }
    }

    // MARK: URLRequestConvertible

    var URLRequest: NSURLRequest {
        let URL = NSURL(string: Router.baseURLString)
        let mutableURLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue

        // add headers and stuff here

        return mutableURLRequest
    }
}
