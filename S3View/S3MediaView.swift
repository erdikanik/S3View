//
//  S3MediaView.swift
//  KomsudaPisti
//
//  Created by Erdi on 23.06.2020.
//  Copyright © 2020 Komsuda. All rights reserved.
//

import UIKit
import AVFoundation

public protocol S3MediaViewDelegate: class {
    
    func mediaViewPageDidChange(mediaView: S3MediaView, currentMedia: S3Media, pageIndex: Int)
    func mediaViewAddSubview(mediaView: S3MediaView, for pageIndex: Int) -> UIView?
}

public class S3MediaView: UIView {
    
    public weak var delegate: S3MediaViewDelegate?
    public var pageControlBottomMargin = CGFloat(12)
    public let pageControl:UIPageControl = UIPageControl()
    
    private let scrollview:UIScrollView = UIScrollView()
    private var players:[AVPlayer] = [AVPlayer]()
    
    var playerItems:[AVPlayerItem]?
    
    public var stopAll:Bool = false {
        didSet {
            players.forEach { player in
                player.seek(to: .zero)
                player.pause()
                
                if !stopAll {
                    guard let media = medias?[pageControl.currentPage] else {
                        return
                    }
                    
                    if media.type == .video {
                        if player == players[currentPlayerIndex(index: pageControl.currentPage)] {
                            player.play()
                        }
                    }
                }
            }
        }
    }
    
    public var muted: Bool {
        get {
            guard let currentMedia = currentMedia,
                currentMedia.type == .video else {
                    return true
            }
            
            return currentMediaPlayer()?.isMuted ?? true
        }
        
        set {
            
            players.forEach { $0.isMuted = true }
            
            if !newValue, let currentPlayer = currentMediaPlayer() {
                currentPlayer.isMuted = false
            }
        }
    }
    
    public var medias:[S3Media]? {
        
        didSet {
            scrollview.subviews.forEach { $0.removeFromSuperview() }
            playerItems = nil
            players = [AVPlayer]()
            
            pageControl.hidesForSinglePage = true
            
            if let medias = medias {
                
                layoutIfNeeded()
                layoutSubviews()
                
                pageControl.numberOfPages = medias.count
                pageControl.currentPage = 0
                
                initializePlayerItems()
                setContentScrollView()
                
                selectedPage = 0
                setNeedsLayout()
                layoutSubviews()
            }
        }
    }
    
    public var selectedPage:Int? {
        
        didSet {
            guard let selectedPage = selectedPage else {
                return
            }
            
            pageControl.currentPage = selectedPage
            stopPlayer()
        }
    }
    
    public var currentMedia: S3Media? {
        guard let medias = medias, let selectedPage = selectedPage else {
            return nil
        }
        
        return medias[selectedPage]
    }
    
    public override func awakeFromNib() {
        
        super.awakeFromNib()
        initializeViews()
    }
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()
    }
}

// MARK: Media View

private extension S3MediaView {
    
    func create(media:S3Media, index:Int) -> UIView? {
        
        let x:CGFloat = CGFloat(index) * bounds.width
        let frame = CGRect(x: x, y: 0, width: bounds.width, height: bounds.height)
        
        switch media.type {
        case .image:
            
            let imageView = UIImageView(frame: frame)
            imageView.image = UIImage(contentsOfFile: media.url)
            
            return imageView
        case .video:
            
            let videoBackground = UIView(frame: frame)
            
            let playerItem = playerItems?[currentPlayerIndex(index: index)]
            let player = AVPlayer(playerItem: playerItem)
            
            players.append(player)
            
            if index == 0 {
                player.play()
            } else {
                player.pause()
            }
            
            let playerLayer = AVPlayerLayer(player: player)
            
            playerLayer.frame = bounds
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            videoBackground.layer.addSublayer(playerLayer)
            return videoBackground
        }
    }
}

// MARK: ScrollView

fileprivate extension S3MediaView {
    
    func setContentScrollView() {
        
        guard let medias = medias else {
            return
        }
        
        let horizontalContentSize = CGFloat(medias.count) * bounds.width
        scrollview.contentSize = CGSize(width: horizontalContentSize, height: bounds.height)
        
        for i in 0 ..< medias.count {
            if let view = create(media: medias[i], index: i) {
                scrollview.addSubview(view)
                
                if let view = delegate?.mediaViewAddSubview(mediaView: self, for: i) {
                    scrollview.addSubview(view)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: nil, queue: nil) { [weak self] notification in
                guard let players = self?.players, players.count > 0, let stopAll = self?.stopAll else {
                    return
                }
                
                if !stopAll, let currentPage = self?.pageControl.currentPage,
                    let index = self?.currentPlayerIndex(index: currentPage), index != NSNotFound {
                    
                    let player = players[index]
                    
                    player.seek(to: CMTime.zero)
                    player.play()
                }
        }
    }
}


// MARK: - Player

private extension S3MediaView {
    
    func initializePlayerItems() {
        guard let medias = medias else {
            return
        }
        
        playerItems = [AVPlayerItem]()
        
        medias.forEach {
            if $0.type == .video {
                let url = URL(fileURLWithPath: $0.url)
                let playerItem = AVPlayerItem(url: url)
                
                playerItems?.append(playerItem)
            }
        }
    }
}

// MARK: Helpers
private extension S3MediaView {
    
    func stopPlayer() {
        players.forEach {
            $0.seek(to: .zero)
            $0.pause()
        }
    }
    
    func currentPlayerIndex(index: Int) -> Int {
        
        guard let medias = medias else {
            return NSNotFound
        }
        
        var playerIndex = 0
        
        for i in 0 ..< medias.count {
            
            if i == index {
                
                return playerIndex
            }
            
            let media = medias[i]
            
            if media.type == .video {
                playerIndex += 1
            }
        }
        
        return NSNotFound
    }
    
    func setMedia(selectedPage: Int) {
        
        guard let medias = medias else {
            return
        }
        
        pageControl.currentPage = selectedPage
        stopPlayer()
        
        let media: S3Media = medias[selectedPage]
        if (media.type == .video) {
            let player = players[currentPlayerIndex(index: selectedPage)]
            player.play()
        }
        
        if let delegate = delegate {
            delegate.mediaViewPageDidChange(mediaView: self, currentMedia: media, pageIndex: pageControl.currentPage)
        }
    }
}

// MARK: Initialize Views
private extension S3MediaView {
    
    func initializeViews() {
        
        setScrollViewConstraints()
        setScrollViewProperties()
        setPageControlConstraints()
    }
    
    func setScrollViewConstraints() {
        
        addSubview(scrollview)
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        
        scrollview.widthAnchor.constraint(equalTo: widthAnchor, multiplier:1).isActive = true
        scrollview.heightAnchor.constraint(equalTo: heightAnchor, multiplier:1).isActive = true
        scrollview.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        scrollview.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func setScrollViewProperties() {
        
        scrollview.isPagingEnabled = true
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.bounces = false
        
        scrollview.delegate = self
    }
    
    func setPageControlConstraints() {
        
        addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        pageControl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: pageControlBottomMargin).isActive = true
        
        pageControl.currentPage = 0
    }
    
    func currentMediaPlayer() -> AVPlayer? {
        guard let currentPage = selectedPage else {
            return nil
        }
        
        let index = currentPlayerIndex(index: currentPage)
        
        if index == NSNotFound {
            return nil
        }
        
        return players[index]
    }
}


// MARK: - UIScrollViewDelegate

extension S3MediaView: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollview.frame.width
        let currentPage = floor(((scrollView.contentOffset.x - width / 2) / width)) + 1
        
        setMedia(selectedPage: Int(currentPage))
    }
}
