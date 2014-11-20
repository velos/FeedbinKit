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


enum EntryRouter: URLRequestConvertible {
    static let baseURLString = "https://api.feedbin.com/v2/"

    case ReadAll(pagination: FeedbinClient.Pagination?, sinceDate: NSDate?, starred: Bool?, identifiers: [Int]?)
    case Read(entry: Entry)
    case ReadStarred
    case StarEntries(entries: [Entry])
    case UnstarEntries(entries: [Entry])
    case GetUnread
    case MarkAsUnread(entries: [Entry])
    case MarkAsRead(entries: [Entry])

    var method: Alamofire.Method {
        switch self {
        case .ReadAll:
            return .GET
        case .Read:
            return .GET
        case .ReadStarred:
            return .GET
        case .StarEntries:
            return .POST
        case .UnstarEntries:
            return .DELETE
        case .GetUnread:
            return .GET
        case .MarkAsUnread:
            return .POST
        case .MarkAsRead:
            return .DELETE
        }
    }

    var path: String {
        switch self {
        case .ReadAll(let params):
            var queryParameters = [String:String]()

            if let pagination = params.pagination {
                queryParameters["page"] = String(pagination.page)
                queryParameters["per_page"] = String(pagination.itemsPerPage)
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
                queryParameters["ids"] = ",".join(identifiers.map { String($0) })
            }

            var path = "/entries.json"
            return path
        case .Read(let entry):
            return "/entries/\(entry).json"
        case .ReadStarred, .StarEntries, .UnstarEntries:
            return "/starred_entries.json"
        case .GetUnread, .MarkAsUnread, .MarkAsRead:
            return "/unread_entries.json"
        }
    }

    // MARK: URLRequestConvertible
    func attachJSONObjectToRequest(request: NSMutableURLRequest, JSONObject: AnyObject) {
        var error = NSErrorPointer()
        let JSONData = NSJSONSerialization.dataWithJSONObject(JSONObject, options: nil, error: error)
        if let JSONData = JSONData {
            request.HTTPBody = JSONData
        } else {
            NSLog("Unexpected error serializing JSON: \(error.memory)")
        }
    }

    var URLRequest: NSURLRequest {
        let URL = NSURL(string: SubscriptionRouter.baseURLString)
        let mutableURLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue

        switch self {
        case .StarEntries(let params):
            attachJSONObjectToRequest(mutableURLRequest, JSONObject: [
                "starred_entries": params.entries.filter{ $0 != nil }.map{ $0.identifier! }
            ])
        case .UnstarEntries(let params):
            attachJSONObjectToRequest(mutableURLRequest, JSONObject: [
                "starred_entries": params.entries.filter{ $0 != nil }.map{ $0.identifier! }
            ])
        case .MarkAsUnread(let params):
            attachJSONObjectToRequest(mutableURLRequest, JSONObject: [
                "unread_entries": params.entries.filter{ $0 != nil }.map{ $0.identifier! }
            ])
        case .MarkAsRead(let params):
            attachJSONObjectToRequest(mutableURLRequest, JSONObject: [
                "unread_entries": params.entries.filter{ $0 != nil }.map{ $0.identifier! }
            ])
        default:
            break
        }

        return mutableURLRequest
    }
}


public extension FeedbinClient {
    public func readAllEntries(pagination: Pagination? = nil, sinceDate: NSDate? = nil, starred: Bool? = nil, identifiers: [Int]? = nil) -> Future<[Entry]> {
        return self.request(EntryRouter.ReadAll(pagination: pagination, sinceDate: sinceDate, starred: starred, identifiers: identifiers)) { _, _, responseString in
            return Mapper().map(responseString, to: Entry.self)
        }
    }


    public func readEntry(entry: Entry) -> Future<Entry> {
        return self.request(EntryRouter.Read(entry: entry)) { _, _, responseString in
            return Mapper().map(responseString, to: entry)
        }
    }


    // MARK: Starred Entries
    public func readStarredEntries() -> Future<[Entry]> {
        return requestJSON(EntryRouter.ReadStarred) { _, _, responseJSON in
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


    public func starEntries(entries: [Entry]) -> Future<Void> {
        return self.request(EntryRouter.StarEntries(entries: entries)) { _, response, _ in
            if response?.statusCode == 200 {
                // think of this as returning [NSNull null] instead of nil.
                // yes, that's extraordinarily silly. typesafety!
                return Void()
            } else {
                return nil
            }
        }
    }


    public func unstarEntries(entries: [Entry]) -> Future<Void> {
        return self.request(EntryRouter.UnstarEntries(entries: entries)) { _, response, _ in
            if response?.statusCode == 200 {
                // think of this as returning [NSNull null] instead of nil.
                // yes, that's extraordinarily silly. typesafety!
                return Void()
            } else {
                return nil
            }
        }
    }


    // MARK: Unread entries
    public func getUnreadEntries() -> Future<[Entry]> {
        return requestJSON(EntryRouter.GetUnread) { _, _, responseJSON in
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


    public func markAsRead(entries: [Entry]) -> Future<Void> {
        return self.request(EntryRouter.MarkAsRead(entries: entries)) { _, response, _ in
            if response?.statusCode == 200 {
                // think of this as returning [NSNull null] instead of nil.
                // yes, that's extraordinarily silly. typesafety!
                return Void()
            } else {
                return nil
            }
        }
    }


    public func markAsUnread(entries: [Entry]) -> Future<Void> {
        return self.request(EntryRouter.MarkAsUnread(entries: entries)) { _, response, _ in
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
