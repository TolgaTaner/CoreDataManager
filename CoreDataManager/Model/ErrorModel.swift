//
//  ErrorModel.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 18.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import Foundation
class ErrorModel {
    
    var code: Int
    var message: String
    
    
    init(){
        self.code = -1
        self.message = ""
    }
    
    init(message:String,code:Int = -1) {
        self.code = code
        self.message = message
    }
    init(error:Error,code:Int = -1) {
        self.code = code
        self.message = error.localizedDescription 
    }
    
}
