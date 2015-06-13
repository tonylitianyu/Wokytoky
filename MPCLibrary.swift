//
//  MPCLibrary.swift
//  Multipeer
//
//  Created by Zois Avgerinos on 10/16/14.
//  Copyright (c) 2014 Zois Avgerinos. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MPCLibrary: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate {
   
    var peerID:MCPeerID!
    var session:MCSession!
    var browser:MCBrowserViewController!
    var advertiser:MCAdvertiserAssistant? = nil
    
    let serviceType = "MultipeerApp"
    
    func initPeerWithDisplayName(displayName:String) {
        peerID = MCPeerID(displayName: displayName)
    }
    
    func initSession() {
        session = MCSession(peer: peerID)
        session.delegate = self
    }
    
    func initBrowser() {
        println("MPCLibrary")
        browser = MCBrowserViewController(serviceType: serviceType, session: session)
    }
    
    func advertiseSelf(advertiseSelf:Bool) {
        if advertiseSelf {
            advertiser = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
            advertiser!.start()
        } else {
            advertiser!.stop()
            advertiser = nil
        }
    }
    
    /*
    ** MCSessionDelegate
    */

    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        // user info dictionary
        let userInfo = ["peerID":peerID, "state":state.rawValue]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("MPCDidChangeStateNotification", object:nil, userInfo:userInfo)
        })
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        let userInfo = ["data":data, "peerID":peerID]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("MPCDidReceiveDataNotification", object:nil, userInfo:userInfo)
        })
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        let userInfo = ["resourceName":resourceName, "peerID":peerID, "progress":progress]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("MPCDidStartReceivingResourceWithNameNotification", object:nil, userInfo:userInfo)
            progress.addObserver(self, forKeyPath: "fractionCompleted", options: NSKeyValueObservingOptions(), context: nil)
        })
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        let userInfo = ["resourceName":resourceName, "peerID":peerID, "localURL":localURL]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("MPCDidFinishReceivingResourceWithNameNotification", object:nil, userInfo:userInfo)
        })
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        println("receive invitation");
    }

    
    
    /*
    ** progress
    */
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("MPCReceivingProgressNotification", object:nil, userInfo: ["progress":object])
        })
    }
    
}
