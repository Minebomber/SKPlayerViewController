//
//  SKVideo.swift
//  SKPlayerViewControllerExample
//
//  Created by Mark Lagae on 9/10/17.
//  Copyright © 2017 Mark Lagae. All rights reserved.
//

import UIKit

class SKVideo: NSObject {

    var title: String!
    var album: String!
    var duration: Double!
    var streamUrl: String!
    var thumbnailUrl: String!
    
    var isLiveStream: Bool!
    
    init(title: String, album: String, duration: Double, streamUrl: String, thumbnailUrl: String, isLiveStream: Bool) {
        self.title = title
        self.album = album
        self.duration = duration
        self.streamUrl = streamUrl
        self.thumbnailUrl = thumbnailUrl
        self.isLiveStream = isLiveStream
    }
}
