//
//  FoodUseCase.swift
//  RealmDemo
//
//  Created by Jinwoo Kim on 2/21/22.
//

import Foundation
import RxSwift

protocol FoodUseCase: AnyObject {
    func readAllFoods() -> Observable<[Food]>
    func readFood(with name: String) -> Observable<Food>
    func update(foods: [Food]) -> Observable<[Food]>
    func delete(foods: [Food]) -> Observable<Void>
    func deleteAll() -> Observable<Void>
    func observe() -> Observable<Void>
}
