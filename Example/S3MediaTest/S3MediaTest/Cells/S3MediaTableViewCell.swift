//
//  S3MediaTableViewCell.swift
//  S3MediaTest
//
//  Created by Erdi on 29.06.2020.
//  Copyright © 2020 *. All rights reserved.
//

import UIKit

final class S3MediaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mediaView: S3MediaView!
    @IBOutlet weak var pageLabel: UILabel!
    
    var medias: [S3Media]? {
        didSet {
            mediaView.medias = medias
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension S3MediaTableViewCell: S3MediaViewDelegate {
    
    func mediaViewPageDidChange(mediaView: S3MediaView, currentMedia: S3Media, pageIndex: Int) {
        
    }
    
    func mediaViewAddSubview(mediaView: S3MediaView, for pageIndex: Int) -> UIView? {
        let innerView = UIView()
        innerView.frame = CGRect(x: 0,
                                 y: mediaView.bounds.height - 50,
                                 width: mediaView.bounds.width,
                                 height: 50)
        innerView.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        return innerView
    }
}
