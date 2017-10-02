//
//  SKVideo.swift
//  StreamKit-iOS
//
//  Created by Mark Lagae on 9/28/17.
//  Copyright © 2017 Mark Lagae. All rights reserved.
//

import Foundation

class SKVideo {
    var title: String
    var album: String
    var duration: Double // in milliseconds
    var m3u8: String
    var thumbnail: String
    var created: String
    let dateCreated: Date
    var isLiveStream: Bool
    
    init(title: String, album: String, duration: Double, m3u8: String, thumbnail: String, created: String?, isLiveStream: Bool) {
        self.title = title
        self.album = album
        self.duration = duration
        self.m3u8 = m3u8
        self.thumbnail = thumbnail
        self.created = created ?? ""
        self.dateCreated = SKVideo.getDateFromDateString(dateString: created)
        self.isLiveStream = isLiveStream
    }
    
    class func getDateFromDateString(dateString: String?) -> Date {
        if dateString == nil { return Date() }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Date string format
        return dateFormatter.date(from: dateString!)!
    }
}
