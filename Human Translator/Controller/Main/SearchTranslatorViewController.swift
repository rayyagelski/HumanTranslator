//
//  SearchTranslatorViewController.swift
//  Human Translator
//
//  Created by Yin on 08/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import UIKit

class SearchTranslatorViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblTranslators: UITableView!
    
    var my_language = ""
    var trans_language = ""
    
    var translatorList = [UserModel]()
    
    var selTranslator = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tblTranslators.tableFooterView = UIView()
        
        self.getTranslators()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        
        if isCalled {
            let rateVC = self.storyboard?.instantiateViewController(withIdentifier: "RateViewController") as! RateViewController
            rateVC.rateUser = self.selTranslator
            self.navigationController?.present(rateVC, animated: true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getTranslators() {
        
        self.showLoadingView()
        
        ApiRequest.searchTranslator(my_language, trans_language: trans_language) { (resCode, translators) in
            
            self.hideLoadingView()
            
            if resCode == R.Const.CODE_SUCCESS {
                
                self.translatorList = translators
                self.tblTranslators.reloadData()
            }
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Translator TableView Delegate datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return translatorList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TranslatorCell") as! TranslatorCell
        
        let translator = translatorList[indexPath.row]
        
        cell.lblName.text = translator.name
        cell.lblGenderAge.text = R.Array.GENDER[translator.gender] + ", \(translator.age)"
        cell.ratingView.rating = Double(translator.avg_mark)
        cell.imvProfile.sd_setImage(with: URL(string: translator.photo_url), placeholderImage: #imageLiteral(resourceName: "img_profile"))
        
        if translator.is_available == 0 {
            cell.imvStatus.image = #imageLiteral(resourceName: "ic_unchecked")
            cell.lblStatus.text = "Offline"
        } else {
            cell.imvStatus.image = #imageLiteral(resourceName: "ic_checked")
            cell.lblStatus.text = "Online"
        }
        
        cell.ratingView.settings.updateOnTouch = false
        cell.btnCall.tag = indexPath.row
        cell.btnCall.addTarget(self, action: #selector(gotoCall), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailInfoViewController") as! DetailInfoViewController
        detailVC.selectedTranslator = translatorList[indexPath.row]
        detailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }

    
    @objc func gotoCall(_ sender: UIButton) {
        
        selTranslator = translatorList[sender.tag]
        
        if selTranslator.is_available == 1 {
        
            let videoVC = self.storyboard?.instantiateViewController(withIdentifier: "VideoViewController") as! VideoViewController
            videoVC.user = selTranslator
            videoVC.roomStatus = R.Const.IS_CALLING
            videoVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(videoVC, animated: true)
            
        } else {
            self.showAlertDialog(title: R.String.ERROR, message: R.String.NON_AVAILABLE, positive: R.String.OK, negative: nil)
        }
    }
    

}
