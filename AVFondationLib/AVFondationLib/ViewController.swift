//
//  ViewController.swift
//  AVFondationLib
//
//  Created by 宛越 on 16/7/6.
//  Copyright © 2016年 yuewan. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class ViewController: UIViewController {

    var recorder:AVAudioRecorder?
    
    var docUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    var imageView:UIImageView!
    
    private var varContext = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        let button = UIButton(frame: CGRect(x: 50, y: 100, width: 100, height: 40))
        button.addTarget(self, action: #selector(ViewController.start), forControlEvents: UIControlEvents.TouchUpInside)
        button.setTitle("开始", forState: UIControlState.Normal)
        button.backgroundColor = UIColor.blueColor()
        
        let button1 = UIButton(frame: CGRect(x: 50, y: 150, width: 100, height: 40))
        button1.addTarget(self, action: #selector(ViewController.stop), forControlEvents: UIControlEvents.TouchUpInside)
        button1.setTitle("停止", forState: UIControlState.Normal)
        button1.backgroundColor = UIColor.blueColor()
        
        
        let button2 = UIButton(frame: CGRect(x: 50, y: 200, width: 100, height: 40))
        button2.addTarget(self, action: #selector(ViewController.play), forControlEvents: UIControlEvents.TouchUpInside)
        button2.setTitle("播放", forState: UIControlState.Normal)
        button2.backgroundColor = UIColor.blueColor()
        
        let button3 = UIButton(frame: CGRect(x: 20, y: 250, width: 100, height: 40))
        button3.addTarget(self, action: #selector(ViewController.accessUserAssets), forControlEvents: UIControlEvents.TouchUpInside)
        button3.setTitle("视频截图", forState: UIControlState.Normal)
        button3.backgroundColor = UIColor.blueColor()
        
        let button4 = UIButton(frame: CGRect(x: 150, y: 250, width: 100, height: 40))
        button4.addTarget(self, action: #selector(ViewController.handelMovie), forControlEvents: UIControlEvents.TouchUpInside)
        button4.setTitle("裁剪", forState: UIControlState.Normal)
        button4.backgroundColor = UIColor.blueColor()
        
        let button5 = UIButton(frame: CGRect(x: 260, y: 250, width: 100, height: 40))
        button5.addTarget(self, action: #selector(ViewController.playMovie), forControlEvents: UIControlEvents.TouchUpInside)
        button5.setTitle("播放视频", forState: UIControlState.Normal)
        button5.backgroundColor = UIColor.blueColor()
        
        imageView = UIImageView(frame: CGRect(x: 50, y: 300, width: 300, height: 300))
        view.addSubview(imageView)
        
        view.addSubview(button)
        view.addSubview(button1)
        view.addSubview(button2)
        view.addSubview(button3)
        view.addSubview(button4)
        view.addSubview(button5)
    }
    
    // 播放视频
    func playMovie(){
        let url = docUrl.URLByAppendingPathComponent("scala01b.mp4")
        
//        guard let url = NSURL(string: "http://www.test.com/scala01b.mp4") else {
//            return;
//        }
//        print(url)
        let asset = AVURLAsset(URL: url);
        
        let keys = ["duration"]
        asset.loadValuesAsynchronouslyForKeys(keys) {
            var error:NSError?
            let tracksStatus = asset.statusOfValueForKey("duration", error: &error);
            switch tracksStatus {
            case .Loaded:
                print("loaded");break;
            case .Failed:
                print(error)
                print("failed");break;
            case .Cancelled:
                print("cancelled");break;
            default:
                print("haha");break;
            }
        }
        
        let playItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playItem)
        print(player.status.rawValue)
    
        playItem.tracks.first?.assetTrack.asset?.duration
        
        let layer = AVPlayerLayer(player: player)
        layer.backgroundColor = UIColor.lightGrayColor().CGColor
        layer.frame = CGRect(x: 0, y: 0, width: 375, height: 600);
        
        self.view.layer.addSublayer(layer)
        
        player.rate = 1.0
        
        
        let fiveSecendsIn = CMTimeMake(700, 1)
        player.seekToTime(fiveSecendsIn)
        
        player.play()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (context == &varContext) {
            print(" 改变")
        }
        
    }
    
    //Accessing the User’s Assets
    func accessUserAssets(){
        
        let url = docUrl.URLByAppendingPathComponent("scala01b.mp4")
        print(url)
        let asset = AVURLAsset(URL: url);
        
        let keys = ["duration"]
        asset.loadValuesAsynchronouslyForKeys(keys) { 
            var error:NSError?
            let tracksStatus = asset.statusOfValueForKey("duration", error: &error);
            switch tracksStatus {
            case .Loaded:
                print("loaded");break;
            case .Failed:
                print(error)
                print("failed");break;
            case .Cancelled:
                print("cancelled");break;
            default:
                print("haha");break;
            }
        }
        
        //从视频中生成图片
        if asset.tracksWithMediaType(AVMediaTypeVideo).count > 0 {
            generatorImage(asset)
//            generatorImages(asset)
        }
        
    }
    
    func handelMovie(){
        let url = docUrl.URLByAppendingPathComponent("scala01b.mp4")
        print(url)
        let asset = AVURLAsset(URL: url);
        
        let keys = ["duration"]
        asset.loadValuesAsynchronouslyForKeys(keys) {
            var error:NSError?
            let tracksStatus = asset.statusOfValueForKey("duration", error: &error);
            switch tracksStatus {
            case .Loaded:
                print("loaded");break;
            case .Failed:
                print(error)
                print("failed");break;
            case .Cancelled:
                print("cancelled");break;
            default:
                print("haha");break;
            }
        }
        trimingAndTranscodingAsset(asset)
    }
    
    //对视频的裁剪和转码
    func trimingAndTranscodingAsset(asset:AVAsset){
        let compatiblePresets = AVAssetExportSession.exportPresetsCompatibleWithAsset(asset)
        if compatiblePresets.contains(AVAssetExportPresetLowQuality) {
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset640x480) else {
                print("出错")
                return
            }
            
            exportSession.outputURL = docUrl.URLByAppendingPathComponent("test.mp4")
            exportSession.outputFileType = AVFileTypeMPEG4
            
            let start = CMTimeMakeWithSeconds(1.0, 600);
            let duration = CMTimeMakeWithSeconds(3.0, 600);
            let range = CMTimeRangeMake(start, duration)
            
            exportSession.timeRange = range
            
            exportSession.exportAsynchronouslyWithCompletionHandler({ 
                switch exportSession.status {
                case .Failed:
                    print("失败");break;
                case .Cancelled:
                    break;
                case .Completed:
                    print("导出成功");
                default:
                    break;
                }
            })
            
            guard let exportSession1 = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset640x480) else {
                print("出错")
                return
            }
            exportSession1.outputURL = self.docUrl.URLByAppendingPathComponent("test1.mp4")
            exportSession1.outputFileType = AVFileTypeMPEG4
            
            let start1 = CMTimeMakeWithSeconds(700.0, 600);
            let duration1 = CMTimeMakeWithSeconds(3.0, 600);
            let range1 = CMTimeRangeMake(start1, duration1)
            exportSession1.timeRange = range1
            exportSession1.exportAsynchronouslyWithCompletionHandler({
                switch exportSession1.status {
                case .Failed:
                    print("失败");break;
                case .Cancelled:
                    break;
                case .Completed:
                    print("导出成功");
                default:
                    break;
                }
            })
            
        }
    }
    
    //从视频中生成单张图片
    func generatorImage(asset:AVAsset){
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        let secends = CMTimeGetSeconds(asset.duration);
        let midpoint = CMTimeMakeWithSeconds(secends/4.0, 600)
        
        var actualTime = CMTime()
        
        do {
            let cgimg = try imageGenerator.copyCGImageAtTime(midpoint, actualTime: &actualTime)
            
            let secend = actualTime.value/Int64(actualTime.timescale)
            
            print("截屏在\(secend)秒处")
            let image = UIImage(CGImage: cgimg)
            imageView.image = image
            
        } catch let error as NSError {
            print(error)
        }
    }
    
    //从视频中生成一系列的图片
    func generatorImages(asset:AVAsset){
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        let secends = CMTimeGetSeconds(asset.duration);
        
        let firstpoint = CMTimeMakeWithSeconds(secends/3.0,600)
        let midpoint = CMTimeMakeWithSeconds(secends/2.0, 600)
        let endpoint = CMTimeMakeWithSeconds(secends, 600)
        
        let times = [
            NSValue.init(CMTime: kCMTimeZero),
            NSValue.init(CMTime: firstpoint),
            NSValue.init(CMTime: midpoint),
            NSValue.init(CMTime: endpoint)
        ]
        
        
        var images = [UIImage]();
        imageGenerator.generateCGImagesAsynchronouslyForTimes(times
            , completionHandler: { (t1, cgimage, t2, result, error) in
                print(error)
                print("\(t1.value/Int64(t1.timescale))------\(t2.value/Int64(t2.timescale))");
                
                if result == AVAssetImageGeneratorResult.Succeeded {
                    if cgimage != nil {
                        images.append(UIImage(CGImage: cgimage!))
                    }
                }
        })
        
        //取消生成图片
        imageGenerator.cancelAllCGImageGeneration();

    }
    
    func play(){
        let url = docUrl.URLByAppendingPathComponent("recoder")
        do {
            let player = try AVAudioPlayer(contentsOfURL: url)
            
            if player.prepareToPlay() {
                player.play()
            }
        } catch let error as NSError  {
            print(error)
        }
    }
    

    func start(){
        
        
        let url = docUrl.URLByAppendingPathComponent("recoder")
        
        if recorder != nil {
            recorder!.record()
        }
        

        print(url)
        do {
            //录音采用pcm编码
            let settings = [
                AVSampleRateKey                     :NSNumber(float: 8000.0),       //音频的采样率
                AVFormatIDKey                       :NSNumber(unsignedInt: kAudioFormatLinearPCM),
                AVLinearPCMBitDepthKey              :16,                   //采样(单位bit)
                AVNumberOfChannelsKey               :2,                 //声道
                AVSampleRateConverterAudioQualityKey:AVAudioQuality.Max.rawValue
            ];
            
            recorder = try AVAudioRecorder(URL: url, settings: settings)
            recorder?.record()
        } catch let error as NSError {
            print(error)
        }

    }
    
    func stop(){
        recorder?.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

