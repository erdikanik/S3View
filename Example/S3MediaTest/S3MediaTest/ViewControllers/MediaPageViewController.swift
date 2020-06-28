//
//  MediaPageViewController.swift
//  S3MediaTest
//
//  Created by Erdi on 28.06.2020.
//  Copyright © 2020 *. All rights reserved.
//

import UIKit

class MediaPageViewController: UIViewController {
    
    @IBOutlet weak var mediaView: S3MediaView!
    private var mediaDispatcher: S3MediaTaskDispatcher?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tasks = DataProvider.mediaPageTasks()
        mediaDispatcher = S3MediaTaskDispatcher(mediaTasks: tasks, groupId: "")
        mediaDispatcher?.s3MediaTaskDispatcherDelegate = self
        mediaDispatcher?.isCachingEnabled = false
        mediaDispatcher?.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        mediaView.stopAll = true
    }
}

extension MediaPageViewController: S3MediaTaskDelegate {
    func s3MediaTaskDispatcherDidCompleteFetching(dispatcher: S3MediaTaskDispatcher,
                                                  dispatchedMedias: [S3Media]?, error: Error?) {
        if error == nil {
            DispatchQueue.main.async {
                self.mediaView.medias = dispatchedMedias
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        } else {
            // Problem is occured
        }
    }
    
    func s3MediaTaskDispatcherDidFinishTask(dispatcher: S3MediaTaskDispatcher, mediaTask: S3MediaTask, result: S3MediaResult) {
        switch result {
        case .failure(let error):
            print("Error occured: \(error)")
        default:
            break
        }
    }
    
    func s3MediaTaskWillStartToDownloadMedia(dispatcher: S3MediaTaskDispatcher, mediaTask: S3MediaTask) -> Data? {
        // If we have data, dispatcher doesn't need to dispatch data from s3 for task
        return nil
    }
}

extension MediaPageViewController: S3MediaViewDelegate {
    func mediaViewPageDidChange(mediaView: S3MediaView, currentMedia: S3Media, pageIndex: Int) {
        
    }
    
    func mediaViewAddSubview(mediaView: S3MediaView, for pageIndex: Int) -> UIView? {
        return nil
    }
}
