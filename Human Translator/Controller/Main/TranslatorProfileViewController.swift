//
//  TranslatorProfileViewController.swift
//  Human Translator
//
//  Created by Yin on 08/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class TranslatorProfileViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var txvAboutMe: UITextView!
    @IBOutlet weak var imgProfile: UIImageView!    
    @IBOutlet weak var tfGender: UITextField!
    @IBOutlet weak var tfAge: UITextField!
    @IBOutlet weak var tfmyLanguage: UITextField!
    @IBOutlet weak var tfTransLanguage: UITextField!
    @IBOutlet weak var switchBtn: UISwitch!
    
    var selectedTF = UITextField()
    
    var targetUser = UserModel()
    var room_no = ""
    
    let _picker: UIImagePickerController = UIImagePickerController()
    var _imgUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        g_currentVC = self
        
        self._picker.delegate = self
        _picker.allowsEditing = true
        
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initView() {        
        
        imgProfile.layer.borderColor = UIColor.white.cgColor
        imgProfile.layer.borderWidth = 2.0
        
        txvAboutMe.layer.borderWidth = 1.0
        txvAboutMe.layer.borderColor = UIColor.init(red: 230/255.0, green: 81/255.0, blue: 0, alpha: 1.0).cgColor
        
        // init User information
        if let user = currentUser {
            
            self.navigationItem.title = user.name
            self.imgProfile.sd_setImage(with: URL(string: user.photo_url), placeholderImage: #imageLiteral(resourceName: "img_profile"))
            tfGender.text = R.Array.GENDER[user.gender]
            tfAge.text = "\(user.age)"
            tfmyLanguage.text = user.my_language
            tfTransLanguage.text = user.trans_language
            txvAboutMe.text = user.about_me
            if user.is_available == 0 {
                switchBtn.setOn(false, animated: true)
            } else {
                switchBtn.setOn(true, animated: true)
            }
        }
        
    }
    
    @IBAction func onLogout(_ sender: Any) {
        
        UserDefaults.standard.set("", forKey: R.String.KEY_USERID)
        UserDefaults.standard.set("", forKey: R.String.KEY_EMAIL)
        UserDefaults.standard.set("", forKey: R.String.KEY_PASSWORD)        
        
        isLogin = false
        isLogout = true
        ApiRequest.saveToken(token: "", completion: { (rescode) in
            
        })
        
        UIApplication.shared.keyWindow?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavVC") as! UINavigationController
    }
    
    @IBAction func onAttach(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
            && UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        {
            let photoSourceAlert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let galleryAction: UIAlertAction = UIAlertAction(title: R.String.FROM_GALLERY, style: UIAlertActionStyle.default, handler: {
                (photoSourceAlert) -> Void in
                self._picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.present(self._picker, animated: true, completion: nil)
            })
            
            let cameraAction: UIAlertAction = UIAlertAction.init(title: R.String.FROM_CAMERA, style: UIAlertActionStyle.default, handler: { (cameraSourceAlert) in
                self._picker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(self._picker, animated: true, completion: nil)
            })
            
            
            photoSourceAlert.addAction(galleryAction)
            photoSourceAlert.addAction(cameraAction)
            photoSourceAlert.addAction(UIAlertAction(title: R.String.CANCEL, style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(photoSourceAlert, animated: true, completion: nil);
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            
            //self.imgProfile.image = pickedImage
            _imgUrl = saveToFile(image: pickedImage, filePath: R.String.SAVE_ROOT_PATH, fileName: "profile.png")
            
            self.showLoadingView()
            
            ApiRequest.uploadPhoto(_imgUrl, userId: currentUser!.id, completion: { (resultCode, photo_url) in
                
                self.hideLoadingView()
                
                if resultCode == R.Const.CODE_SUCCESS {
                    currentUser?.photo_url = photo_url
                    self.imgProfile.sd_setImage(with: URL(string: photo_url), placeholderImage: #imageLiteral(resourceName: "img_profile"))
                } else {
                    self.showAlertDialog(title: R.String.ERROR, message: R.String.ERROR_CONNECT, positive: R.String.OK, negative: nil)
                }
            })

        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSwitch(_ sender: Any) {
        
        var title = ""
        var pickerArr = [String]()
        let btn = sender as! UIButton
        switch btn.tag {
        case 0:
            selectedTF = tfGender
            pickerArr = R.Array.GENDER
            title = R.String.GENDER
        case 1:
            selectedTF = tfAge
            title = R.String.AGE
            for index in 10...100 {
                pickerArr.append(String(index))
            }
        case 2:
            for name in languageArr {
                pickerArr.append(name.name/* + "," + name.nativeName*/)
            }
            selectedTF = tfmyLanguage
            title = R.String.SEL_LANGUAGE
        default:
            selectedTF = tfTransLanguage
            for name in languageArr {
                pickerArr.append(name.name/* + "," + name.nativeName*/)
            }
            title = R.String.SEL_LANGUAGE
        }
        
        ActionSheetStringPicker.show(withTitle: title, rows: pickerArr, initialSelection: 0, doneBlock: {
            picker, value, index in
            
            print("value = \(value)")
            print("index = \(String(describing: index))")
            print("picker = \(String(describing: picker))")
            self.selectedTF.text = "\(index!)"
            
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    
    }
    
    func isValid() -> Bool {
        
        if tfGender.text?.count == 0 {
            
            self.showAlertDialog(title: R.String.ERROR, message: R.String.CHECK_GENDER_EMPTY, positive: R.String.OK, negative: nil)
            return false
        }
        
        if tfAge.text?.count == 0 {
            
            self.showAlertDialog(title: R.String.ERROR, message: R.String.CHECK_AGE_EMPTY, positive: R.String.OK, negative: nil)
            return false
        }
        
        if tfmyLanguage.text?.count == 0 {
            
            self.showAlertDialog(title: R.String.ERROR, message: R.String.CHECK_MYLANGUAGE, positive: R.String.OK, negative: nil)
            return false
        }
        
        if tfTransLanguage.text?.count == 0 {
            
            self.showAlertDialog(title: R.String.ERROR, message: R.String.CHECK_TRANS_LANGUAGE, positive: R.String.OK, negative: nil)
            return false
        }
        
        if txvAboutMe.text?.count == 0 {
            
            self.showAlertDialog(title: R.String.ERROR, message: R.String.CHECK_ABOUTME, positive: R.String.OK, negative: nil)
            return false
        }
        
        return true
    }
    
    @IBAction func onSave(_ sender: Any) {
        
        if isValid() {
            
            let user = UserModel()
            user.id = currentUser!.id
            user.gender = tfGender.text == R.Array.GENDER[0] ? 0 : 1
            user.age = Int(tfAge.text!)!
            user.my_language = tfmyLanguage.text!
            user.trans_language = tfTransLanguage.text!
            user.about_me = txvAboutMe.text
            user.is_available = switchBtn.isOn ? 1 : 0
            
            showLoadingView()
            
            ApiRequest.updateProfile(user, completion: { (resCode) in
                
                self.hideLoadingView()
                
                if resCode == R.Const.CODE_SUCCESS {
                    self.showToast(R.String.SUCCESS_UPDATE)
                } else {
                    self.showAlertDialog(title: R.String.ERROR, message: R.String.ERROR_CONNECT, positive: R.String.OK, negative: nil)
                }
            })
        }
    }
    
    @IBAction func onChange(_ sender: Any) {
        
        var is_available = 0
        let statusBtn = sender as! UISwitch
        
        if statusBtn.isOn {
            is_available = 1
        } else {
            is_available = 0
        }
        
        self.showLoadingView()
        
        ApiRequest.setAvailable(is_available) { (resCode) in
            
            self.hideLoadingView()
            
            if resCode != R.Const.CODE_SUCCESS {
           
                self.showAlertDialog(title: R.String.ERROR, message: R.String.ERROR_CONNECT, positive: R.String.OK, negative: nil)
            }
        }
    }
    
}




