//
//  RateViewController.swift
//  Human Translator
//
//  Created by Yin on 09/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import UIKit
import Cosmos

class RateViewController: BaseViewController {

    @IBOutlet weak var txvReview: UITextView!
    @IBOutlet weak var imvProfile: UIImageView!
    @IBOutlet weak var rateView: CosmosView!
    
    var rateUser = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        isCalled = false
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        txvReview.layer.borderColor = UIColor.init(red: 230/255.0, green: 81/255.0, blue: 0, alpha: 1).cgColor
        txvReview.layer.borderWidth = 1.0
    
        imvProfile.layer.borderColor = UIColor.white.cgColor
        imvProfile.layer.borderWidth = 1.0
        
        imvProfile.sd_setImage(with: URL(string: rateUser.photo_url), placeholderImage: #imageLiteral(resourceName: "img_profile"))
    }
    
    func isValid() -> Bool {
        
        if rateView.rating == 0 {
            
            self.showAlertDialog(title: R.String.ERROR, message: R.String.INVALID_RATING, positive: R.String.OK, negative: nil)
            return false
        }
        
        if (txvReview.text!.count < 6) {
            self.showAlertDialog(title: R.String.ERROR, message: R.String.INVAILD_REVIEW_LETTER, positive: R.String.OK, negative: nil)
            return false
        }
        
        return true
    }

    @IBAction func onRate(_ sender: Any) {
        
        if isValid() {
            
            self.showLoadingView()
            
            ApiRequest.writeReview(target_id: rateUser.id, mark: Float(rateView.rating), review: txvReview.text!, completion: { (resCode) in
                
                self.hideLoadingView()
                
                if resCode == R.Const.CODE_SUCCESS {
                    
                    self.showToast(R.String.SUCCESS_RATE)
                    self.perform(#selector(self.gotoBack), with: nil, afterDelay: 1.0)
                    
                } else {
                    self.showAlertDialog(title: R.String.ERROR, message: R.String.ERROR_CONNECT, positive: R.String.OK, negative: nil)
                }
                
            })
            
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        gotoBack()
    }
    
    @objc func gotoBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
