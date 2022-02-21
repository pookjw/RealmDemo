//
//  RealmDBStack.swift
//  RealmDemoDB
//
//  Created by Jinwoo Kim on 2/21/22.
//

import Foundation
import RxSwift

public protocol RealmDBStack: AnyObject {
    func read<T: DBRepresentable>() -> Observable<[T]>
    func read<T: DBRepresentable>(identifier: String) -> Observable<T>
    func write<T: DBRepresentable>(representables: [T]) -> Observable<[T]>
    func delete<T: DBRepresentable>(representables: [T]) -> Observable<Void>
    func deleteAll<T: DBRepresentable>(type: T.Type) -> Observable<Void>
    func observe<T: DBRepresentable>(type: T.Type) -> Observable<Void>
}
