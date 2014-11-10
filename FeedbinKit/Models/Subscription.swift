//
//  Subscription.swift
//  FeedbinKit
//
//  Created by Bill Williams on 11/10/14.
//  Copyright (c) 2014 Velos Mobile. All rights reserved.
//

import Foundation
import ObjectMapper


public class Subscription : MapperProtocol {
    var identifier: Int?
    var createdAt: NSDate?
    var feedIdentifier: Int?
    var title: String?
    var feedURL: NSURL?
    var siteURL: NSURL?

    public required init () {
        // ...
    }

    // MARK: - MapperProtocol
    public class func map(mapper: Mapper, object: Subscription) {
        object.identifier       <= mapper["id"]
        object.createdAt        <= mapper["created_at"] // TODO: DateTransformer
        object.feedIdentifier   <= mapper["feed_id"]
        object.title            <= mapper["title"]
        object.feedURL          <= (mapper["feed_url"], URLTransform<NSURL, String>())
        object.siteURL          <= (mapper["site_url"], URLTransform<NSURL, String>())
    }
}
