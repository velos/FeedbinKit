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
    public var identifier: Int?
    public var createdAt: NSDate?
    public var feedIdentifier: Int?
    public var title: String?
    public var feedURL: NSURL?
    public var siteURL: NSURL?

    public required init () {
        // ...
    }

    // MARK: - MapperProtocol
    public class func map(mapper: Mapper, object: Subscription) {
        object.identifier       <= mapper["id"]
        object.createdAt        <= (mapper["created_at"], ISO8601DateTransform<NSDate, String>())
        object.feedIdentifier   <= mapper["feed_id"]
        object.title            <= mapper["title"]
        object.feedURL          <= (mapper["feed_url"], URLTransform<NSURL, String>())
        object.siteURL          <= (mapper["site_url"], URLTransform<NSURL, String>())
    }
}
