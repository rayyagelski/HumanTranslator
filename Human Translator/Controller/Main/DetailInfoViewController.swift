//
//  DetailInfoViewController.swift
//  Human Translator
//
//  Created by Yin on 09/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import UIKit
import Cosmos

class DetailInfoViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var imvProfile: UIImageView!
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var aboutMeView: UIView!
    @IBOutlet weak var tblReview: UITableView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblGenderAge: UILabel!
    @IBOutlet weak var imvStatus: UIImageView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var txvAboutMe: UITextView!
    
    var selectedTranslator = UserModel()
    var reviewList = [ReviewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        tblReview.rowHeight = UITableViewAutomaticDimension
        tblReview.estimatedRowHeight = 72
        
        ratingView.settings.updateOnTouch = false
        
        profileView.layer.borderColor = UIColor.init(red: 230/255.0, green: 81/255.0, blue: 0, alpha: 1).cgColor
        profileView.layer.borderWidth = 1.0
        
        aboutMeView.layer.borderColor = UIColor.init(red: 230/255.0, green: 81/255.0, blue: 0, alpha: 1).cgColor
        aboutMeView.layer.borderWidth = 1.0
        
        tblReview.tableFooterView = UIView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        
        setupInfo()
        
        if isCalled {
            let rateVC = self.storyboard?.instantiateViewController(withIdentifier: "RateViewController") as! RateViewController
            rateVC.rateUser = self.selectedTranslator
            self.navigationController?.present(rateVC, animated: true, completion: nil)
        } else {
            getReviews()
        }
    }
    
    func setupInfo() {
        
        self.navigationItem.title = selectedTranslator.name        
        
        imvProfile.sd_setImage(with: URL(string: selectedTranslator.photo_url), placeholderImage: #imageLiteral(resourceName: "img_profile"))
        ratingView.rating = Double(selectedTranslator.avg_mark)
        lblName.text = selectedTranslator.name
        lblGenderAge.text = R.Array.GENDER[selectedTranslator.gender] + ", \(selectedTranslator.age)"
        
        if selectedTranslator.is_available == 0 {
            imvStatus.image = #imageLiteral(resourceName: "ic_unchecked")
            lblStatus.text = "Offline"
        } else {
            imvStatus.image = #imageLiteral(resourceName: "ic_checked")
            lblStatus.text = "Online"
        }
        
        txvAboutMe.text = selectedTranslator.about_me
        
    }
    
    func getReviews() {
        
        reviewList.removeAll()
        
        self.showLoadingView()
        
        ApiRequest.getReview(selectedTranslator.id) { (resCode, reviews) in
            
            self.hideLoadingView()
            
            if resCode == R.Const.CODE_SUCCESS {
                
                self.reviewList = reviews
                self.tblReview.reloadData()
            }
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onCall(_ sender: Any) {
        
        if selectedTranslator.is_available == 1 {
            
            let videoVC = self.storyboard?.instantiateViewController(withIdentifier: "VideoViewController") as! VideoViewController
            videoVC.user = selectedTranslator
            videoVC.roomStatus = R.Const.IS_CALLING
            videoVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(videoVC, animated: true)
        } else {
            self.showAlertDialog(title: R.String.ERROR, message: R.String.NON_AVAILABLE, positive: R.String.OK, negative: nil)
        }
    }
    
    
    //MARK:- Review TableView delegate & datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell") as! ReviewCell
        
        let review = reviewList[indexPath.row]
        
        cell.lblName.text = review.name
        cell.imvProfile.sd_setImage(with: URL(string: review.photo_url), placeholderImage: #imageLiteral(resourceName: "img_profile"))
        cell.ratingView.rating = Double(review.mark)
        cell.lblReview.text = review.review
        
        return cell
    }

}
