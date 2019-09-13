//
//  MyReviewViewController.swift
//  Human Translator
//
//  Created by Yin on 11/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import UIKit

class MyReviewViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblReview: UITableView!
    
    var reviewList = [ReviewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tblReview.rowHeight = UITableViewAutomaticDimension
        tblReview.estimatedRowHeight = 72
        
        getReviews()
        
        tblReview.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    
    func getReviews() {
        
        self.showLoadingView()
        
        ApiRequest.getReview(currentUser!.id) { (resCode, reviews) in
            
            self.hideLoadingView()
            
            if resCode == R.Const.CODE_SUCCESS {
                
                self.reviewList = reviews
                self.tblReview.reloadData()
            }
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
