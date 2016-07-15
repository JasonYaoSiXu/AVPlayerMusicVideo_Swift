//
//  PlayMusicView.swift
//  LearnVideos
//
//  Created by yaosixu on 16/7/13.
//  Copyright © 2016年 Jason_Yao. All rights reserved.
//

import UIKit
import AVFoundation

class PlayMusicView : UIView {
    private let cmTime = CMTimeMake(1, 1)
    private var startTimeLabel = UILabel()
    private var sumTimeLabel = UILabel()
    
    private var sumProgress = 0.0
    private var sumTimeNum : Double?
    ///进度
    private var progress : Float = 0.0
    ///播放按钮
    private let playButton = UIButton()
    ///设置播放器
    private var avPlayMusic = AVPlayer()

    ///暂停图片
    var stopImage: UIImage!
    ///播放图片
    var playImage: UIImage!

    ///播放地址
    var musicUrlStr = " "
    
    ///判断播放状态
    var isPlay = false {
        didSet {
            if isPlay == false {
                stopCurPlay()
            } else {
                playMusic()
            }
        }
    }
    
    
    
    ///缓冲进度条
    private var loadProgress = UIProgressView()
    ///播放进度条
    private var playProgress = UISlider()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        backgroundColor = UIColor.cyanColor()
        
        playImage = UIImage(named: "播放")
        stopImage = UIImage(named: "停止")
        
        configPlayButton()
    }
    
    ///可以自定义播放、暂停按钮图片
    init(frame: CGRect, playImage: UIImage, stopImage: UIImage) {
        super.init(frame: frame)
        self.frame = frame
        backgroundColor = UIColor.cyanColor()
        
        self.playImage = playImage
        self.stopImage = stopImage
        
        configPlayButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///配置播放按钮以及进度条
    private func configPlayButton() {
        print("\(#function)")
        //播放按钮
        playButton.frame = CGRect(x: self.frame.size.width / 2 - 20, y: self.frame.size.height / 2 - 20, width: 40, height: 40)
        playButton.setImage(playImage, forState: .Normal)
        self.addSubview(playButton)
        playButton.addTarget(self, action: #selector(PlayMusicView.tapPlayButton), forControlEvents: .TouchUpInside)
        
        //缓存进度条
        loadProgress.frame = CGRect(x: 5, y: self.frame.size.height - 10, width: self.frame.size.width - 10, height: 20)
        loadProgress.trackTintColor = UIColor.blackColor()
        loadProgress.progressTintColor = UIColor.whiteColor()
        self.addSubview(loadProgress)
        
        ///播放进度条
        playProgress.frame = loadProgress.frame
        playProgress.maximumTrackTintColor = UIColor.clearColor()
        playProgress.minimumTrackTintColor = UIColor.greenColor()
//        playProgress.setThumbImage(kt_drawRectWithRoundedCorner(radius: 5, borderWidth: 0, backgroundColor: UIColor.redColor(), borderColor: UIColor.redColor(), size: CGSize(width: 10, height: 10)), forState: .Normal)
        playProgress.setThumbImage(getImage(CGSize(width: 15,height: 15), color: UIColor.redColor()).makeCircleImage(), forState: .Normal)
        playProgress.addTarget(self, action: #selector(PlayMusicView.playFasterOrSlow), forControlEvents: .TouchUpInside)
        playProgress.enabled = false
        self.addSubview(playProgress)
        
        //已经播放的时间
        startTimeLabel.frame = CGRect(x: 0, y: 0, width: 25, height: 21)
        startTimeLabel.textColor = UIColor.blackColor()
        startTimeLabel.font = UIFont(name: "Didot", size: 10)
        self.addSubview(startTimeLabel)
        
        //总时长
        sumTimeLabel.frame = CGRect(x: 75, y: 0, width: 25, height: 21)
        sumTimeLabel.textColor = UIColor.redColor()
        sumTimeLabel.font = UIFont(name: "Didot", size: 10)
        self.addSubview(sumTimeLabel)
    }
    
    ///点击按钮
   @objc private func tapPlayButton() {
    print("\(#function)")
        isPlay = !isPlay
    }
    
    ///停止播放
    private func stopCurPlay() {
        print("\(#function)")
        playButton.setImage(playImage, forState: .Normal)
        avPlayMusic.pause()
    }
    
    ///开始播放
    private func playMusic( ) {
        print("\(#function)")
        if avPlayMusic.currentItem != nil {
            playButton.setImage(stopImage, forState: .Normal)
            avPlayMusic.play()
            loadProgress.progress = Float(sumProgress)
            return
        }
        
        guard let musicUrl = NSURL(string: "http://7xq510.com1.z0.glb.clouddn.com//1465884760511676585.mp3") else {
            return
        }
        
        avPlayMusic = AVPlayer(playerItem: AVPlayerItem(URL: musicUrl))
        loadProgress.setProgress(0.0, animated: false)
        
        avPlayMusic.currentItem?.addObserver(self, forKeyPath: "status", options: .New, context: &avPlayMusic)
        avPlayMusic.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .New, context: &avPlayMusic)
        avPlayMusic.currentItem?.addObserver(self, forKeyPath: "duration", options: .New, context: &avPlayMusic)
        
        avPlayMusic.play()
        loadProgress.progress = 0.0
        playButton.setImage(stopImage, forState: .Normal)
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        guard let avPlayItem = object as? AVPlayerItem else {
            return
        }
        
        if context != &avPlayMusic {
            return
        }
        
        if keyPath == "status" {
            print("keyPath = status = \(avPlayItem.status.rawValue)")
            
            if avPlayItem.status == .ReadyToPlay {
                playProgress.enabled = true
                avPlayMusic.addPeriodicTimeObserverForInterval(cmTime, queue: nil, usingBlock: {[unowned self] _ in
                        self.updateCurPlayTime()
                })
            } else {
                print("it's not ready to play")
            }
            
        } else if keyPath == "loadedTimeRanges" {
            if self.sumProgress <  1.0 {
                updateSumLoadRange()
            }
            print("keyPath = loadedTimeRanges")
        }  else if keyPath == "duration" {
            print("avPlayItem.duration.value = \(avPlayItem.duration.value),seconde = \(avPlayItem.duration.seconds)")
            print("avPlayItem.duration.value = \(avPlayItem.duration)")
            sumTimeNum = avPlayItem.duration.seconds
            sumTimeLabel.text = calculateSumTime(sumTimeNum!)
        }
        
    }
    
    ///更新当前播放时间
    func updateCurPlayTime() {
        print("\(#function)")
        let cmTime = avPlayMusic.currentTime()
        let curSeconde = cmTime.seconds
        guard let sumTimeNum = sumTimeNum else {
            return
        }
        playProgress.setValue(Float(curSeconde / sumTimeNum), animated: true)
        progress = playProgress.value
        startTimeLabel.text = calculateSumTime(curSeconde)
//        print("curTime = \(calculateSumTime(curSeconde))")
    }
    
    ///更新总缓存
    func updateSumLoadRange() {
        let timeRange = avPlayMusic.currentItem?.loadedTimeRanges
        let loadTimeRange = timeRange?.first?.CMTimeRangeValue
        let startTime = CMTimeGetSeconds((loadTimeRange?.start)!)
        let durationTime = CMTimeGetSeconds((loadTimeRange?.duration)!)
        
        print("loadTimeRange = \(calculateSumTime(startTime + durationTime))")
        
        guard  let sumTime = sumTimeNum else {
            return
        }
        
        sumProgress = (startTime + durationTime) / sumTime
        loadProgress.setProgress(Float(sumProgress), animated: true)
//        print("\(#function):: loadProgress = \(sumProgress)")
    }
    
    
    ///将秒数转为 时:分:秒 格式
    func calculateSumTime(sumSeconde: Double) -> String {
        let date = NSDate(timeIntervalSince1970: sumSeconde)
        let forMat = NSDateFormatter()
        if sumSeconde >= 3600 {
            forMat.dateFormat = "HH:mm:ss"
        } else {
            forMat.dateFormat = "mm:ss"
        }
        return forMat.stringFromDate(date)
    }
    
    ///快进、快退
    func playFasterOrSlow() {
        print("\(#function)")
        if avPlayMusic.status != .ReadyToPlay {
            return
        }
        
        print("playProgress = \(playProgress.value)")
        
        guard let sumCMTime = sumTimeNum else {
            return
        }
        
        let seekTime = CMTime(value: Int64(Float(sumCMTime) * playProgress.value), timescale: 1)
        avPlayMusic.seekToTime(seekTime)
    }
    
}

func getImage(size: CGSize, color: UIColor) -> UIImage {
    
    let rect = CGRectMake(0, 0, size.width, size.height)

    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
}



extension UIImage {
    
    /// 截取
    func makeCircleImage() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        CGContextAddPath(UIGraphicsGetCurrentContext(), UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: size.width, height: size.height)).CGPath)
        CGContextClip(UIGraphicsGetCurrentContext())
        
        self.drawInRect(rect) 
        CGContextDrawPath(UIGraphicsGetCurrentContext(), .FillStroke)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}


//重新绘制
func kt_drawRectWithRoundedCorner(radius radius: CGFloat,
                                         borderWidth: CGFloat,
                                         backgroundColor: UIColor,
                                         borderColor: UIColor,size: CGSize) -> UIImage {
    let sizeToFit = CGSize(width: (Double(size.width)), height: Double(size.height))
    let halfBorderWidth = CGFloat(borderWidth / 2.0)
    
    UIGraphicsBeginImageContextWithOptions(sizeToFit, false, UIScreen.mainScreen().scale)
    let context = UIGraphicsGetCurrentContext()
    
    CGContextSetLineWidth(context, borderWidth)
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor)
    
    let width = sizeToFit.width, height = sizeToFit.height
    CGContextMoveToPoint(context, width - halfBorderWidth, radius + halfBorderWidth)  // 开始坐标右边开始
    CGContextAddArcToPoint(context, width - halfBorderWidth, height - halfBorderWidth, width - radius - halfBorderWidth, height - halfBorderWidth, radius)  // 右下角角度
    CGContextAddArcToPoint(context, halfBorderWidth, height - halfBorderWidth, halfBorderWidth, height - radius - halfBorderWidth, radius) // 左下角角度
    CGContextAddArcToPoint(context, halfBorderWidth, halfBorderWidth, width - halfBorderWidth, halfBorderWidth, radius) // 左上角
    CGContextAddArcToPoint(context, width - halfBorderWidth, halfBorderWidth, width - halfBorderWidth, radius + halfBorderWidth, radius) // 右上角
    
    CGContextDrawPath(UIGraphicsGetCurrentContext(), .FillStroke)
    let output = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return output
}




/*
 ///play status
 @objc private func playStatus() {
 print("\(#function)")
 switch avPlayMusic.status {
 case .Failed:
 self.hideToastActivity()
 self.makeToast("加载失败", duration: 1.5, position: .Center)
 case .ReadyToPlay:
 print("准备播放")
 self.makeToast("正在播放", duration: 0.5, position: .Center)
 avPlayMusic.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .New, context: nil)
 times.invalidate()
 //            times = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(PlayMusicView.progressing), userInfo: nil, repeats: true)
 //            times.fire()
 caculateTime()
 case .Unknown:
 self.makeToast("正在加载", duration: 1, position: .Center)
 }
 
 }
 
 
 //        guard let musicUrl = NSURL(string:musicUrlStr) else {
 //            isPlay = !isPlay
 //            self.makeToast("播放失败请重试!", duration: 0.5, position: .Center)
 //            return
 //        }
 
 
 ///progress Animation
 @objc private func progressing() {
 print("\(#function)")
 guard let ctTime = avPlayMusic.currentItem?.duration else {
 times.invalidate()
 return
 }
 
 let timeRange = avPlayMusic.currentItem?.loadedTimeRanges
 let loadTimeRange = timeRange?.first?.CMTimeRangeValue
 let startSeconds = CMTimeGetSeconds(loadTimeRange!.start);
 let durationSeconds = CMTimeGetSeconds(loadTimeRange!.duration);
 
 //        print("huanchong jindu  = \(startSeconds + durationSeconds )")
 
 //        let ss = NSTimeInterval((ctTime.value) / Int64(ctTime.timescale))
 //
 //        let d = NSDate(timeIntervalSince1970: ss)
 //        let format = NSDateFormatter()
 //
 //        if ss / 3600 >= 1 {
 //            format.dateFormat = "HH:mm:ss"
 //        } else {
 //            format.dateFormat = "mm:ss"
 //        }
 //
 //        print("showTime = \(format.stringFromDate(d))")
 
 let sumTime = CMTimeGetSeconds(ctTime)
 let currTime = CMTimeGetSeconds(avPlayMusic.currentTime())
 let pro = Float(currTime / sumTime)
 progress = pro
 
 //        print("currTime = \(currTime) , sumTime = \(sumTime)")
 
 playProgress.setProgress( pro, animated: true)
 
 if pro >= 1.0 {
 times.invalidate()
 }
 }
 
 //    func caculateTime() {
 //        avPlayMusic.addPeriodicTimeObserverForInterval(cmTime, queue: nil, usingBlock: {
 //            print("$0 = \($0) 播放进度")
 //        })
 //        avPlayMusic.addBoundaryTimeObserverForTimes([NSValue(CMTime:  cmTime)], queue: nil, usingBlock: {
 //            let timeRange = self.avPlayMusic.currentItem?.loadedTimeRanges
 //            let loadTimeRange = timeRange?.first?.CMTimeRangeValue
 //            let startSeconds = CMTimeGetSeconds(loadTimeRange!.start)
 //            let durationSeconds = CMTimeGetSeconds(loadTimeRange!.duration)
 //            print("总缓冲 = \(startSeconds + durationSeconds )")
 //        })
 //    }
 
 */
