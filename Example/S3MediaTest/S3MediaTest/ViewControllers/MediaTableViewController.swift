//
//  MediaTableViewController.swift
//  S3MediaTest
//
//  Created by Erdi on 30.06.2020.
//  Copyright © 2020 *. All rights reserved.
//

import UIKit

class MediaTableViewController: UITableViewController {
    
    var dispatchers: [S3MediaTaskDispatcher] = []
    var cellCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: S3MediaTableViewCell.self),
                                 bundle: Bundle.main),
                           forCellReuseIdentifier: String(describing: S3MediaTableViewCell.self))
        
        let tasksList = DataProvider.tableViewCells()
        cellCount = tasksList.count
        
        for i in 0..<tasksList.count {
            let dispatcher = S3MediaTaskDispatcher(mediaTasks: tasksList[i], groupId: "\(i)")
            dispatcher.s3MediaTaskDispatcherDelegate = self
            dispatchers.append(dispatcher)
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: S3MediaTableViewCell.self)) as! S3MediaTableViewCell
        
        let dispatcher = dispatchers[indexPath.row]
        
        if dispatcher.state == .notStarted {
            dispatcher.start()
        } else if dispatcher.state == .completed {
            cell.medias = dispatcher.fetchedMedias
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! S3MediaTableViewCell
        
        if let mediaView = cell.mediaView, cell.medias != nil {
            mediaView.stopAll = false
            cell.mediaView.muted = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cell = cell as! S3MediaTableViewCell

        if let mediaView = cell.mediaView {
            mediaView.stopAll = true
        }
    }
}

extension MediaTableViewController: S3MediaTaskDispatcherDelegate {
    func s3MediaTaskDispatcherDidCompleteFetching(dispatcher: S3MediaTaskDispatcher, dispatchedMedias: [S3Media]?, error: Error?) {
        
        if error != nil, let dispatcher = dispatchers.first(where: { $0.groupId == dispatcher.groupId }) {
            dispatcher.state = .notStarted
            dispatcher.start()
            return
        }
        
        if let index = Int(dispatcher.groupId),
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? S3MediaTableViewCell {
            DispatchQueue.main.async {
                cell.medias = dispatchedMedias
            }
        }
    }
    
    func s3MediaTaskDispatcherDidFinishTask(dispatcher: S3MediaTaskDispatcher, mediaTask: S3MediaTask, result: S3MediaResult) {
        
    }
    
    func s3MediaTaskWillStartToDownloadMedia(dispatcher: S3MediaTaskDispatcher, mediaTask: S3MediaTask) -> Data? {
        return nil
    }
}
