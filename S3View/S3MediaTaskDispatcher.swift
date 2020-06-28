//
//  S3MediaTask.swift
//  KomsudaPisti
//
//  Created by Erdi on 25.06.2020.
//  Copyright © 2020 Komsuda. All rights reserved.
//

import AVFoundation
import UIKit

public protocol S3MediaTaskDelegate: class {
    
    func s3MediaTaskDispatcherDidCompleteFetching(dispatcher: S3MediaTaskDispatcher, dispatchedMedias: [S3Media]?, error: Error?)
    func s3MediaTaskDispatcherDidFinishTask(dispatcher: S3MediaTaskDispatcher,
                                         mediaTask: S3MediaTask,
                                         result: S3MediaResult)
    func s3MediaTaskWillStartToDownloadMedia(dispatcher: S3MediaTaskDispatcher, mediaTask: S3MediaTask) -> Data?
}

public final class S3MediaTaskDispatcher {
    
    private class S3Error: NSError {

        override var code: Int {
            -99
        }
        
        override var localizedDescription: String {
            "Error occured at least in one task"
        }
        
        override var description: String {
            "Error occured at least in one task"
        }
    }
    
    public var s3MediaTaskDispatcherDelegate: S3MediaTaskDelegate?
    public var isCachingEnabled = true
    public private(set) var fetchedMedias: [S3Media]?
    public let groupId: String
    
    private var urlResultMap: [String: S3MediaResult?]
    private var tasks: [S3MediaTask]
    
    public init(mediaTasks: [S3MediaTask], groupId: String) {
        self.tasks = mediaTasks
        self.groupId = groupId
        urlResultMap = Dictionary(uniqueKeysWithValues: mediaTasks.compactMap { ($0.keyName, nil) })
    }
    
    public func start() {
        let dispatchGroup = DispatchGroup()
        for task in tasks {
            dispatchGroup.enter()
            let url = S3MediaUtils.url(with: task.keyName)
            
            var mediaNeededToFetch = true
            
            if isCachingEnabled {
                mediaNeededToFetch = !checkMediaExistOnDirectory(type: task.type, url: url)
            }
            
            if mediaNeededToFetch,
                let data = s3MediaTaskDispatcherDelegate?.s3MediaTaskWillStartToDownloadMedia(
                    dispatcher: self, mediaTask: task) {
                mediaNeededToFetch = !writeToDataUrl(materialType: task.type, data: data, url: url)
            }
            
            if mediaNeededToFetch {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {}
                
                S3MediaDownloader.downloadMedia(with: task) { [weak self] (downloadUrl, error, downloadTask) in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    strongSelf.taskCompleted(task: downloadTask, url: downloadUrl?.path, error: error)
                    dispatchGroup.leave()
                }
            } else {
                taskCompleted(task: task, url: url.path, error: nil)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.operationFinished()
        }
    }
    
    private func taskCompleted(task: S3MediaTask, url: String?, error: Error?) {
        let result = error != nil ? S3MediaResult.failure(error!) : S3MediaResult.success(S3Media(type: task.type, url: url ?? "" ))
        urlResultMap[task.keyName] = result
        s3MediaTaskDispatcherDelegate?.s3MediaTaskDispatcherDidFinishTask(dispatcher: self,
                                                                          mediaTask: task,
                                                                          result: result)
    }
    
    private func writeToDataUrl(materialType: S3MediaType, data: Data, url: URL) -> Bool {
        do {
            try data.write(to: url)
            return checkMediaExistOnDirectory(type: materialType, url: url)
        } catch {
            return false
        }
    }
    
    private func checkMediaExistOnDirectory(type: S3MediaType, url: URL) -> Bool {
        switch type {
        case .image:
            return isImageExist(imageUrl: url)
        case .video:
            return isVideoExist(videoUrl: url)
        }
    }
    
    private func isVideoExist(videoUrl: URL) -> Bool {
        return AVAsset(url: videoUrl).isPlayable
    }
    
    private func isImageExist(imageUrl: URL) -> Bool {
        return UIImage(contentsOfFile: imageUrl.path) != nil
    }
    
    private func operationFinished() {
        var medias: [S3Media] = []
        for task in tasks {
            if let result = urlResultMap[task.keyName] {
                switch result {
                case .success(let media):
                    medias.append(media)
                case .failure(let error):
                    s3MediaTaskDispatcherDelegate?.s3MediaTaskDispatcherDidCompleteFetching(dispatcher: self, dispatchedMedias: nil, error: error)
                    return
                default:
                    s3MediaTaskDispatcherDelegate?.s3MediaTaskDispatcherDidCompleteFetching(dispatcher: self, dispatchedMedias: nil, error: S3Error())
                    return
                }
            }
        }
        
        fetchedMedias = medias
        s3MediaTaskDispatcherDelegate?.s3MediaTaskDispatcherDidCompleteFetching(dispatcher: self, dispatchedMedias: medias, error: nil)
    }
}
