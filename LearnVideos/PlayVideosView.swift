//
//  PlayVideosView.swift
//  LearnVideos
//
//  Created by yaosixu on 16/7/13.
//  Copyright © 2016年 Jason_Yao. All rights reserved.
//

import UIKit
import AVFoundation

class PlayVideoView : UIView {
    
    private var avPlayer = AVPlayer()
    
    var videoUrl = "https://dn-boxue-free-video.qbox.me/switch-hd-1de6b253b59616d8b0d694ec7e5ca82f.mp4"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        configVideoPlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configVideoPlayer() {
        
        guard let video = NSURL(string: self.videoUrl) else {
            return
        }
        avPlayer = AVPlayer(URL: video)
        let playerLayer = AVPlayerLayer(player: avPlayer)
        playerLayer.frame = self.frame
        self.layer.addSublayer(playerLayer)
        
        avPlayer.pause()
    }
    
    func palyVideo (videoUrl: String) {
        guard let video = NSURL(string: videoUrl) else {
            print("\(#function)")
            return
        }
        
        print("video = \(video)")
        
        avPlayer.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: video))
        
        avPlayer.play()
    }
    
}
