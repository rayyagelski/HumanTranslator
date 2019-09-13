//
//  ActorProfileViewController.swift
//  Human Translator
//
//  Created by Yin on 08/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SDWebImage


class ActorProfileViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {


    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var tfGender: UITextField!
    @IBOutlet weak var tfAge: UITextField!

    
    var selectedTF = UITextField()
    
    let _picker: UIImagePickerController = UIImagePickerController()
    var _imgUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        g_currentVC = self
        
        // Do any additional setup after loading the view.
        
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
        
        // init User information
        self.navigationItem.title = currentUser!.name
        self.imgProfile.sd_setImage(with: URL(string: currentUser!.photo_url), placeholderImage: #imageLiteral(resourceName: "img_profile"))
        tfGender.text = R.Array.GENDER[currentUser!.gender]
        tfAge.text = "\(currentUser!.age)"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    @IBAction func onPicker(_ sender: Any) {
        
        var title = ""
        var pickerArr = [String]()
        let btn = sender as! UIButton
        switch btn.tag {
        case 0:
            selectedTF = tfGender
            pickerArr = R.Array.GENDER
            title = R.String.GENDER
        default:
            selectedTF = tfAge
            title = R.String.AGE
            for index in 10...100 {
                pickerArr.append(String(index))
            }
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
        
        return true
    }
    
    @IBAction func onSave(_ sender: Any) {
        
        if isValid() {
            
            let user = UserModel()
            
            user.id = currentUser!.id
            user.gender = tfGender.text == R.Array.GENDER[0] ? 0 : 1
            user.age = Int(tfAge.text!)!
                        
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
}
