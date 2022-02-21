//
//  FoodUseCaseImpl.swift
//  RealmDemo
//
//  Created by Jinwoo Kim on 2/21/22.
//

import Foundation
import RxSwift

final class FoodUseCaseImpl: FoodUseCase {
    private let foodRepository: FoodRepository
    
    init() {
        self.foodRepository = FoodRepositoryImpl()
    }
    
    func readAllFoods() -> Observable<[Food]> {
        foodRepository.readAllFoods()
    }
    
    func readFood(with name: String) -> Observable<Food> {
        foodRepository.readFood(with: name)
    }
    
    func update(foods: [Food]) -> Observable<[Food]> {
        foodRepository.update(foods: foods)
    }
    
    func delete(foods: [Food]) -> Observable<Void> {
        foodRepository.delete(foods: foods)
    }
    
    func deleteAll() -> Observable<Void> {
        foodRepository.deleteAll()
    }
    
    func observe() -> Observable<Void> {
        foodRepository.observe()
    }
}
