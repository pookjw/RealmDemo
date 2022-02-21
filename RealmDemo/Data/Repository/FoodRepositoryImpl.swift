//
//  FoodRepositoryImpl.swift
//  RealmDemo
//
//  Created by Jinwoo Kim on 2/21/22.
//

import Foundation
import RealmDemoDB
import RxSwift

final class FoodRepositoryImpl: FoodRepository {
    private let realmDBStack: RealmDBStack
    
    init() {
        self.realmDBStack = RealmDBStackImpl()
    }
    
    func readAllFoods() -> Observable<[Food]> {
        realmDBStack.read()
    }
    
    func readFood(with name: String) -> Observable<Food> {
        realmDBStack.read(identifier: name)
    }
    
    func update(foods: [Food]) -> Observable<[Food]> {
        realmDBStack.write(representables: foods)
    }
    
    func delete(foods: [Food]) -> Observable<Void> {
        realmDBStack.delete(representables: foods)
    }
    
    func deleteAll() -> Observable<Void> {
        realmDBStack.deleteAll(type: Food.self)
    }
    
    func observe() -> Observable<Void> {
        realmDBStack.observe(type: Food.self)
    }
}
