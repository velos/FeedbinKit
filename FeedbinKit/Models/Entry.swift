//
//  Entry.swift
//  FeedbinKit
//
//  Created by Bill Williams on 11/10/14.
//  Copyright (c) 2014 Velos Mobile. All rights reserved.
//

import Foundation
import ObjectMapper


public class Entry: MapperProtocol {
    public var identifier: Int?
    public var feedIdentifier: Int?
    public var title: String?
    public var URL: NSURL?
    public var author: String?
    public var content: String?
    public var summary: String?
    public var published: NSDate?
    public var createdAt: NSDate?

    public required init () {
        // ...
    }

    // MARK: - MapperProtocol
    public class func map(mapper: Mapper, object: Entry) {
        object.identifier       <= mapper["id"]
        object.feedIdentifier   <= mapper["feed_id"]
        object.title            <= mapper["title"]
        object.URL              <= (mapper["url"], URLTransform<NSURL, String>())
        object.author           <= mapper["author"]
        object.content          <= mapper["content"]
        object.summary          <= mapper["summary"]
        object.published        <= (mapper["published"], ISO8601DateTransform<NSDate, String>())
        object.createdAt        <= (mapper["created_at"], ISO8601DateTransform<NSDate, String>())
    }
}
