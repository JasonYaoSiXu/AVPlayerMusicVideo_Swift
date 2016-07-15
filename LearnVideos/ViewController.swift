//
//  ViewController.swift
//  LearnVideos
//
//  Created by yaosixu on 16/7/13.
//  Copyright © 2016年 Jason_Yao. All rights reserved.
//

import UIKit
import AVFoundation
//import Toast_Swift
//import AVKit
//import RxSwift
//import RxCocoa

enum PlayType: Int {
    case Music = 0
    case Video = 1
}

class ViewController: UIViewController {
//    private let playAddress = ["https://dn-boxue-free-video.qbox.me/struct-hd-ccc5b4d527b725b18831a56166414c91.mp4","http://7xq510.com1.z0.glb.clouddn.com//1465884760511676585.mp3"]
    private let playAddress = ["https://dn-boxue-free-video.qbox.me/struct-hd-ccc5b4d527b725b18831a56166414c91.mp4","https://dn-boxue-free-video.qbox.me/struct-hd-ccc5b4d527b725b18831a56166414c91.mp4"]
    private let playButton = UIButton()
    private let buttonWidth: CGFloat = 100.0
    private let buttonHeight: CGFloat = 21.0
    var proView = ProgressView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PlayMusic"
        view.backgroundColor = UIColor.whiteColor()
        // Do any additional setup after loading the view, typically from a nib.
        
        proView = ProgressView(frame: CGRect(x: 0, y: 70, width: view.frame.size.width, height: 200))
        view.addSubview(proView)
        
        playButton.frame = CGRect(x: (view.frame.size.width - buttonWidth) / 2, y: view.frame.size.height / 2 - buttonHeight / 2, width: buttonWidth, height: buttonHeight)
        playButton.setTitle("Play", forState: .Normal)
        playButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        view.addSubview(playButton)
        playButton.addTarget(self, action: #selector(ViewController.tapPlayButton), forControlEvents: .TouchUpInside)
        
//        playMusic()
//        playVideo()
//        playVideoTwo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///点击播放按钮
    func tapPlayButton() {
        let randNumber = random() % playAddress.count
        print("\(#function):: randNumber = \(randNumber)")
        let urlStr = playAddress[randNumber]
        proView.initToPlay(urlStr, playType: playSwitch(urlStr))
    }
    
    ///选择播放类型
    func playSwitch(urlStr: String) -> PlayType {
        if urlStr.hasSuffix(".mp4") {
            return .Video
        } else {
            return .Music
        }
    }
    
}


/*
 //AVFoundation
 func playMusic() {
 let playMusic = PlayMusicView(frame: CGRect(x: view.frame.size.width / 2 - 50, y: view.frame.size.height / 2 - 35, width: 100, height: 70))
 //        let playMusic = PlayMusicView()
 view.addSubview(playMusic)
 }
 
 //AVFoundation
 func playVideo() {
 let playVideo = PlayVideoView(frame: CGRect(x: 0, y: 100, width: view.frame.size.width, height: 300))
 view.addSubview(playVideo)
 playVideo.palyVideo("https://dn-boxue-free-video.qbox.me/struct-hd-ccc5b4d527b725b18831a56166414c91.mp4")
 }
 
 //AVKit
 func playVideoTwo() {
 
 guard let videoUrl = NSURL(string: "https://dn-boxue-free-video.qbox.me/struct-hd-ccc5b4d527b725b18831a56166414c91.mp4") else {
 return
 }
 
 let player = AVPlayer(URL: videoUrl)
 
 let playVC = AVPlayerViewController()
 playVC.player = player
 
 self.presentViewController(playVC, animated: true, completion: nil)
 playVC.showsPlaybackControls = false
 playVC.view.frame = view.frame
 playVC.player?.play()
 }
 */
