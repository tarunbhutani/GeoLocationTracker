//
//  RealmService.swift
//  GeoLocationTracker
//
//  Created by Tarun Bhutani on 16/02/2019.
//  Copyright © 2019 Tarun Bhutani. All rights reserved.
//

import Foundation
import RealmSwift

class RealmService {
    
    private init() {}
    
    static let instance = RealmService()
    
    let realm = try! Realm()
    
    func addObject<T: Object>(_ object: T, _ completion: (()->Void)? = nil) {
        do{
            try realm.write {
                realm.add(object)
                //realm.add(object, update: true)
            }
            completion?()
        }catch{
            print("\(#function), line: ", #line, " Error: ", error)
            post(error)
        }
    }
    
    func isObjectExist<T : Object>(_ model:T.Type, predicate : NSPredicate, completion : @escaping(Bool, T?) -> Void) {
        autoreleasepool{
            if let user = realm.objects(model.self).filter(predicate).first{
                completion(true, user)
                return
            }
            completion(false, nil)
        }
    }
    
    func getObject<T:Object>(_ model:T.Type, predicate:NSPredicate) -> T? {
        
        return realm.objects(model.self).filter(predicate).first
        
    }
    
    func getAllFilterObjects<T : Object>(_ model:T.Type, predicate : NSPredicate) -> Results<T>? {
        return realm.objects(model.self).filter(predicate)
    }
    
    func getAllObjects<T : Object>(_ model:T.Type) -> Results<T> {
        return realm.objects(model.self)
    }
    
    func getAllObjects<T : Object>(_ model:T.Type, predicate : NSPredicate, totalItemToLoad:Int, presentListSize : Int, sortedByKey : String, isAscending:Bool, completion: @escaping ([T]) -> Void)  {
        
        autoreleasepool{
            let objects = realm.objects(model.self).filter(predicate).sorted(byKeyPath: sortedByKey, ascending: isAscending)
            
            var genericObjects = [T]()
            let to = objects.count - presentListSize
            let from = (to - totalItemToLoad) < 0 ? 0 : (to - totalItemToLoad)
            //print("load message from ", from, " To ", to)
            for index in from..<to{
                genericObjects.append(objects[index])
            }
            
            completion(genericObjects)
        }
        
    }
    
    
    func addAll<T:Object>(_ objects : [T]) {
        do{
            try realm.write {
                autoreleasepool{
                    objects.forEach{ realm.add($0, update: true) }
                }
            }
        }catch{post(error)}
    }
    
    func update<T:Object>(_ object:T, with dictionary: [String:Any?]) {
        do{
            try realm.write {
                autoreleasepool{
                    for (key, value) in dictionary{
                        object.setValue(value, forKey: key)
                    }
                }
            }
        }catch{
            post(error)
        }
    }
    
    
    
    func delete<T:Object>(_ object : T) {
        autoreleasepool{
            do{
                try realm.write {
                    realm.delete(object)
                }
            }catch{ post(error) }
        }
        
    }
    func deleteAll<T:Object>(_ objects : Results<T>) {
        do{
            try realm.write {
                autoreleasepool{
                    objects.forEach{ realm.delete($0) }
                }
            }
        }catch{ post(error) }
    }
    
    func post(_ error : Error) {
        NotificationCenter.default.post(name: NSNotification.Name("RealmError"), object: error)
    }
    
    func observeRealmErrors(in vc: UIViewController, completion: @escaping (Error?) -> Void) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("RealmError"), object: nil, queue: nil, using: { completion($0.object as? Error)})
    }
    
    func removeObserver(in vc : UIViewController) {
        NotificationCenter.default.removeObserver(vc, name: NSNotification.Name("RealmError"), object: nil)
    }
}
