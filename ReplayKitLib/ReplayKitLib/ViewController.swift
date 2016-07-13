//
//  ViewController.swift
//  ReplayKitLib
//
//  Created by 宛越 on 16/7/6.
//  Copyright © 2016年 yuewan. All rights reserved.
//

import UIKit
import ReplayKit

class ViewController: UIViewController {

    
//    let previewController = RPPreviewViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let button = UIButton(frame: CGRect(x: 50, y: 150, width: 100, height: 40))
        button.addTarget(self, action: #selector(ViewController.start), forControlEvents: UIControlEvents.TouchUpInside)
        button.setTitle("开始", forState: UIControlState.Normal)
        button.backgroundColor = UIColor.blueColor()
        
        let button1 = UIButton(frame: CGRect(x: 50, y: 350, width: 100, height: 40))
        button1.addTarget(self, action: #selector(ViewController.stop), forControlEvents: UIControlEvents.TouchUpInside)
        button1.setTitle("停止", forState: UIControlState.Normal)
        button1.backgroundColor = UIColor.blueColor()
        
        
        view.addSubview(button)
        view.addSubview(button1)
        
        
        RPScreenRecorder.sharedRecorder().delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func start(){
        if !RPScreenRecorder.sharedRecorder().available {
            print("不可用")
            return
        }
        

        RPScreenRecorder.sharedRecorder().startRecordingWithMicrophoneEnabled(true) { (error) in
            print(error);
        }
        
        
    }
    
    func stop(){
        RPScreenRecorder.sharedRecorder().stopRecordingWithHandler { (previewController, error) in
            print(error)
            self.presentViewController(previewController!, animated: true, completion: nil)
            
        }
    }

}

extension ViewController: RPScreenRecorderDelegate
{
    func screenRecorder(screenRecorder: RPScreenRecorder, didStopRecordingWithError error: NSError, previewViewController: RPPreviewViewController?) {
        print(error)
    }
    
    func screenRecorderDidChangeAvailability(screenRecorder: RPScreenRecorder) {
        print(screenRecorder.available)
    }
}


