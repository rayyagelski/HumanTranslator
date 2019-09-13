//
//  CallingViewController.swift
//  Human Translator
//
//  Created by Yin on 09/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import UIKit

class CallingViewController: BaseViewController {
    
    var user = UserModel()
    var status = 0
    var type = 0 // 0: call request, 1: request received and accept
    
    var alertTimer : Timer!
    
    var timerCount = 0
 
    @IBOutlet weak var callDeclineButton: UIButton!
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var lblGenderAge: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
        initView()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        
        imvPhoto.layer.borderColor = UIColor.white.cgColor
        imvPhoto.layer.borderWidth = 2.0
        imvPhoto.layer.masksToBounds = true
        
        lblName.text = user.name
        imvPhoto.sd_setImage(with: URL(string: user.photo_url), placeholderImage: #imageLiteral(resourceName: "img_profile"))
        lblGenderAge.text = R.Array.GENDER[user.gender] + ", \(user.age)"
        
        if status == R.Const.IS_CALLING {
            
            callDeclineButton.isHidden = false
        }
        else {
            callDeclineButton.isHidden = true
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onCall(_ sender: Any) {
        
        self.view.superview?.isHidden = true
        let parentVC = self.parent as! VideoViewController
        parentVC.connectToChatRoom()
        parentVC.pauseAudio()
    }
    

    @IBAction func declineButtonTapped(_ sender: UIButton) {
        //self.view.isUserInteractionEnabled = false
        
        if status == R.Const.IS_CALLING {
            let videoVC = self.parent as! VideoViewController
            
            ApiRequest.rejectRequest(target_id: user.id, room_no: videoVC.roomName, completion: { (resCode) in
                
            })
            
            if self.alertTimer != nil && self.alertTimer.isValid {
                self.alertTimer.invalidate()
            }
            //self.view.isUserInteractionEnabled = true
            
            videoVC.disconnect()
        }
            
        else {
            
            declineCall()

        }
    }
    
    func declineCall() {
        
        if self.alertTimer != nil && self.alertTimer.isValid {
            self.alertTimer.invalidate()
        }
        if let videoVC = self.parent as? VideoViewController {
            videoVC.pauseAudio()
            videoVC.disconnect()
            ApiRequest.rejectRequest(target_id: user.id, room_no: videoVC.roomName, completion: { (resCode) in
                
            })
        }
        
        if isLogin {
            self.navigationController?.dismiss(animated: false, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavVC") as! UINavigationController
        }
        
        
    }
}
