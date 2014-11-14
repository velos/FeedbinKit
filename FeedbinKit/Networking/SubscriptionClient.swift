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


public enum SubscriptionRouter: URLRequestConvertible {
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

    public var URLRequest: NSURLRequest {
        let URL = NSURL(string: SubscriptionRouter.baseURLString)
        let mutableURLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue

        // add headers and stuff here

        return mutableURLRequest
    }
}


public extension FeedbinClient {
    public func readAllSubscriptions() -> Future<[Subscription]> {
        let promise = Promise<[Subscription]>()

        if credential == nil {
            promise.error(NSError())
            return promise.future
        }

        self.request(SubscriptionRouter.ReadAll()).authenticate(usingCredential: self.credential!).responseString { (_, _, responseString, error) -> Void in
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


    public func readAllSubscriptionsSince(sinceDate: NSDate) -> Future<[Subscription]> {
        let promise = Promise<[Subscription]>()

        if credential == nil {
            promise.error(NSError())
            return promise.future
        }

        self.request(SubscriptionRouter.ReadAllSince(sinceDate: sinceDate)).authenticate(usingCredential: self.credential!).responseString { (_, _, responseString, error) -> Void in
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


    // TODO: read individual subscription


    public func createSubscription(feedURL: NSURL) -> Future<([Subscription]?, NSURL?)> {
        let promise = Promise<([Subscription]?, NSURL?)>()

        if credential == nil {
            promise.error(NSError())
            return promise.future
        }

        self.request(SubscriptionRouter.Create(feedURL)).authenticate(usingCredential: self.credential!).responseString { (_, response, responseString, error) -> Void in

            if let response = response {
                switch response.statusCode {
                case 201, 302:
                    // 201 Created, 302 Found
                    // TODO: this should provide a Subscription object instead
                    if let subscriptionURLString = response.allHeaderFields["Location"] as? NSString {
                        let subscriptionURL: NSURL? = NSURL(string: subscriptionURLString)
                        promise.success(nil, subscriptionURL)
                        return
                    }
                case 300:
                    if let responseString = responseString {
                        promise.success(Mapper().map(responseString, to: Subscription.self), nil)
                        return
                    }
                default:
                    // assume anything else is failure
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


    public func updateSubscription(subscription: Subscription) -> Future<Subscription> {
        let promise = Promise<Subscription>()

        if credential == nil {
            promise.error(NSError())
            return promise.future
        }

        self.request(SubscriptionRouter.Update(subscription)).authenticate(usingCredential: self.credential!).responseString { (_, _, responseString, error) -> Void in

            if let responseString = responseString {
                if let subscription: Subscription = Mapper().map(responseString, to: Subscription.self) {
                    promise.success(subscription)
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


    public func deleteSubscription(subscription: Subscription) -> Future<Void> {
        let promise = Promise<Void>()

        if credential == nil {
            promise.error(NSError())
            return promise.future
        }

        self.request(SubscriptionRouter.Delete(subscription)).authenticate(usingCredential: self.credential!).responseString { (_, response, _, error) -> Void in

            if response?.statusCode == 200 {
                promise.success()
                return
            }

            if let error = error {
                promise.error(error)
            } else {
                promise.error(NSError())
            }
        }
        return promise.future
    }
}


