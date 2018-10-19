//
//  PredicateFormatter.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 18.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import Foundation
import CoreData


enum PredicateFormat:String {
    case keyValueObserving = "%K = %@"
    case contains = "contains[c] %@"
    case greaterThanEqual = ">="
    case lessThanEqual = "<="
    case equal = "="
    case none = ""
    
}

class PredicateFormatter:NSObject {
    var key:String
    var value:Any
    var formatType :PredicateFormat = .none
    var predicate:NSPredicate?
    var sortAs:NSSortDescriptor?
    
    init(key:String,value:String,formatType:PredicateFormat) {
        self.key = key
        self.value = value
        super.init()
        self.setPredicate(key: key, value: value,formatType:formatType)
    }
    
    override init() {
        key = ""
        value = ""
    }
    
    
    
    func setPredicate(key:String,value:String, formatType:PredicateFormat = .none ) {
        self.formatType = formatType
        switch self.formatType {
        case .keyValueObserving:
            self.predicate = NSPredicate(format: formatType.rawValue,key,value)  // Example Given: let ageIs33Predicate = NSPredicate(format: "%K = %@", "age", "33")
        case .greaterThanEqual:
            self.predicate = NSPredicate(format: "\(key) \(formatType.rawValue)",value)
        case .lessThanEqual:
            self.predicate = NSPredicate(format: "\(key) \(formatType.rawValue)",value)
        case .equal:
            self.predicate = NSPredicate(format: "\(key) \(formatType.rawValue)",value)
        case .contains:
            self.predicate = NSPredicate(format: "\(key) \(formatType.rawValue)",value)
        case .none:
            break
        }
    }
    func sortAs(key:String,isAscending:Bool) {
        self.sortAs = NSSortDescriptor(key: key, ascending: isAscending)
        
    }
    func changePredicateWith(key:String,value:String,formatType:PredicateFormat = .none) {
        clearPredicate()
        if formatType == .none {
              setPredicate(key: key, value: value)
        }
        else {
        setPredicate(key: key, value: value, formatType: formatType)
        }
    }
    func clearPredicate() {
        self.predicate = nil
    }
    
    
}
