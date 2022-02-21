//
//  RealmDB.swift
//  RealmDemoDB
//
//  Created by Jinwoo Kim on 2/21/22.
//

import Foundation
import RealmSwift

internal final class RealmDB: Object {
    @Persisted(primaryKey: true) var identifier: String
    @Persisted var json: String

    convenience init<T: DBRepresentable>(with representable: T) throws {
        self.init()
        
        self.identifier = representable.identifier
        let data: Data = try JSONEncoder().encode(representable)
        self.json = String(data: data, encoding: .utf8)!
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let toCompare: Self = object as? Self else {
            return false
        }
        
        return (self.identifier == toCompare.identifier) && (self.json == toCompare.json)
    }
}
