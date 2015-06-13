//
//  ViewController.swift
//  wokytoky
//
//  Created by Tianyu Li on 15/1/5.
//  Copyright (c) 2015年 Tianyu Li. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import MobileCoreServices
import CoreBluetooth

class ViewController: UIViewController,UITextFieldDelegate, MCBrowserViewControllerDelegate, CBCentralManagerDelegate, CBPeripheralManagerDelegate{
    var appDelegate:AppDelegate!
    
    
    var circularProgress1: KYCircularProgress!
    var textLabel1:UILabel!
    var infoText: UITextView!
    var documentsDirectory:String!
    var chatView : WKChatView!
    var titleView : UILabel!
    var item : UINavigationItem!
    
    
    
    var centralManager : CBCentralManager!
    var peripheralManager : CBPeripheralManager!
    var identifer : String = "1F6312DC-0C22-4076-9FD9-ACFA447ED45A"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        
        
        
        //navigation bar
        var bar : UINavigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.width, 60));
        //bar.backgroundColor = UIColor(red: 252/255, green: 252/255, blue: 252/255, alpha: 1.0);
        bar.backgroundColor = UIColor(red: 78/255, green: 228/255, blue: 195/255, alpha: 1.0)
        bar.barTintColor = UIColor(red: 78/255, green: 228/255, blue: 195/255, alpha: 1.0)
        bar.translucent = false
        self.view.addSubview(bar);
        
        item = UINavigationItem();
        
        titleView = UILabel(frame: CGRectMake(0, 0, self.view.frame.width - 170, 60))
        titleView.textColor = UIColor.whiteColor()
        titleView.text = "Nearby"
        titleView.textAlignment = NSTextAlignment.Center
        
        item.titleView = titleView
        
        bar.pushNavigationItem(item, animated: true);
        
        
        var menuBtn : UIButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        menuBtn.setImage(UIImage(named: "menu"), forState: UIControlState.Normal)
        menuBtn.addTarget(self, action: "browser", forControlEvents: UIControlEvents.TouchUpInside)
        menuBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        var browseDevice : UIBarButtonItem = UIBarButtonItem(customView: menuBtn)
        
        browseDevice.tintColor = UIColor.whiteColor()
        item.leftBarButtonItem = browseDevice
        
        
        var barLine : UIView = UIView(frame: CGRectMake(0, 60, self.view.frame.width, 1))
        barLine.backgroundColor = UIColor(red: 78/255, green: 228/255, blue: 195/255, alpha: 1.0)
        bar.addSubview(barLine)
        
        
        //chatView
        chatView = WKChatView(frame: self.view.frame);
        
        self.view.addSubview(chatView);
        self.view.sendSubviewToBack(chatView);
        
        
        
        
        
        
        
        
        
        
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;
        
        appDelegate.mpcDelegate.initPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcDelegate.initSession()
        appDelegate.mpcDelegate.advertiseSelf(true)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPCDidChangeStateNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPCDidReceiveDataNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startReceivingResourceWithNameNotification:", name: "MPCDidStartReceivingResourceWithNameNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishReceivingResourceWithNameNotification:", name: "MPCDidFinishReceivingResourceWithNameNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivingProgressNotification:", name: "MPCReceivingProgressNotification", object: nil)
        
        
        //chatTextView.text = NSUserDefaults.standardUserDefaults().objectForKey("chat") as String!
        
        
        
        
        /*if appDelegate.mpcDelegate.session.connectedPeers.count > 0 {
            item.title = "Chat ✓"
        } else {
            item.title = "Chat ✗"
        
        }*/
        
        
        

        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: Browser
    func browser(){
        
        if appDelegate.mpcDelegate.session != nil {
            appDelegate.mpcDelegate.initBrowser()
            appDelegate.mpcDelegate.browser.delegate = self
            
            self.presentViewController(appDelegate.mpcDelegate.browser, animated: true, completion: nil)
        }
        
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil);
        chatView.sendTextField.becomeFirstResponder()
        println("finish");
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil);
        
        chatView.sendTextField.becomeFirstResponder()
        
        
        println("cancel");
    }
    
    func peerChangedStateWithNotification(notification:NSNotification) {
        if let userInfo : AnyObject = notification.userInfo?
        {
            let peerID = userInfo["peerID"] as MCPeerID
            let peerDisplayName = peerID.displayName
            let state: MCSessionState = MCSessionState(rawValue: Int(userInfo["state"] as NSNumber)) as MCSessionState!
            
            if (state != MCSessionState.Connecting)
            {
                if (state == MCSessionState.Connected)
                {
                    
                    self.titleView.text = ""+peerDisplayName+""
                }
                else if (state == MCSessionState.NotConnected)
                {
                    
                    self.titleView.text = "Nearby"
                }
            }
        } else {
            println("userInfo is nil")
        }
    }
    
    func handleReceivedDataWithNotification(notification:NSNotification) {
        // use if needed
    }
    
    func startReceivingResourceWithNameNotification(notification:NSNotification) {
        if appDelegate.skipnotifications {
            return
        }
        
        
        
        dispatch_async(dispatch_get_main_queue(), {
            self.setupKYCircularProgress1()
        })
        
        if let userInfo : AnyObject = notification.userInfo? {
            println("RECEIVING")
            let progress:NSProgress = userInfo["progress"] as NSProgress
            progress.addObserver(self, forKeyPath: "fractionCompleted", options: NSKeyValueObservingOptions.New, context: nil)
        }
    }
    
    func finishReceivingResourceWithNameNotification(notification:NSNotification) {
        if appDelegate.skipnotifications{
            return
        }
        
        
        
        
        removeKYCircularProgress1()
        if let userInfo : AnyObject = notification.userInfo? {
            let localURL:NSURL = userInfo["localURL"] as NSURL
            let resourceName:String = userInfo["resourceName"] as String
            let destinationPath:String = documentsDirectory.stringByAppendingPathComponent(resourceName)
            let data:NSData = NSData(contentsOfURL: localURL)!
            
            // check if image
            let test:UIImage? = UIImage(data: data)
            
            if (test != nil) { // Image
                println("IMAGE")
                UIImageWriteToSavedPhotosAlbum(test, self, Selector("image:didFinishSavingWithError:contextInfo:"),nil)
            } else { // Video
                println("VIDEO")
                data.writeToFile(destinationPath, atomically: true)
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(destinationPath) {
                    UISaveVideoAtPathToSavedPhotosAlbum(destinationPath, self, Selector("video:didFinishSavingWithError:contextInfo:"), nil)
                }
            }
        }
    }
    
    func receivingProgressNotification(notification:NSNotification) {
        if appDelegate.skipnotifications{
            return
        }
        
        
        // use if needed
    }
    
    
    
    
    
    
    
    
    
    
    //MARK: Progress
    func setupKYCircularProgress1() {
        circularProgress1 = KYCircularProgress(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2))
        let center = (self.view.frame.size.width/2, self.view.frame.size.height/2)
        circularProgress1.path = UIBezierPath(arcCenter: CGPointMake(center.0, center.1), radius: CGFloat(circularProgress1.frame.size.width/3.0), startAngle: CGFloat(M_PI), endAngle: CGFloat(0.0), clockwise: true)
        circularProgress1.lineWidth = 8.0
        
        textLabel1 = UILabel(frame: CGRectMake(self.view.frame.size.width/2-40, self.view.frame.size.height/2-16, 80.0, 32.0))
        textLabel1.font = UIFont(name: "HelveticaNeue-Bold", size: 32)
        textLabel1.textAlignment = .Center
        textLabel1.textColor = circularProgress1.colorHex(0xffa500) // orange
        textLabel1.backgroundColor = UIColor.clearColor()
        self.view.addSubview(textLabel1)
        
        circularProgress1.progressChangedClosure({ (progress: Double, circularView: KYCircularProgress) in
            //println("progress: \(progress)")
            self.textLabel1.text = "\(Int(progress * 100.0))%"
        })
        
        self.view.addSubview(circularProgress1)
        
        self.view.alpha = 0.9
        infoText.hidden=true;
    }
    
    func removeKYCircularProgress1() {
        circularProgress1.removeFromSuperview()
        textLabel1.removeFromSuperview()
        self.view.alpha = 1.0
        infoText.hidden=false;
    }
    
    
    
    
    
    //MARK: bluetooth
    
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
        
        
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        
        
    }
    
    
    
    
}

    
        
    
    
    
    
    




