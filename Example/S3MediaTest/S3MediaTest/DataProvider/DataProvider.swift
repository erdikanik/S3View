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
    
    private static func allMedias() -> [String] {
        return ["IMG_611667419.007082.jpg",
        "IMG_612692262.947296.jpg",
        "IMG_613997459.596866.jpg",
        "IMG_614180909.826037.jpg",
        "VID_595455357.829865.mov",
        "VID_595457887.535975.mov",
        "VID_597606824.665165.mov",
        "VID_603556477.489582.mov"]
    }
    
    private static func createRandomCellTask() -> [S3MediaTask] {
        let randomLength = Int.random(in: 1..<6)
        
        var mediasArray: [String] = []
        
        var count = 0
        while (count < 1) {
            let medias: [String] = (0..<randomLength).map {_ in
                let index = Int.random(in: 0..<DataProvider.allMedias().count)
                return DataProvider.allMedias()[index]
            }
            
            mediasArray = Array(Set(medias)) // need uniqueness
            count = mediasArray.count
        }
        
        return mediasArray.map { DataProvider.mediaTask(for: $0) }
    }
    
    private static func mediaTask(for mediaName: String) -> S3MediaTask {
        
        return S3MediaTask(keyName: mediaName,
                           bucketName: Buckets.mediaBucket,
                           type: mediaName.hasSuffix(".jpg") ? .image : .video)
    }
    
    static func tableViewCells() -> [[S3MediaTask]] {
        return (0..<10).map { _ in
            return createRandomCellTask()
        }
    }
    
    static func mediaPageTasks() -> [S3MediaTask] {
        mediaPageList().map { DataProvider.mediaTask(for: $0) }
    }
}
