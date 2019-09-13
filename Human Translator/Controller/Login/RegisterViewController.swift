//
//  RegisterViewController.swift
//  Human Translator
//
//  Created by Yin on 08/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import UIKit

class RegisterViewController: BaseViewController {

    @IBOutlet weak var imvActorCheck: UIImageView!
    @IBOutlet weak var imvTranslatorCheck: UIImageView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    var user = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        isActor = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSwitch(_ sender: Any) {
        
        let btn = sender as! UIButton
        let tag = btn.tag
        if tag == 0 {
            imvActorCheck.image = #imageLiteral(resourceName: "ic_checked")
            imvTranslatorCheck.image = #imageLiteral(resourceName: "ic_unchecked")
            isActor = true
        } else {
            imvActorCheck.image = #imageLiteral(resourceName: "ic_unchecked")
            imvTranslatorCheck.image = #imageLiteral(resourceName: "ic_checked")
            isActor = false
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
   
    @IBAction func onSignup(_ sender: Any) {
        
        if isValid() {
            
            user.email = tfEmail.text!
            user.name = tfName.text!
            user.password = tfPassword.text!
            user.user_type = isActor ? 0 : 1
            
            self.showLoadingView()
            
            ApiRequest.register(user, completion: { (resultCode, user_id)  in
                
                self.hideLoadingView()
                
                if resultCode == R.Const.CODE_SUCCESS {
                    self.user.id = user_id
                    currentUser = self.user
                    
                    //save token
                    if let token = UserDefaults.standard.string(forKey: R.String.KEY_TOKEN) {
                        ApiRequest.saveToken(token: token, completion: { (rescode) in
                        })
                    }
                    self.gotoMain()
                    
                } else if resultCode == R.Const.CODE_ALREADY_EXIST {
                    self.showAlertDialog(title: R.String.ERROR, message: R.String.EXIST_EMAIL, positive: R.String.OK, negative: nil)
                } else {
                    self.showAlertDialog(title: R.String.ERROR, message: R.String.ERROR_CONNECT, positive: R.String.OK, negative: nil)
                }
            })
        }
    }
    
    func isValid() -> Bool {
        
        if tfName.text?.count == 0 {
            self.showAlertDialog(title: R.String.ERROR, message: R.String.CHECK_NAME_EMPTY, positive: R.String.OK, negative: nil)
            return false
        }
        
        if tfEmail.text?.count == 0 {
            self.showAlertDialog(title: R.String.ERROR, message: R.String.CHECK_EMAIL_EMPTY, positive: R.String.OK, negative: nil)
            return false
        }
        
        if !CommonUtils.isValidEmail(tfEmail.text!) {
            self.showAlertDialog(title: R.String.APP_NAME, message: R.String.CHECK_EMAIL_INVALID, positive: R.String.OK, negative: nil)
            return false
        }
        
        if tfPassword.text?.count == 0 {
            self.showAlertDialog(title: R.String.APP_NAME, message: R.String.CHECK_PASSWORD_EMPTY, positive: R.String.OK, negative: nil)
            return false
        }
        
        return true
    }
    
    func gotoMain() {
        
        if isActor {
            UIApplication.shared.keyWindow?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "ActorNavVC") as! UINavigationController
        } else {
            UIApplication.shared.keyWindow?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "TranslatorNavVC") as! UINavigationController
        }
    }
}
