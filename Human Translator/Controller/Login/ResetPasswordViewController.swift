//
//  ResetPasswordViewController.swift
//  Human Translator
//
//  Created by Yin on 09/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import UIKit

class ResetPasswordViewController: BaseViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func onResetPassword(_ sender: Any) {
    
        if isValid() {
            resetPassword()
        }
    }
    
    func isValid() -> Bool {
        
        if tfEmail.text?.count == 0 {
            
            self.showAlertDialog(title: R.String.ERROR, message: R.String.CHECK_EMAIL_EMPTY, positive: R.String.OK, negative: nil)
            return false
        }
        
        if tfPassword.text?.count == 0 {
            self.showAlertDialog(title: R.String.ERROR, message: R.String.CHECK_PASSWORD_EMPTY, positive: R.String.OK, negative: nil)
            return false
        }
        
        return true
    }
    
    func resetPassword() {
        
        if isValid() {
            
            self.showLoadingView()
            
            ApiRequest.resetPassword(tfEmail.text!, password: tfPassword.text!) { (resCode) in
                
                self.hideLoadingView()
                
                if resCode == R.Const.CODE_SUCCESS {
                    
                    self.showToast(R.String.SUCCESS_RESETPWD)
                    self.perform(#selector(self.gotoBack), with: nil, afterDelay: 1.0)
                    
                } else if resCode == R.Const.CODE_NON_EXIST {
                    self.showAlertDialog(title: R.String.ERROR, message: R.String.UNREGISTERED_USER, positive: R.String.OK, negative: nil)
                } else {
                    self.showAlertDialog(title: R.String.ERROR, message: R.String.ERROR_CONNECT, positive: R.String.OK, negative: nil)
                }
            }
        }
    }
    
    @objc func gotoBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
