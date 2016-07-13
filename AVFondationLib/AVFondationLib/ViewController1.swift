//
//  ViewController1.swift
//  AVFondationLib
//
//  Created by 宛越 on 16/7/8.
//  Copyright © 2016年 yuewan. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController1: UIViewController {

    var docUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    var playLayer:AVPlayerLayer?
    
    var playContext = 0;
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(frame: CGRect(x: 20, y: 50, width: 90, height: 30))
        button.addTarget(self, action: #selector(ViewController1.playMovie), forControlEvents: UIControlEvents.TouchUpInside)
        button.setTitle("播放/停止", forState: UIControlState.Normal)
        button.backgroundColor = UIColor.blueColor()
        
        let button1 = UIButton(frame: CGRect(x: 120, y: 50, width: 90, height: 30))
        button1.addTarget(self, action: #selector(ViewController1.combainVideo), forControlEvents: UIControlEvents.TouchUpInside)
        button1.setTitle("视频合并", forState: UIControlState.Normal)
        button1.backgroundColor = UIColor.blueColor()
        
        self.view.addSubview(button)
        self.view.addSubview(button1)
    }
    
    func combainVideo(){
        
        let url = docUrl.URLByAppendingPathComponent("test.mp4")
        let asset = AVAsset(URL: url)
        
        let url1 = docUrl.URLByAppendingPathComponent("test1.mp4")
        let asset1 = AVAsset(URL: url1)
        
        //Creating the Composition
        
        let composition = AVMutableComposition()
        
        let compositionVideoTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        let compositionAudioTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let firstVideoAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo).first
        let anotherVideoAssetTrack = asset1.tracksWithMediaType(AVMediaTypeVideo).first
        
        if firstVideoAssetTrack == nil || anotherVideoAssetTrack == nil {
            print("为空")
            return;
        }
        let firstAudioAssetTrack = asset.tracksWithMediaType(AVMediaTypeAudio).first
        let anotherAudioAssetTrack = asset1.tracksWithMediaType(AVMediaTypeAudio).first
        
        if firstAudioAssetTrack == nil || anotherAudioAssetTrack == nil {
            print("为空")
            return;
        }
        
        /*-----------------Adding the Assets--------------------*/
        do {
            try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack!.timeRange.duration), ofTrack: firstVideoAssetTrack!, atTime: kCMTimeZero)
            try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, anotherVideoAssetTrack!.timeRange.duration), ofTrack: anotherVideoAssetTrack!, atTime: firstVideoAssetTrack!.timeRange.duration)
            
            
            try compositionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstAudioAssetTrack!.timeRange.duration), ofTrack: firstAudioAssetTrack!, atTime: kCMTimeZero)
            try compositionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, anotherAudioAssetTrack!.timeRange.duration), ofTrack: anotherAudioAssetTrack!, atTime: firstAudioAssetTrack!.timeRange.duration)
            
        } catch let error as NSError {
            print(error)
            return
        }
        
        /*-----------------------Checking the Video Orientations--------------------*/
        var isFirstVideoAssetPortrait = false;
        let firstTransform = firstVideoAssetTrack?.preferredTransform;
        if (firstTransform?.a==0 && firstTransform?.d==0 && ( firstTransform?.b == 1 || firstTransform?.b == -1) && ( firstTransform?.c == 1 || firstTransform?.c == -1) ) {
            isFirstVideoAssetPortrait = true;
        }
        let anotherTransform = anotherVideoAssetTrack?.preferredTransform;
        var isAnotherVideoPortrait = false;
        if (anotherTransform?.a==0 && anotherTransform?.d==0 && ( anotherTransform?.b == 1 || anotherTransform?.b == -1) && ( anotherTransform?.c == 1 || anotherTransform?.c == -1) ) {
            isAnotherVideoPortrait = true;
        }
        if ((isFirstVideoAssetPortrait && !isAnotherVideoPortrait)||(!isFirstVideoAssetPortrait && isAnotherVideoPortrait)){
            print("出错")
        }
      
//        AVMutableAudioMix()
        
        /*-----------------Applying the Video Composition Layer Instructions--------------------*/
        let firstVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        firstVideoCompositionInstruction.timeRange =  CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack!.timeRange.duration)
        
//        CMTimeRangeMake(firstVideoAssetTrack.timeRange.duration, CMTimeAdd(firstVideoAssetTrack.timeRange.duration, secondVideoAssetTrack.timeRange.duration));
        
        let anotherVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        anotherVideoCompositionInstruction.timeRange = CMTimeRangeMake(firstVideoAssetTrack!.timeRange.duration, CMTimeAdd(firstVideoAssetTrack!.timeRange.duration, anotherVideoAssetTrack!.timeRange.duration))
        
        
        let firstVideoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        firstVideoLayerInstruction.setOpacityRampFromStartOpacity(1.0, toEndOpacity: 0.0, timeRange: CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack!.timeRange.duration))
        firstVideoLayerInstruction.setTransform(anotherTransform!, atTime: kCMTimeZero)
        
        let anotherVideoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        firstVideoLayerInstruction.setTransform(anotherTransform!, atTime: firstVideoAssetTrack!.timeRange.duration)
        
//        secondVideoLayerInstruction setTransform:secondTransform atTime:firstVideoAssetTrack.timeRange.duration];
        
        
        
        firstVideoCompositionInstruction.layerInstructions = [firstVideoLayerInstruction]
        anotherVideoCompositionInstruction.layerInstructions = [anotherVideoLayerInstruction]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.instructions = [firstVideoCompositionInstruction,anotherVideoCompositionInstruction];
        
        /*----------Setting the Render Size and Frame Duration---------*/
        var naturalSizeFirst:CGSize? = nil
        var naturalSizeSecond:CGSize? = nil
        
        if (isFirstVideoAssetPortrait) {
            // Invert the width and height for the video tracks to ensure that they display properly.
            naturalSizeFirst = CGSizeMake(firstVideoAssetTrack!.naturalSize.height, firstVideoAssetTrack!.naturalSize.width);
            naturalSizeSecond = CGSizeMake(anotherVideoAssetTrack!.naturalSize.height, anotherVideoAssetTrack!.naturalSize.width);
        } else {
            naturalSizeFirst = firstVideoAssetTrack?.naturalSize
            naturalSizeSecond = anotherVideoAssetTrack?.naturalSize
        }
        var renderWidth:CGFloat?
        var renderHeight:CGFloat?
        if (naturalSizeFirst!.width > naturalSizeSecond!.width) {
            renderWidth = naturalSizeFirst!.width;
        } else {
            renderWidth = naturalSizeSecond!.width;
        }
        if (naturalSizeFirst!.height > naturalSizeSecond!.height) {
            renderHeight = naturalSizeFirst!.height;
        } else {
            renderHeight = naturalSizeSecond!.height;
        }
        videoComposition.renderScale = 1.0;
        videoComposition.renderSize = CGSizeMake(renderWidth!, renderHeight!)
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
//        videoComposition.frameDuration = CMTimeMake(1,30);
//        videoComposition.renderScale = 1.0;
//        videoComposition.renderSize = CGSizeMake(352.0, 288.0);
//        instruction.layerInstructions = [NSArray arrayWithObject: layerInstruction];
//        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
//        videoComposition.instructions = [NSArray arrayWithObject: instruction];
        
        //------------------Exporting the Composition -------------//
        let kDateFormatter = NSDateFormatter()
        kDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        kDateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle//NSDateFormatterShortStyle;
        
        
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        
//        let outputUrl = docUrl.URLByAppendingPathComponent(kDateFormatter.stringFromDate(NSDate()))
        let outputUrl = docUrl.URLByAppendingPathComponent( String(NSDate().timeIntervalSince1970))
        exporter?.outputURL = outputUrl
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.videoComposition = videoComposition
        exporter?.outputFileType = AVFileTypeQuickTimeMovie;
        
        exporter?.exportAsynchronouslyWithCompletionHandler({
            
            dispatch_async(dispatch_get_main_queue(), { 
                if exporter?.status == AVAssetExportSessionStatus.Completed {
                    print("完成")
                } else {
                
                }
            })
            
            print(exporter?.error)

        })
        
//        AVAssetExportSession(asset: composition, presetName: <#T##String#>)
        
        
        
//        let parentLayer = CALayer.init();
//        let videoLayer = CALayer.init();
//        parentLayer.frame = CGRectMake(0, 0, mutableVideoComposition.renderSize.width, mutableVideoComposition.renderSize.height);
//        videoLayer.frame = CGRectMake(0, 0, mutableVideoComposition.renderSize.width, mutableVideoComposition.renderSize.height);
//        parentLayer.addSublayer(videoLayer)
//        mutableVideoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
        
        
        
        
    }
    
    //视频连播
    func playMovie(){
        if playLayer == nil {
            
            let url = docUrl.URLByAppendingPathComponent("test.mp4")
            let asset = AVAsset(URL: url)
            let playeritem = AVPlayerItem(asset: asset)
            
            let url1 = docUrl.URLByAppendingPathComponent("test1.mp4")
            let asset1 = AVAsset(URL: url1)
            let playeritem1 = AVPlayerItem(asset: asset1)
            
            
            let queueplayer = AVQueuePlayer(items: [playeritem,playeritem1])
            queueplayer.addObserver(self, forKeyPath: "status", options: .New, context: &playContext)
            queueplayer.play()
            
            playLayer = AVPlayerLayer(player: queueplayer)
            playLayer!.backgroundColor = UIColor.lightGrayColor().CGColor
            playLayer!.frame = CGRect(x: 0, y: 100, width: 375, height: 500);
            
            self.view.layer.addSublayer(playLayer!)

            return;
        }
        
        
        if !playLayer!.hidden {
            self.playLayer?.hidden = true
            return;
        }
        playLayer?.player?.rate = 1.0
    
        playLayer?.hidden = false
    
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &playContext {
            //ok，ready to play
            if AVPlayerStatus.ReadyToPlay.rawValue == change?["new"] as? Int {
                if let player = object as? AVQueuePlayer {
                    player.play()
                }
            }
        }
    }
    
    deinit {
        playLayer?.player?.removeObserver(self, forKeyPath: "status")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func cancel(sender:UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
