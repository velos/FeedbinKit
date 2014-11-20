//
//  SubscriptionClient.swift
//  FeedbinKit
//
//  Created by Bill Williams on 11/12/14.
//  Copyright (c) 2014 Velos Mobile. All rights reserved.
//

import Foundation

import Alamofire
import BrightFutures
import ObjectMapper


enum SubscriptionRouter: URLRequestConvertible {
    static let baseURLString = "https://api.feedbin.com/v2/"

    case ReadAll()
    case ReadAllSince(sinceDate: NSDate)
    case Create(NSURL)
    case Read(Subscription)
    case Update(Subscription)
    case Delete(Subscription)

    var method: Alamofire.Method {
        switch self {
        case .ReadAll:
            return .GET
        case .ReadAllSince:
            return .GET
        case .Create:
            return .POST
        case .Read:
            return .GET
        case .Update:
            return .PATCH
        case .Delete:
            return .DELETE
        }
    }

    var path: String {
        switch self {
        case .ReadAll:
            return "/subscriptions.json"
        case .ReadAllSince(let sinceDate):
            return "/subscriptions.json?since=\(sinceDate)"
        case .Create:
            return "/subscriptions.json"
        case .Read(let subscription):
            return "/subscriptions/\(subscription.identifier).json"
        case .Update(let subscription):
            return "/subscriptions/\(subscription.identifier).json"
        case .Delete(let subscription):
            return "/subscriptions/\(subscription.identifier).json"
        }
    }

    // MARK: URLRequestConvertible

    var URLRequest: NSURLRequest {
        let URL = NSURL(string: SubscriptionRouter.baseURLString)
        let mutableURLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue

        switch self {
        case Update(let subscription):
            let JSONString = Mapper().toJSONString(subscription, prettyPrint: false)
            mutableURLRequest.HTTPBody = JSONString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        default:
            break
        }

        return mutableURLRequest
    }
}


public extension FeedbinClient {
    public func readAllSubscriptions() -> Future<[Subscription]> {
        return request(SubscriptionRouter.ReadAll()) { _, _, responseString in
            return Mapper().map(responseString, to: Subscription.self)
        }
    }


    public func readAllSubscriptionsSince(sinceDate: NSDate) -> Future<[Subscription]> {
        return request(SubscriptionRouter.ReadAllSince(sinceDate: sinceDate)) { _, _, responseString in
            return Mapper().map(responseString, to: Subscription.self)
        }
    }


    public func readSubscription(subscription: Subscription) -> Future<Subscription> {
        return request(SubscriptionRouter.Read(subscription)) { _, _, responseString in
            return Mapper().map(responseString, to: subscription)
        }
    }


    public func createSubscription(feedURL: NSURL) -> Future<([Subscription]?, NSURL?)> {
        return request(SubscriptionRouter.Create(feedURL)) { _, response, responseString in

            if response == nil {
                return (nil, nil)
            }

            switch response!.statusCode {
            case 201, 302:
                // 201 Created, 302 Found
                // TODO: this should provide a Subscription object instead
                if let subscriptionURLString = response!.allHeaderFields["Location"] as? NSString {
                    let subscriptionURL: NSURL? = NSURL(string: subscriptionURLString)
                    return (nil, subscriptionURL)
                }
            case 300:
                let subscriptions: [Subscription]? = Mapper().map(responseString, to: Subscription.self)
                return (subscriptions, nil)
            default:
                // assume anything else is failure
                return (nil, nil)
            }

            return (nil, nil)
        }
    }


    public func updateSubscription(subscription: Subscription) -> Future<Subscription> {
        return request(SubscriptionRouter.Update(subscription)) { _, _, responseString in
            return Mapper().map(responseString, to: Subscription.self)
        }
    }


    public func deleteSubscription(subscription: Subscription) -> Future<Void> {
        return self.request(SubscriptionRouter.Delete(subscription)) { _, response, _ in
            if response?.statusCode == 200 {
                // think of this as returning [NSNull null] instead of nil.
                // yes, that's extraordinarily silly. typesafety!
                return Void()
            } else {
                return nil
            }
        }
    }
}


