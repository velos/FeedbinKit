//
//  ISO8601DateTransform.swift
//  FeedbinKit
//
//  Created by Bill Williams on 11/10/14.
//  Copyright (c) 2014 Velos Mobile. All rights reserved.
//

import Foundation
import ObjectMapper


public class ISO8601DateTransform<ObjectType, JSONType>: MapperTransform<ObjectType, JSONType> {
    let dateFormatter = NSDateFormatter()

    public override init() {
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
    }

    func transformFromJSON(value: AnyObject?) -> ObjectType? {
        if let dateString = value as? String {
            return (dateFormatter.dateFromString(dateString) as ObjectType)
        }
        return nil
    }

    func transformToJSON(value: ObjectType?) -> JSONType? {
        if let date = value as? NSDate {
            return (dateFormatter.stringFromDate(date) as JSONType)
        }
        return nil
    }
}
