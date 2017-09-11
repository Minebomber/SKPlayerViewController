//
//  SKVideo.swift
//  SKPlayerViewControllerExample
//
//  Created by Mark Lagae on 9/10/17.
//  Copyright © 2017 Mark Lagae. All rights reserved.
//

import UIKit

class SKVideo: NSObject {

    let title: String!
    let album: String!
    let duration: Double!
    let streamUrl: String!
    let thumbnailUrl: String!
    
    let isLiveStream: Bool!
    
    init(title: String, album: String, duration: Double, streamUrl: String, thumbnailUrl: String, isLiveStream: Bool) {
        self.title = title
        self.album = album
        self.duration = duration
        self.streamUrl = streamUrl
        self.thumbnailUrl = thumbnailUrl
        self.isLiveStream = isLiveStream
    }
}
