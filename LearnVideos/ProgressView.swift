//
//  Progress.swift
//  LearnVideos
//
//  Created by yaosixu on 16/7/14.
//  Copyright © 2016年 Jason_Yao. All rights reserved.
//

import UIKit
import AVFoundation

class ProgressView : UIView {
    private var sumPlayTime : Double?
    private let cmTime = CMTimeMake(1, 1)
    //播放进度条
    private let playSlider = UISlider()
    //缓冲进度条
    private let loadProgress = UIProgressView()
    //已经播放的时间
    private let playedTimeLabel = UILabel()
    //总的时间
    private let sumPlayTimeLabel = UILabel()
    //音频视频播放器
    private var avPlayer = AVPlayer()
    private var avPlayItem : AVPlayerItem!
    private var playerLayer : AVPlayerLayer?
    
    private let height: CGFloat = 20
    
    class var PlayInstall : ProgressView {
        struct Singleton {
            static let instance = ProgressView()
        }
        return Singleton.instance
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.grayColor()
        self.frame = frame
//        addAVPlayer()
        addLoadProgress()
        addPlayProgress()
        addTimeLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //添加播放器
    private func addAVPlayer() {
        
        playerLayer = AVPlayerLayer(player: avPlayer)
        playerLayer!.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: frame.size.height - 3 * height)
        playerLayer!.backgroundColor = UIColor.blackColor().CGColor
        print("\(#function) \(playerLayer!.videoRect))")
        self.layer.addSublayer(playerLayer!)
    }
    
    //添加缓冲进度条
    private func addLoadProgress() {
        loadProgress.frame = CGRect(x: 3, y: frame.size.height - 2 * height, width: self.frame.width - 10, height: 2 * height)
        //已缓存的进度
        loadProgress.progressTintColor = UIColor.whiteColor()
        //全部缓存
        loadProgress.trackTintColor = UIColor.darkGrayColor()
        
        addSubview(loadProgress)
    }
    
    //添加播放进度条
    private func addPlayProgress() {
        playSlider.frame = loadProgress.frame
        playSlider.frame.origin.x -= 3
        playSlider.frame.size.width += 5
        
        //已播放的进度颜色
        playSlider.minimumTrackTintColor = UIColor.greenColor()
        //全部进度颜色
        playSlider.maximumTrackTintColor = UIColor.clearColor()
        playSlider.addTarget(self, action: #selector(ProgressView.controlPlayProgress), forControlEvents: .TouchUpInside)
        
        addSubview(playSlider)
    }
    
    //添加已经播放的时间和视频活着音频的时间总长度
    private func addTimeLabel() {
        playedTimeLabel.frame = CGRect(x: 10, y: frame.size.height - height, width: frame.size.width / 5, height: height)
        playedTimeLabel.font = UIFont(name: "Didot", size: 13)
        playedTimeLabel.backgroundColor = UIColor.clearColor()
        playedTimeLabel.textColor = UIColor.whiteColor()
        playedTimeLabel.text = "00:00"
        playedTimeLabel.sizeToFit()
        addSubview(playedTimeLabel)
        
        sumPlayTimeLabel.frame = CGRect(x: frame.size.width - playedTimeLabel.bounds.width - 10, y: frame.size.height - height, width: frame.size.width / 5, height: height)
        sumPlayTimeLabel.font = UIFont(name: "Didot", size: 13)
        sumPlayTimeLabel.backgroundColor = UIColor.clearColor()
        sumPlayTimeLabel.textColor = UIColor.whiteColor()
        sumPlayTimeLabel.text = "00:00"
        sumPlayTimeLabel.sizeToFit()
        addSubview(sumPlayTimeLabel)
    }
    
    //添加播放地址后开始播放
    func initToPlay(playAddress: String, playType: PlayType) {
        print("\(#function)")
        guard let playUrl = NSURL(string: playAddress) else {
            return
        }
        
        avPlayItem = AVPlayerItem(URL: playUrl)
        avPlayer = AVPlayer(playerItem: avPlayItem)
        if playType == .Video {
            addAVPlayer()
        }
        avPlayItem.addObserver(self, forKeyPath: "status", options: .New, context: &avPlayItem)
        avPlayItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .New, context: &avPlayItem)
        avPlayItem.addObserver(self, forKeyPath: "duration", options: .New, context: &avPlayItem)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProgressView.playEnd), name: AVPlayerItemDidPlayToEndTimeNotification, object: avPlayItem)
        avPlayer.play()
    }
    
    //添加kvo
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context != &avPlayItem {
            return
        }
        
        guard let avPlayItem = object as? AVPlayerItem else {
            return
        }
        
        if keyPath == "status" {
            switch avPlayItem.status {
            case .Failed:
                print("\(#function)::play Failed")
            case .ReadyToPlay:
                print("\(#function)::ReadyToPlay")
                avPlayer.addPeriodicTimeObserverForInterval(cmTime, queue: nil, usingBlock: { [unowned self] _ in
                    self.cucalatePlay()
                })
            case .Unknown:
                print("\(#function)::Unknown Error")
            }
        } else if keyPath == "loadedTimeRanges" {
            cucalateLoad()
        } else if keyPath == "duration" {
            print("\(#function)::duration")
            sumPlayTime = avPlayItem.duration.seconds
            sumPlayTimeLabel.text = transFormDateFromSeconde(sumPlayTime!)
        }
        
    }
    
    //把播放时间的长度从秒数转为 00:00:00
    private func transFormDateFromSeconde(seconde: Double) -> String {
        let date = NSDate(timeIntervalSince1970: seconde)
        let dateFormat = NSDateFormatter()
        
        if seconde >= 3600 {
            dateFormat.dateFormat = "HH:mm:ss"
            return dateFormat.stringFromDate(date)
        } else {
            dateFormat.dateFormat = "mm:ss"
            return dateFormat.stringFromDate(date)
        }
    }
    
    //计算播放进度
    func cucalatePlay() {
        playedTimeLabel.text = transFormDateFromSeconde(avPlayer.currentTime().seconds)
        
        if sumPlayTime != nil {
            playSlider.value = Float(avPlayer.currentTime().seconds / sumPlayTime!)
        }
    }
    
    //计算缓冲进度
    func cucalateLoad() {
        print("\(#function)")
        if sumPlayTime != nil {

            let timeRange = avPlayItem.loadedTimeRanges
            let loadTimeRange = timeRange.first?.CMTimeRangeValue
            let startTime = CMTimeGetSeconds((loadTimeRange?.start)!)
            let durationTime = CMTimeGetSeconds((loadTimeRange?.duration)!)

            loadProgress.setProgress(Float( Double(startTime + durationTime) / sumPlayTime!), animated: true)
        }
    }
    
    //控制播放进度
    func controlPlayProgress() {
        if sumPlayTime != nil {
            let cmTime = CMTime(value: Int64(sumPlayTime! * Double(playSlider.value)), timescale: 1)
            avPlayItem.seekToTime(cmTime)
        }
    }
    
    //播放结束
    @objc private func playEnd() {
        print("\(#function)")
        avPlayItem.removeObserver(self, forKeyPath: "status")
        avPlayItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
        avPlayItem.removeObserver(self, forKeyPath: "duration")
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        if playerLayer != nil {
            self.layer.sublayers?.forEach({
                if $0.isKindOfClass(AVPlayerLayer) {
                    $0.removeFromSuperlayer()
                    return
                }
            })
            playerLayer = nil
        }
    }
    
}


//func makeImage(size: CGSize, color: UIColor) -> UIImage {
//    
//    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//
//    UIGraphicsBeginImageContextWithOptions(size, false, 0)
//    UIRectFill(rect)
//    color.setFill()
//    let image = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//    
//    return image
//}
//
//extension UIImage {
//    
//    func addCircle() -> UIImage {
//        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//        
//        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
//        
//        CGContextAddPath(UIGraphicsGetCurrentContext(), UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: size.width, height: size.height)).CGPath)
//        CGContextClip(UIGraphicsGetCurrentContext())
//        
//        self.drawInRect(rect)
//        CGContextDrawPath(UIGraphicsGetCurrentContext(), .FillStroke)
//        
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return image
//    }
//    
//}
//
