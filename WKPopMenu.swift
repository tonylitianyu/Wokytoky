//
//  WKPopMenu.swift
//  wokytoky
//
//  Created by Tianyu Li on 15/1/17.
//  Copyright (c) 2015年 Tianyu Li. All rights reserved.
//

import UIKit
import AVFoundation
class WKPopMenu: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UINavigationBarDelegate, AVAudioRecorderDelegate {
    
    var cameraBtn : UIButton!
    var voiceBtn : UIButton!
    var documentsDirectory:String!
    var recorder : AVAudioRecorder!
    override init(frame: CGRect) {
        super.init(frame:frame);
        
        self.backgroundColor = UIColor.whiteColor()
        
        
        
        
        
        cameraBtn = UIButton(frame: CGRectMake(-55, 0, 44, 44))
        cameraBtn.backgroundColor = UIColor(red: 245/255, green: 177/255, blue: 51/255, alpha: 1.0)
        cameraBtn.layer.cornerRadius = 22
        cameraBtn.alpha = 0
        cameraBtn.addTarget(self, action: "imagePickerShow", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(cameraBtn)
        
        
        voiceBtn = UIButton(frame: CGRectMake(-55, 0, 44, 44))
        voiceBtn.backgroundColor = UIColor(red: 233/255, green: 75/255, blue: 94/255, alpha: 1.0)
        voiceBtn.layer.cornerRadius = 22
        voiceBtn.alpha = 0
        
        
        
        self.addSubview(voiceBtn)
        
        
        
        var voiceRecordPress : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressRecognizer:")
        voiceBtn.addGestureRecognizer(voiceRecordPress)
        
    }
    
    func buttonMenuShow(){
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            self.cameraBtn.alpha = 1
            self.cameraBtn.frame = CGRectMake(4, 0, 44, 44)
            
            
            self.voiceBtn.alpha = 1
            self.voiceBtn.frame = CGRectMake(44 + 15 + 4, 0, 44, 44)
            
        })
        
    }
    
    
    
    func buttonMenuHide(){
        
        
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.cameraBtn.alpha = 0
            self.cameraBtn.frame = CGRectMake(-55, 0, 44, 44)
            
            
            self.voiceBtn.alpha = 0
            self.voiceBtn.frame = CGRectMake(-55, 0, 44, 44)
            
        }) { (Bool) -> Void in
            
            self.removeFromSuperview()
            
            
        }
        
        
    }
    
    
    
    

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    /*//MARK: imagePicker
    func imagePickerShow(){
        
        var imagePicker : UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self;
        imagePicker.editing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.window?.rootViewController?.presentViewController(imagePicker, animated: true, completion: { () -> Void in
            
            
        })
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        
        
        
        
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        
        
    }
    
    
    
    //MARK: voiceMessage
    
    func longPressRecognizer(recognizer : UILongPressGestureRecognizer){
        
        if recognizer.state == UIGestureRecognizerState.Began {
            
            
            println("start recording")
            
            var audioSession : AVAudioSession = AVAudioSession.sharedInstance()
            var err : NSError?
            audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: &err)
            audioSession.setMode(AVAudioSessionModeVoiceChat, error: &err)
            
            
            audioSession.setActive(true, error: &err)
            
            var recordSettings : NSDictionary = [AVFormatIDKey : NSNumber(integer: kAudioFormatAppleIMA4),
                AVSampleRateKey : NSNumber(float: 44100.0),
                AVNumberOfChannelsKey : NSNumber(integer: 1),
                AVEncoderBitRateKey : NSNumber(integer: 12800),
                AVLinearPCMBitDepthKey : NSNumber(integer: 16),
                AVEncoderAudioQualityKey : NSNumber(integer:0x7F)]
            
            
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            documentsDirectory = paths[0] as? String
            let pathToSave = documentsDirectory.stringsByAppendingPaths([self.dateString()])
            
            var url : NSURL = NSURL.fileURLWithPath(pathToSave[0])!
            
            recorder = AVAudioRecorder(URL: url, settings: recordSettings, error: &err)
            
            if recorder == nil {
                println(err?.localizedFailureReason)
            }
            recorder.delegate = self
            recorder.meteringEnabled = true
            
            
            
            
            
        }else if recognizer.state == UIGestureRecognizerState.Ended{
            
            println("stop recording and send")
            
            
            
        }
        
        
        
        
        
        
        
        
    }
    
    
    func dateString() -> String{
        
        var formatter : NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "ddMMMYY_hhmmssa"
        
        
        return formatter.stringFromDate(NSDate()).stringByAppendingString(".aif")
        
    }*/
    
    
    
    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
