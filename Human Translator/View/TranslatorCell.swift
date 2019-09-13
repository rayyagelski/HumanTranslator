//
//  TranslatorCell.swift
//  Human Translator
//
//  Created by Yin on 09/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import UIKit
import Cosmos

class TranslatorCell: UITableViewCell {

    @IBOutlet weak var imvProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblGenderAge: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var imvStatus: UIImageView!
    @IBOutlet weak var btnCall: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
