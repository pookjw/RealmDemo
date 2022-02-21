//
//  RealmDBStackImpl.swift
//  RealmDemoDB
//
//  Created by Jinwoo Kim on 2/21/22.
//

import Foundation
import RxSwift
import RealmSwift

internal extension Results {
    var allObjects: [Element] {
        let indexes: IndexSet = .init(integersIn: 0..<count)
        return objects(at: indexes)
    }
}

public enum RealmDBStackImplError: Error {
    case nsDataConversionFailed
    case noObjectFound
}

public final class RealmDBStackImpl: RealmDBStack {
    public init() {
        
    }
    
    public func read<T>() -> Observable<[T]> where T : DBRepresentable {
        return .create { observer in
            do {
                let realmStore: Realm = try self.realmStore(type: T.self)
                let objects: [T] = try realmStore
                    .objects(RealmDB.self)
                    .allObjects
                    .map { db throws -> T in
                        guard let data: Data = db.json.data(using: .utf8) else {
                            throw RealmDBStackImplError.nsDataConversionFailed
                        }
                        return try JSONDecoder().decode(T.self, from: data)
                    }
                observer.onNext(objects)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create {}
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }
    
    public func read<T>(identifier: String) -> Observable<T> where T : DBRepresentable {
        return .create { observer in
            do {
                let realmStore: Realm = try self.realmStore(type: T.self)
                
                guard let object: RealmDB = realmStore.object(ofType: RealmDB.self, forPrimaryKey: identifier) else {
                    throw RealmDBStackImplError.noObjectFound
                }
                    
                guard let data: Data = object.json.data(using: .utf8) else {
                    throw RealmDBStackImplError.nsDataConversionFailed
                }
                
                let result: T = try JSONDecoder().decode(T.self, from: data)
                
                observer.onNext(result)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create {}
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }
    
    public func write<T>(representables: [T]) -> Observable<[T]> where T : DBRepresentable {
        return .create { observer in
            do {
                let objects: [RealmDB] = try representables
                    .map { rep throws -> RealmDB in
                        return try .init(with: rep)
                    }
                
                let realmStore: Realm = try self.realmStore(type: T.self)
                
                try realmStore.write({
                    autoreleasepool {
                        realmStore.add(objects, update: .modified)
                        observer.onNext(representables)
                        observer.onCompleted()
                    }
                })
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create {}
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }
    
    public func delete<T>(representables: [T]) -> Observable<Void> where T : DBRepresentable {
        return .create { observer in
            do {
                let realmStore: Realm = try self.realmStore(type: T.self)
                var objects: [RealmDB] = []
                
                try representables
                    .forEach { rep throws in
                        guard let object: RealmDB = realmStore.object(ofType: RealmDB.self, forPrimaryKey: rep.identifier) else {
                            throw RealmDBStackImplError.noObjectFound
                        }
                        objects.append(object)
                    }
                
                try realmStore.write({
                    autoreleasepool {
                        realmStore.delete(objects)
                        observer.onNext(())
                        observer.onCompleted()
                    }
                })
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create {}
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }
    
    public func deleteAll<T: DBRepresentable>(type: T.Type) -> Observable<Void> {
        return .create { observer in
            do {
                let realmStore: Realm = try self.realmStore(type: T.self)
                let objects: [RealmDB] = realmStore.objects(RealmDB.self).allObjects
                
                try realmStore.write({
                    autoreleasepool {
                        realmStore.delete(objects)
                        observer.onNext(())
                        observer.onCompleted()
                    }
                })
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create {}
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }
    
    public func observe<T>(type: T.Type) -> Observable<Void> where T : DBRepresentable {
        return .create { observer in
            do {
                let realm = try self.realmStore(type: T.self)
                
                let token = realm.observe { _, _ in
                    observer.onNext(())
                }
                
                return Disposables.create {
                    token.invalidate()
                }
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }
    
    private func realmStore<T>(type: T.Type) throws -> Realm where T : DBRepresentable {
        let name: String = String(describing: type)
        
        let realmsUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Realms")
        
        if !FileManager.default.fileExists(atPath: realmsUrl.path) {
            try FileManager.default.createDirectory(at: realmsUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        let realmUrl: URL = realmsUrl
            .appendingPathComponent(name)
            .appendingPathExtension("realm")
        
        var config: Realm.Configuration = .defaultConfiguration
        config.fileURL = realmUrl
        
        return try Realm(configuration: config)
    }
}
