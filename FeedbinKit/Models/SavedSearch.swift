//
//  SavedSearch.swift
//  FeedbinKit
//
//  Created by Bill Williams on 11/10/14.
//  Copyright (c) 2014 Velos Mobile. All rights reserved.
//

import Foundation
import ObjectMapper


public class SavedSearch : MapperProtocol {
    var identifier: Int?
    var name: String?
    var query: String?

    public required init () {
        // ...
    }

    // MARK: - MapperProtocol
    public class func map(mapper: Mapper, object: SavedSearch) {
        object.identifier   <= mapper["id"]
        object.name         <= mapper["name"]
        object.query        <= mapper["query"]
    }
}
