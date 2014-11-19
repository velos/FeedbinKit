//
//  SavedSearchClient.swift
//  FeedbinKit
//
//  Created by Bill Williams on 11/17/14.
//  Copyright (c) 2014 Velos Mobile. All rights reserved.
//

import Foundation

import Alamofire
import BrightFutures
import ObjectMapper


public enum SavedSearchRouter: URLRequestConvertible {
    static let baseURLString = "https://api.feedbin.com/v2/"

    case ReadAll()
    case Create(SavedSearch)
    case Read(SavedSearch)
    case Update(SavedSearch)
    case Delete(SavedSearch)

    var method: Alamofire.Method {
        switch self {
        case .ReadAll:
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
            return "/saved_searches.json"
        case .Create:
            return "/saved_searches.json"
        case .Read(let savedSearch):
            return "/saved_searches/\(savedSearch.identifier).json"
        case .Update(let savedSearch):
            return "/saved_searches/\(savedSearch.identifier).json"
        case .Delete(let savedSearch):
            return "/saved_searches/\(savedSearch.identifier).json"
        }
    }

    // MARK: URLRequestConvertible

    public var URLRequest: NSURLRequest {
        let URL = NSURL(string: SavedSearchRouter.baseURLString)
        let mutableURLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue

        switch self {
        case .Create(let search):
            let JSONString = Mapper().toJSONString(search, prettyPrint: false)
            mutableURLRequest.HTTPBody = JSONString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        case Update(let search):
            let JSONString = Mapper().toJSONString(search, prettyPrint: false)
            mutableURLRequest.HTTPBody = JSONString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        default:
            break
        }

        return mutableURLRequest
    }
}


public extension FeedbinClient {
    public func readAllSavedSearches() -> Future<[SavedSearch]> {
        return request(SavedSearchRouter.ReadAll()) { request, response, responseString in
            return Mapper().map(responseString, to: SavedSearch.self)
        }
    }


    // TODO: pagination
    public func readSavedSearch(search: SavedSearch) -> Future<[Entry]> {
        return requestJSON(SavedSearchRouter.Read(search)) { request, response, responseJSON in
            if let identifiers = responseJSON as? Array<Int> {
                let entries = identifiers.map { (identifier: Int) -> Entry in
                    var entry = Entry()
                    entry.identifier = identifier
                    return entry
                }
                return entries
            }

            return nil
        }

    }


    public func createSavedSearch(search: SavedSearch) -> Future<NSURL?> {
        return request(SavedSearchRouter.Create(search)) { request, response, responseString in
            // TODO: return the actual saved search object
            if let locationHeaderString = response?.allHeaderFields["Location"] as? String {
                return NSURL(string: locationHeaderString)
            } else {
                return nil
            }
        }
    }


    public func updateSavedSearch(search: SavedSearch) -> Future<SavedSearch> {
        return request(SavedSearchRouter.Update(search)) { request, response, responseString in
            return Mapper().map(responseString, to: SavedSearch.self)
        }
    }


    public func deleteSavedSearch(search: SavedSearch) -> Future<Void> {
        return self.request(SavedSearchRouter.Delete(search)) { request, response, responseString in
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

