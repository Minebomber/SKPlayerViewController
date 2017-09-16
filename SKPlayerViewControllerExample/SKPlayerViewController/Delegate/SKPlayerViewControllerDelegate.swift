//
//  SKPlayerViewControllerDelegate.swift
//  SKPlayerViewControllerExample
//
//  Created by Mark Lagae on 9/10/17.
//  Copyright © 2017 Mark Lagae. All rights reserved.
//

import Foundation

protocol SKPlayerViewControllerDelegate: class {
    
    
    // Called when the player view controller dismisses from a presented state. This must be used to dealloc the player. (self.playerViewControllerInstance = nil)
    func playerViewControllerDidDismissCompletely(_ controller: SKPlayerViewController)
    
}
