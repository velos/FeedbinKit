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
    public struct Pagination {
        var page: Int
        var itemsPerPage: Int

        public init(page: Int, itemsPerPage: Int = 50) {
            self.page = page
            self.itemsPerPage = itemsPerPage
        }
    }

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


    internal func request<T>(URLRequest: URLRequestConvertible, responseHandler: (request: NSURLRequest, response: NSHTTPURLResponse?, responseString: String) -> T?) -> Future<T> {
        let promise = Promise<T>()

        if self.credential == nil {
            promise.error(NSError())
            return promise.future
        }

        let request = self.request(URLRequest).responseString { (request, response, responseString, error) -> Void in
            if let responseString = responseString {
                let value = responseHandler(request: request, response: response, responseString: responseString)
                if let value = value {
                    promise.success(value)
                    return
                }
            }

            promise.error(error ?? NSError())
        }

        return promise.future
    }


    internal func requestJSON<T>(URLRequest: URLRequestConvertible, responseHandler: (request: NSURLRequest, response: NSHTTPURLResponse?, responseObject: AnyObject) -> T?) -> Future<T> {
        let promise = Promise<T>()

        if self.credential == nil {
            promise.error(NSError())
            return promise.future
        }

        let request = self.request(URLRequest).responseJSON { (request, response, responseObject, error) -> Void in
            if let responseObject: AnyObject = responseObject {
                let value = responseHandler(request: request, response: response, responseObject: responseObject)
                if let value = value {
                    promise.success(value)
                    return
                }
            }

            promise.error(error ?? NSError())
        }

        return promise.future
    }
}
