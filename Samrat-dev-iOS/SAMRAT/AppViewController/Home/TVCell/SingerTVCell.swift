//
//  SingerTVCell.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 03/05/21.
//

import UIKit

class SingerTVCell: UITableViewCell {
    
    @IBOutlet weak var viewBase: UIView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var imageViewProduct: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDecription: UILabel!
    @IBOutlet weak var btnBook: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewBase.layer.cornerRadius = 20.0
        viewBase.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setImage(str: String?) {
        imageViewProduct.downloadImage(str: str)
    }
}
