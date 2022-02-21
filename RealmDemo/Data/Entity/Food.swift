//
//  Food.swift
//  RealmDemo
//
//  Created by Jinwoo Kim on 2/21/22.
//

import Foundation
import RealmDemoDB

struct Food: DBRepresentable {
    let name: String
    var price: Int
    
    init(name: String, price: Int) {
        self.name = name
        self.price = price
    }
    
    // MARK: - DBRepresentable
    
    let version: Int = 0
    var identifier: String { name }
    
    enum CodingKeyForVersion: String, CodingKey {
        case version
    }
    
    enum CodingKeysForZero: String, CodingKey {
        case name, price
    }
    
    init(from decoder: Decoder) throws {
        let versionContainer: KeyedDecodingContainer<CodingKeyForVersion> = try decoder.container(keyedBy: CodingKeyForVersion.self)
        
        let version: Int = try versionContainer.decode(Int.self, forKey: .version)
        
        switch version {
        case 0:
            let container: KeyedDecodingContainer<CodingKeysForZero> = try decoder.container(keyedBy: CodingKeysForZero.self)
            
            self.name = try container.decode(String.self, forKey: .name)
            self.price = try container.decode(Int.self, forKey: .price)
        default:
            fatalError("Not supported version.")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var versionContainer: KeyedEncodingContainer<CodingKeyForVersion> = encoder.container(keyedBy: CodingKeyForVersion.self)
        var zeroContainer: KeyedEncodingContainer<CodingKeysForZero> = encoder.container(keyedBy: CodingKeysForZero.self)
        
        try versionContainer.encode(version, forKey: .version)
        try zeroContainer.encode(name, forKey: .name)
        try zeroContainer.encode(price, forKey: .price)
    }
}
