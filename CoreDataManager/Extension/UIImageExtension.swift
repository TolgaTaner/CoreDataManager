//
//  UIImageExtension.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 30.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import UIKit
import CoreGraphics
extension UIImage {
    
    var pngRepresentationData: Data? {
        return self.pngData()
    }
    
    var jpegRepresentationData: NSData? {
        return self.jpegData(compressionQuality: 1.0)! as NSData
    }
}
