//
//  SKExtensions.swift
//  SKPlayerViewControllerExample
//
//  Created by Mark Lagae on 9/3/17.
//  Copyright © 2017 Mark Lagae. All rights reserved.
//

import UIKit

// Recolors the image to the specified color. Useful for not having multiple of the same image but in different colors in assets
extension UIImage {
    
    func maskWith(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage!)
        
        color.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

// Resized the image to the specified height taking into account the device scale
extension UIImage {
    
    func resizeTo(height: CGFloat) -> UIImage {
        
        let size = self.size
        
        let newWidth = (size.width * height) / size.height
        
        let newImageRect = CGRect(x: 0, y: 0, width: newWidth, height: height)
        
        UIGraphicsBeginImageContextWithOptions(newImageRect.size, false, UIScreen.main.scale)
        self.draw(in: newImageRect)
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }
}
