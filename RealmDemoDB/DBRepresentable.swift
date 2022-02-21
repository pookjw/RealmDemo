//
//  DBRepresentable.swift
//  RealmDemoDB
//
//  Created by Jinwoo Kim on 2/21/22.
//

import Foundation

public protocol DBRepresentable: Codable {
    var version: Int { get }
    var identifier: String { get }
}
