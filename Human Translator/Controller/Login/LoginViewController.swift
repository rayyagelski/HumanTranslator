//
//  LoginViewController.swift
//  Human Translator
//
//  Created by Yin on 08/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    var rLanArray = [LanguageModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initSetup()
        
        // for test
        //tfEmail.text = "yin@user.com"
        //tfPassword.text = "123456"
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initSetup() {
        // get language list from json file
        if let path = Bundle.main.path(forResource: "languages", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                    // do stuff
                    
                    let keys = jsonResult.keys
                    languageArr.removeAll()
                    rLanArray.removeAll()
                    for key in keys {
                        let languageModel = LanguageModel()
                        languageModel.code = key
                        
                        languageModel.name = jsonResult[key]!["name"] as! String
                        languageModel.nativeName = jsonResult[key]!["nativeName"] as! String
                        rLanArray.append(languageModel)
                        
                    }
                }
            } catch {
                // handle error
                print("catch error")
            }
            languageArr = rLanArray.sorted {
                $0.name < $1.name
            }            
        }
        
        if let email = UserDefaults.standard.string(forKey: R.String.KEY_EMAIL) {
            tfEmail.text = email
            tfPassword.text = UserDefaults.standard.string(forKey: R.String.KEY_PASSWORD)
            
            //if email.count > 0 {
            //    login()
            //}
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
    
    @IBAction func doLogin(_ sender: Any) {
        
        login()
    }
    
    func login() {
        
        if isValid() {
            
            self.showLoadingView()
            
            ApiRequest.login(tfEmail.text!, password: tfPassword.text!) { (resCode) in
                
                self.hideLoadingView()
                
                if resCode == R.Const.CODE_SUCCESS {
                    isActor = currentUser!.user_type == 0 ? true : false
                    
                    isLogin = true
                    self.gotoMain()
                    
                    // register token
                    if let token = UserDefaults.standard.string(forKey: R.String.KEY_TOKEN) {
                        ApiRequest.saveToken(token: token, completion: { (rescode) in
                        })
                    }
                    
                } else if resCode == R.Const.CODE_NON_EXIST {
                    self.showAlertDialog(title: R.String.ERROR, message: R.String.UNREGISTERED_USER, positive: R.String.OK, negative: nil)
                } else  if resCode == R.Const.CODE_WRONG_PWD {
                    self.showAlertDialog(title: R.String.ERROR, message: R.String.WRONG_PASSWORD, positive: R.String.OK, negative: nil)
                } else {
                    self.showAlertDialog(title: R.String.ERROR, message: R.String.ERROR_CONNECT, positive: R.String.OK, negative: nil)
                }
            }
        }
    }
    
    func gotoMain() {
        
        if isActor {
            UIApplication.shared.keyWindow?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "ActorNavVC") as! UINavigationController
        } else {
            UIApplication.shared.keyWindow?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "TranslatorNavVC") as! UINavigationController
        }
    }
}
