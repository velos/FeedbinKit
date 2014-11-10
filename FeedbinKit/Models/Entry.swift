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
    var identifier: Int?
    var feedIdentifier: Int?
    var title: String?
    var URL: NSURL?
    var author: String?
    var content: String?
    var summary: String?
    var published: NSDate?
    var createdAt: NSDate?

    public required init () {
        // ...
    }

    // MARK: - MapperProtocol
    public class func map(mapper: Mapper, object: Entry) {
        object.identifier       <= mapper["id"]
        object.feedIdentifier   <= mapper["feed_id"]
        object.title            <= mapper["title"]
        object.URL              <= (mapper["url"], URLTransform<NSURL, String>)
        object.author           <= mapper["author"]
        object.content          <= mapper["content"]
        object.summary          <= mapper["summary"]
        object.published        <= mapper["published"] // TODO: DateTransformer
        object.createdAt        <= mapper["created_at"] // TODO: DateTransformer
    }
}
