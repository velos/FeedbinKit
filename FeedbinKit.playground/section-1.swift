// Playground - noun: a place where people can play

import UIKit
import XCPlayground
import FeedbinKit
import ObjectMapper

XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: true)


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


let username = ""
let password = ""

let client = FeedbinClient()
client.authenticate(username, password: password).flatMap { _ in
    client.readAllSubscriptions()
}.onSuccess { subscriptions in
    println("got subscriptions: \(subscriptions)")
}.onFailure { error in
    println("authentication failed")
}
