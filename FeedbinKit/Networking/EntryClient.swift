//
//  EntryClient.swift
//  FeedbinKit
//
//  Created by Bill Williams on 11/14/14.
//  Copyright (c) 2014 Velos Mobile. All rights reserved.
//

import Foundation

import Alamofire
import BrightFutures
import ObjectMapper


public enum EntryRouter: URLRequestConvertible {
    static let baseURLString = "https://api.feedbin.com/v2/"

    public struct Pagination {
        var page: Int
        var entriesPerPage: Int

        public init(page: Int, entriesPerPage: Int = 50) {
            self.page = page
            self.entriesPerPage = entriesPerPage
        }
    }

    case ReadAll(pagination: Pagination?, sinceDate: NSDate?, starred: Bool?, identifiers: [Int]?)
    case Read(entry: Entry)

    var method: Alamofire.Method {
        switch self {
        case .ReadAll:
            return .GET
        case .Read:
            return .GET
        }
    }

    var path: String {
        switch self {
        case .ReadAll(let params):
            var queryParameters = [String:String]()

            if let pagination = params.pagination {
                queryParameters["page"] = String(pagination.page)
                queryParameters["per_page"] = String(pagination.entriesPerPage)
            }

            if let sinceDate = params.sinceDate {
                // transformToJSON actually means "transform to a simple JSON-compatible type"
                queryParameters["since_date"] = ISO8601DateTransform().transformToJSON(sinceDate)
            }

            if let starred = params.starred {
                queryParameters["starred"] = starred ? "true" : "false"
            }

            if let identifiers = params.identifiers {
                // equivalent Objective-C is -[NSArray componentsJoinedByString:].
                // similarly to python, though, we call join on the separator string.
                queryParameters["ids"] = ",".join(identifiers.map { id in
                    return String(id)
                })
            }

            var path = "/entries.json"
            return path
        case .Read(let entry):
            return "/entries/\(entry).json"
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
    public func readAllEntries(pagination: EntryRouter.Pagination? = nil, sinceDate: NSDate? = nil, starred: Bool? = nil, identifiers: [Int]? = nil) -> Future<[Entry]> {
        return self.request(EntryRouter.ReadAll(pagination: pagination, sinceDate: sinceDate, starred: starred, identifiers: identifiers)) { _, _, responseString in
            return Mapper().map(responseString, to: Entry.self)
        }
    }


    public func readEntry(entry: Entry) -> Future<Entry> {
        return self.request(EntryRouter.Read(entry: entry)) { _, _, responseString in
            return Mapper().map(responseString, to: entry)
        }
    }
}
