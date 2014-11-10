//
//  Tagging.swift
//  FeedbinKit
//
//  Created by Bill Williams on 11/10/14.
//  Copyright (c) 2014 Velos Mobile. All rights reserved.
//

import Foundation
import ObjectMapper


public class Tagging : MapperProtocol {
    var identifier: Int?
    var feedIdentifier: Int?
    var name: String?

    // MARK: - MapperProtocol
    class func map(mapper: Mapper, object: Subscription) {
        object.identifier       <= mapper["id"]
        object.feedIdentifier   <= mapper["feed_id"]
        object.name             <= mapper["name"]
    }
}
