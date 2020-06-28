//
//  S3MediaDownloader.swift
//  KomsudaPisti
//
//  Created by Erdi on 25.06.2020.
//  Copyright © 2020 Komsuda. All rights reserved.
//

import AWSS3

class S3MediaDownloader {
    
    static func downloadMedia(with mediaTask: S3MediaTask, completionBlock: @escaping (URL?, Error?, S3MediaTask)->()) {
        
        let utility = AWSS3TransferUtility.s3TransferUtility(forKey: "transfer-utility-with-advanced-options")
        let url = S3MediaUtils.url(with: mediaTask.keyName)

        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Update a progress bar.
                print(progress)
            })
        } 
        
        utility?.download(to: url,
                          bucket: mediaTask.bucketName,
                          key: mediaTask.keyName,
                          expression: expression,
                          completionHandler: { (task, url, data, error) in
                            completionBlock(url, error, mediaTask)
        })
    }
}
