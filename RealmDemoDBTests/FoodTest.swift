//
//  FoodTest.swift
//  RealmDemoDBTests
//
//  Created by Jinwoo Kim on 2/21/22.
//

import XCTest
@testable import RealmDemo
@testable import RxSwift

class FoodTest: XCTestCase {
    private var foodUseCase: FoodUseCase!
    private var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        self.foodUseCase = FoodUseCaseImpl()
        self.disposeBag = .init()
    }
    
    override func tearDown() {
        super.tearDown()
        self.foodUseCase = nil
        self.disposeBag = nil
    }
    
    func testCreatingFruits() {
        let apple: Food = .init(name: "Apple", price: 300)
        let banana: Food = .init(name: "Banana", price: 500)
        
        let expectation: XCTestExpectation = .init()
        
        foodUseCase.update(foods: [apple, banana])
            .subscribe(onNext: nil,
                       onError: { error in XCTFail(error.localizedDescription)},
                       onCompleted: { expectation.fulfill() },
                       onDisposed: nil)
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testReadingAllFruits() {
        let expectation: XCTestExpectation = .init()
        
        foodUseCase.readAllFoods()
            .subscribe(onNext: { foods in
                guard let apple: Food = foods.first(where: { $0.name == "Apple" }),
                      let banana: Food = foods.first(where: { $0.name == "Banana" }) else {
                          XCTFail("")
                          return
                      }
                
                print(apple, banana)
            }, onError: { error in
                XCTFail(error.localizedDescription)
            }, onCompleted: {
                expectation.fulfill()
            }, onDisposed: nil)
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testReadApple() {
        let expectation: XCTestExpectation = .init()
        
        foodUseCase.readFood(with: "Apple")
            .subscribe(onNext: nil,
                       onError: { error in
                XCTFail(error.localizedDescription)
            }, onCompleted: {
                expectation.fulfill()
            }, onDisposed: nil)
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testDeletingApple() {
        let expectation: XCTestExpectation = .init()
        
        foodUseCase.readFood(with: "Apple")
            .flatMapLatest { food -> Observable<Void> in
                return self.foodUseCase.delete(foods: [food])
            }
            .subscribe(onNext: nil,
                       onError: { error in XCTFail(error.localizedDescription) },
                       onCompleted: {
                expectation.fulfill()
            }, onDisposed: nil)
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testDeleteAll() {
        let expectation: XCTestExpectation = .init()
        
        foodUseCase.deleteAll()
            .subscribe(onNext: nil,
                       onError: { error in XCTFail(error.localizedDescription)},
                       onCompleted: { expectation.fulfill() },
                       onDisposed: nil)
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 3.0)
    }
}
