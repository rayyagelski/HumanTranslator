//
//  VideoViewController.swift
//  Human Translator
//
//  Created by Yin on 22/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import UIKit
import AVFoundation

class VideoViewController: BaseViewController, ARDAppClientDelegate, RTCEAGLVideoViewDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var remoteView: RTCEAGLVideoView!
    @IBOutlet weak var localView: RTCEAGLVideoView!
    
    var roomName: String!
    var client: ARDAppClient?
    var localVideoTrack: RTCVideoTrack?
    var remoteVideoTrack: RTCVideoTrack?
    
    var ringTimer: Timer!
    
    var player : AVAudioPlayer?
    var cancelStatus = false
    
    var loaded = false
    
    var statusVC = CallingViewController()
    
    var roomStatus = 0
    var user = UserModel()
    @IBOutlet weak var statusView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initialize()
        if roomStatus == R.Const.IS_CALLING {
            connectToChatRoom()
        }
        
        (UIApplication.shared.delegate as? AppDelegate)?.videoCallStautsDelegate = self
        playAudio()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disconnect()
    }

    
    @IBAction func endButton(_ sender: UIButton) {
        disconnect()
        //self.view.isUserInteractionEnabled = false
        ///_ = self.navigationController?.popToRootViewController(animated: true)
        /*
        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            guard viewControllers.count < 4 else {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 4], animated: true)
                return
            }
        }
        
        if roomStatus == R.Const.IS_CALLING {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }*/
    }
    
    //    MARK: RTCEAGLVideoViewDelegate
    func appClient(_ client: ARDAppClient!, didChange state: ARDAppClientState) {
        switch state{
        case ARDAppClientState.connected:
            
            if roomStatus == R.Const.IS_CALLING {
                ApiRequest.sendRequest(target_id: user.id, room_no: roomName, completion: { (resCode) in
                    if resCode == R.Const.CODE_SUCCESS {
                        
                    } else {
                        self.disconnect()
                    }
                })
            }
            print("Client Connected")
            break
        case ARDAppClientState.connecting:
            print("Client Connecting")
            break
        case ARDAppClientState.disconnected:
            print("Client Disconnected")
            remoteDisconnected()
        }
    }
    
    func appClient(_ client: ARDAppClient!, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack!) {
        self.localVideoTrack = localVideoTrack
        self.localVideoTrack?.add(localView)
    }
    
    func appClient(_ client: ARDAppClient!, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack!) {
        self.remoteVideoTrack = remoteVideoTrack
        self.statusView.isHidden = true
        isCalled = true
        self.remoteVideoTrack?.add(remoteView)
        self.pauseAudio()
    }
    
    func appClient(_ client: ARDAppClient!, didError error: Error!) {
        //        Handle the error
        showAlertWithMessage(error.localizedDescription)
        disconnect()
    }
    
    //    MARK: RTCEAGLVideoViewDelegate
    
    func videoView(_ videoView: RTCEAGLVideoView!, didChangeVideoSize size: CGSize) {
        //        Resize localView or remoteView based on the size returned
    }
    
    //    MARK: Private
    
    func initialize(){
        disconnect()
        //        Initializes the ARDAppClient with the delegate assignment
        client = ARDAppClient.init(delegate: self)
        
        //        RTCEAGLVideoViewDelegate provides notifications on video frame dimensions
        remoteView.delegate = self
        localView.delegate = self
    }
    
    func connectToChatRoom(){
        client?.serverHostUrl = "https://apprtc.appspot.com"
        
        if roomStatus == R.Const.IS_CALLING {
            roomName = "HTranslator\(CommonUtils.getRandomRoomNumber())"
        }
        
        loaded = true
        
        client?.connectToRoom(withId: roomName, options: nil)
    }
    
    func remoteDisconnected(){
        if(remoteVideoTrack != nil){
            remoteVideoTrack?.remove(remoteView)
        }
        remoteVideoTrack = nil
        /*
        if cancelStatus {
            ApiFunctions.doDeclineCall(senderid: currentUser.user_id, receiverid: user.user_id, type : Constants.STATUS_DECLINE_FROMCONNECT ,completion: { (message) in
                self.navigationController?.popViewController(animated: true)
            })
        }
        else{
            self.navigationController?.popViewController(animated: false)
        }*/
        
        if roomStatus == R.Const.IS_CALLING {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func disconnect() {
        
        if loaded == true {
            loaded = false
            if(client != nil) {
                pauseAudio()
                if(localVideoTrack != nil){
                    localVideoTrack?.remove(localView)
                }
                if(remoteVideoTrack != nil){
                    remoteVideoTrack?.remove(remoteView)
                }
                localVideoTrack = nil
                remoteVideoTrack = nil
                client?.disconnect()
            } else {
                
                pauseAudio()
                print("client is nil")
                /* decline API
                ApiFunctions.doDeclineCall(senderid: currentUser.user_id, receiverid: user.user_id, type : Constants.STATUS_DECLINE_CANCEL ,completion: { (message) in
                    self.navigationController?.popViewController(animated: true)
                })*/
                
                if roomStatus == R.Const.IS_CALLING {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            print("load false")
        }
    }
    
    func showAlertWithMessage(_ message: String){
        let alertView: UIAlertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alertView.addAction(alertAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CallingStatusSegue"{
            
            statusVC = segue.destination as! CallingViewController
            statusVC.status = self.roomStatus
            statusVC.user = user
        }
        
    }
    
    //MARK: --ring  sound play and stop
    
    
    func pauseAudio() {
        if ringTimer != nil && ringTimer.isValid {
            ringTimer.invalidate()
        }
        if player != nil {
            player?.pause()
        }
    }
    
    
    @objc func playAudio(){
        guard let url = Bundle.main.url(forResource: CommonUtils.getCallStatusAudioFileName(roomStatus), withExtension: nil)  else {
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            guard let player = player else { return }
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.duckOthers)
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if ringTimer != nil && ringTimer.isValid {
            ringTimer.invalidate()
        }
        ringTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(playAudio), userInfo: nil, repeats: false)
    }
}

extension VideoViewController: VideoCallStatusDelegate {
    func statusChanged(_ stauts: String) {
        
        if roomStatus == R.Const.IS_CALLING {
            self.disconnect()
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
}

























