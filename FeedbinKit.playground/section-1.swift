// Playground - noun: a place where people can play

import UIKit
import FeedbinKit
import ObjectMapper


let saved_searches_json = "{\"id\": 1, \"name\": \"JavaScript\", \"query\": \"javascript is:unread\" }"

let s: SavedSearch = Mapper().map(saved_searches_json, to: SavedSearch.self)

s.identifier
s.query
s.name
