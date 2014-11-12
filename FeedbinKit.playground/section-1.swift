// Playground - noun: a place where people can play

import UIKit
import FeedbinKit
import ObjectMapper


let savedSearchesJSON = "[{\"id\": 1, \"name\": \"JavaScript\", \"query\": \"javascript is:unread\" }]"
let searches: [SavedSearch]? = Mapper().map(savedSearchesJSON, to: SavedSearch.self)

if let searches = searches {
    println("# Saved searches")
    for search in searches {
        if let name = search.name {
            println("- \(name)")
        } else {
            println("- Unnamed")
        }
    }
    print("\n\n")
}
