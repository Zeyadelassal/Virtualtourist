//
//  DataController.swift
//  VirtualTourist
//
//  Created by zeyadel3ssal on 6/2/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import Foundation
import CoreData

class DataController{
    
    let persistentContainer : NSPersistentContainer
    
    //Create managed object context to deal with attributes
    var viewContext : NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    //Intialize persistent container with our model name
    init(modelName:String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }

    
    //Load data from persistent store
    func load(Completion :(()->Void)? = nil){
        persistentContainer.loadPersistentStores(){(storeDescription , error) in
            guard error == nil else {
                print("There is with loading data: \(String(describing: error?.localizedDescription))")
                return
            }
            Completion?()
        }
    }
}


extension DataController{
    
    func autoSaveViewContext(interval : TimeInterval = 30){
        print("Auto Saving")
        
        if viewContext.hasChanges{
            try? viewContext.save()
        }
    
        DispatchQueue.main.asyncAfter(deadline: .now() + interval){
            self.autoSaveViewContext(interval: interval)
        }
    }
}
