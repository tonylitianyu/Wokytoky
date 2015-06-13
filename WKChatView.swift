//
//  WKChatView.swift
//  wokytoky
//
//  Created by Tianyu Li on 15/1/7.
//  Copyright (c) 2015年 Tianyu Li. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class WKChatView: UIView, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
    {

    var appDelegate : AppDelegate!
    var sendTextField:UITextField!
    var chatTextView:UITextView!
    var chatArray : NSMutableArray!
    var chatTableView : UITableView!
    var inputField : UITextField!
    var cameraBtn : UIButton!
    var popMenu : WKPopMenu!
    
    override init(frame : CGRect){
        super.init(frame:frame);
        
        chatArray = NSMutableArray(capacity: 100)
        //chatArray = ["first", "second", "third"]
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        appDelegate.mpcDelegate.initPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcDelegate.initSession()
        appDelegate.mpcDelegate.advertiseSelf(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPCDidChangeStateNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPCDidReceiveDataNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "watchReply", name: "watchKitReply", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeFirstResponder", name: UIKeyboardDidShowNotification, object: nil)
        
        
        self.backgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1.0);
        
        
        //chatTextField
        self.sendTextField = UITextField(frame: CGRectMake(0, self.frame.height - 40, self.frame.width, 40));
        self.sendTextField.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0);
        self.sendTextField.layer.borderColor = UIColor.clearColor().CGColor;
        //self.sendTextField.delegate = self
        self.addSubview(self.sendTextField);
        self.bringSubviewToFront(self.sendTextField)
        self.sendTextField.becomeFirstResponder();
        
        
        
        //chatTextView
        self.chatTextView = UITextView(frame: CGRectMake(40, 60, self.frame.width - 80, 280));
        self.chatTextView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 0.8);
        self.chatTextView.editable = false;
        
        //self.addSubview(self.chatTextView)
        
        
        
        //tableview
        chatTableView = UITableView(frame: CGRectMake(0, 60, self.frame.width, self.frame.height-280-80), style: UITableViewStyle.Plain)
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.backgroundColor = UIColor(red: 239/255, green: 247/255, blue: 251/244, alpha: 1.0)
        chatTableView.registerClass(WKChatTableViewCell.classForCoder(), forCellReuseIdentifier: "cellIdetifer")
        chatTableView.separatorColor = UIColor.clearColor()
        self.addSubview(chatTableView)
        self.sendSubviewToBack(chatTableView)
        
        
        
        //keyboard with textfield & btn
        var inputView : UIView = UIView(frame: CGRectMake(0, 0, self.frame.width, 50))
        inputView.backgroundColor = UIColor.whiteColor()
        inputView.layer.borderColor = UIColor.clearColor().CGColor;
        
        
        /*var topLine : CALayer = CALayer(layer: layer)
        topLine.frame = CGRectMake(0, 0, inputView.frame.width, 1)
        topLine.backgroundColor = UIColor(white: 220/255, alpha: 1.0).CGColor
        inputView.layer.addSublayer(topLine)*/
        
        
        
        cameraBtn = UIButton(frame: CGRectMake(5, 3, 44, 44))
        cameraBtn.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        cameraBtn.layer.cornerRadius = 22;
        cameraBtn.addTarget(self, action: "imagePickerShow", forControlEvents: UIControlEvents.TouchUpInside)
        cameraBtn.setImage(UIImage(named: "plus"), forState: UIControlState.Normal)
        inputView.addSubview(cameraBtn)
        
        
        
        inputField = UITextField(frame: CGRectMake(60, 1, self.frame.width - 60, 49))
        inputField.backgroundColor = UIColor.whiteColor()
        inputField.layer.borderColor = UIColor.clearColor().CGColor;
        inputField.returnKeyType = UIReturnKeyType.Send
        inputField.delegate = self
        inputField.placeholder = "Say something..."
        inputView.addSubview(inputField)
        inputField.becomeFirstResponder()
        inputView.becomeFirstResponder()
        
        
        self.sendTextField.inputAccessoryView = inputView
        self.window?.makeKeyAndVisible()
        

        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    
    
    
    //MARK: UItextField
    func changeFirstResponder(){
        
        self.inputField.becomeFirstResponder()
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //textField.resignFirstResponder()
        
        if self.chatTextView != nil{
            self.chatTextView.text = self.chatTextView.text.stringByAppendingString("me: " + textField.text + "\n")
        }
        
        
        chatArray.addObject(["user" : "self", "text" : textField.text])
        chatTableView.reloadData()
        self.scrollToBottom()
        
        
        // save
        NSUserDefaults.standardUserDefaults().setObject(chatTextView.text, forKey: "chat")
        
        // inform other device
        if let count = appDelegate.mpcDelegate.session.connectedPeers.count as Int? {
            println(count);
            if  count > 0{
                
                let infoDict = ["message":textField.text]
                let infodata = NSJSONSerialization.dataWithJSONObject(infoDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
                var error:NSError?
                
                appDelegate.mpcDelegate.session.sendData(infodata, toPeers: appDelegate.mpcDelegate.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
                
                if error != nil {
                    println("error: \(error?.localizedDescription)")
                }
            }
        }
        sendTextField.text = ""
        inputField.text = ""
        return true
    }
    
    
    func watchReply(){
        
        if self.chatTextView != nil{
            self.chatTextView.text = self.chatTextView.text.stringByAppendingString("me: " + "Yes" + "\n")
        }
        
        chatArray.addObject("Yes")
        chatTableView.reloadData()
        self.scrollToBottom()
        
        // save
        NSUserDefaults.standardUserDefaults().setObject(chatTextView.text, forKey: "chat")
        
        // inform other device
        if let count = appDelegate.mpcDelegate.session.connectedPeers.count as Int? {
            println(count);
            if  count > 0{
                
                let infoDict = ["message":"Yes"]
                let infodata = NSJSONSerialization.dataWithJSONObject(infoDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
                var error:NSError?
                
                appDelegate.mpcDelegate.session.sendData(infodata, toPeers: appDelegate.mpcDelegate.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
                
                if error != nil {
                    println("error: \(error?.localizedDescription)")
                }
            }
        }

        
    }
    
    
    
    
    
    
    //MARK: MPC DATA
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
            //self.navigationItem.title = "Chat ✓"
                println("Chat ✓")
            }
                else if (state == MCSessionState.NotConnected)
            {
            //self.navigationItem.title = "Chat ✗"
                println("Chat ✗")
                        }
                    }
                }
        }
        
    func handleReceivedDataWithNotification(notification:NSNotification) {
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let receivedData:NSData = userInfo["data"] as NSData
        let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        let senderPeerID:MCPeerID = userInfo["peerID"] as MCPeerID
        let senderDisplayName = senderPeerID.displayName
        
        var msg:String? = message.objectForKey("message") as? String
        chatTextView.text = chatTextView.text.stringByAppendingString(senderDisplayName + ": " + msg! + "\n")
        
        chatArray.addObject(["user" : "other", "text" : msg!])
        println(chatArray)
        chatTableView.reloadData()
        self.scrollToBottom()
    
    
        println("receiveText");
        let notification :UILocalNotification = UILocalNotification()
        notification.alertBody = "Hello Watch"
        
        let dateNow = NSDate()
        
        notification.fireDate = dateNow
        println("\(dateNow)");
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        
    
        //save
        NSUserDefaults.standardUserDefaults().setObject(chatTextView.text, forKey: "chat")
    
    
        }
    
    
    
    //MARK: tableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifer = "cellIdetifer"
        var cell : WKChatTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifer) as! WKChatTableViewCell?
        
        //if !(cell != nil) {
            
        cell = WKChatTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifer)
            
            
        //}
        
        //cell?.textLabel?.text = chatArray[indexPath.row]["text"] as? String
        cell?.backgroundColor = UIColor.clearColor()
        
        //cell?.cellText.text = chatArray[indexPath.row]["text"] as? String
        //cell?.cellText.sizeToFit()
        
        let user = chatArray[indexPath.row]["user"]as!s; String()
        
        if user == "self" {
            cell?.selfTextShowWith(chatArray[indexPath.row]["text"] as String)
            println(chatArray[indexPath.row]["user"])
        }else{
            cell?.otherTextShowWith(chatArray[indexPath.row]["text"] as String)
        }
        
        
        
        return cell!
        

        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func scrollToBottom(){
        chatTableView.scrollRectToVisible(CGRectMake(0, chatTableView.contentSize.height - chatTableView.bounds.size.height, chatTableView.bounds.size.width, chatTableView.bounds.size.height), animated: true)
        
        
        
    }
    
    
    
    
    
    
    //MARK: imagePicker
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
        
        picker.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
        
            self.sendTextField.becomeFirstResponder()
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
            return
            
        
        })
        
    }
    
    
    
    /*//MARK: optionBtn
    
    func optionBtnPress(){
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.optionBtn.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 4.0))
            
        })
        
        
        popMenu = WKPopMenu(frame: CGRectMake(60, 3, self.frame.width - 60, 44))
        self.sendTextField.inputAccessoryView?.addSubview(popMenu)
        popMenu.buttonMenuShow()
        
        self.optionBtn.removeTarget(self, action: "optionBtnPress", forControlEvents: UIControlEvents.TouchUpInside)
        self.optionBtn.addTarget(self, action: "optionBtnCancel", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    
    func optionBtnCancel(){
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.optionBtn.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI / 512.0))
            
        })
        
        
        popMenu.buttonMenuHide()
        
        
        self.optionBtn.removeTarget(self, action: "optionBtnCancel", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.optionBtn.addTarget(self, action: "optionBtnPress", forControlEvents: UIControlEvents.TouchUpInside)
    }*/
    

    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
