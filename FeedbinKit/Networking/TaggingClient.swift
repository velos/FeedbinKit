//
//  TaggingClient.swift
//  FeedbinKit
//
//  Created by Bill Williams on 11/19/14.
//  Copyright (c) 2014 Velos Mobile. All rights reserved.
//

import Foundation

import Alamofire
import BrightFutures
import ObjectMapper


enum TaggingRouter: URLRequestConvertible {
    static let baseURLString = "https://api.feedbin.com/v2/"

    case ReadAll()
    case Create(Tagging)
    case Read(Tagging)
    case Delete(Tagging)

    var method: Alamofire.Method {
        switch self {
        case .ReadAll:
            return .GET
        case .Create:
            return .POST
        case .Read:
            return .GET
        case .Delete:
            return .DELETE
        }
    }

    var path: String {
        switch self {
        case .ReadAll:
            return "/taggings.json"
        case .Create:
            return "/taggings.json"
        case .Read(let tag):
            return "/taggings/\(tag.identifier).json"
        case .Delete(let tag):
            return "/taggings/\(tag.identifier).json"
        }
    }

    // MARK: URLRequestConvertible

    var URLRequest: NSURLRequest {
        let URL = NSURL(string: TaggingRouter.baseURLString)
        let mutableURLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue

        switch self {
        case .Create(let search):
            let JSONString = Mapper().toJSONString(search, prettyPrint: false)
            mutableURLRequest.HTTPBody = JSONString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        default:
            break
        }

        return mutableURLRequest
    }
}


public extension FeedbinClient {
    public func readAllTagginges() -> Future<[Tagging]> {
        return request(TaggingRouter.ReadAll()) { _, _, responseString in
            return Mapper().map(responseString, to: Tagging.self)
        }
    }


    public func readTagging(tag: Tagging) -> Future<Tagging> {
        return request(TaggingRouter.Read(tag)) { _, _, responseString in
            return Mapper().map(responseString, to: tag)
        }
    }


    public func createTagging(tag: Tagging) -> Future<NSURL?> {
        return request(TaggingRouter.Create(tag)) { _, response, _ in
            // TODO: return the actual tagging object
            if let locationHeaderString = response?.allHeaderFields["Location"] as? String {
                return NSURL(string: locationHeaderString)
            } else {
                return nil
            }
        }
    }



    public func deleteTagging(search: Tagging) -> Future<Void> {
        return self.request(TaggingRouter.Delete(search)) { _, response, _ in
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
