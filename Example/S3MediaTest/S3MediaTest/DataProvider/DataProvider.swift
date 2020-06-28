//
//  DataProvider.swift
//  S3MediaTest
//
//  Created by Erdi on 28.06.2020.
//  Copyright © 2020 *. All rights reserved.
//

import Foundation

class DataProvider {
    
    private enum Buckets {
        
        static let mediaBucket = "s3-media-test-app/public/mediaImages"
    }
    
    private static func mediaPageList() -> [String] {
        return ["IMG_611667419.007082.jpg",
        "IMG_612692262.947296.jpg",
        "VID_595455357.829865.mov",
        "VID_595457887.535975.mov"]
    }
    
    static func mediaPageTasks() -> [S3MediaTask] {
        mediaPageList().map { S3MediaTask(keyName: $0,
                                          bucketName: Buckets.mediaBucket,
                                          type: $0.hasSuffix(".jpg") ? .image : .video) }
    }
}
