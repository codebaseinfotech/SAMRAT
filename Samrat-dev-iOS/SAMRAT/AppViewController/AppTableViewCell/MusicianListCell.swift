//
//  MusicianListCell.swift
//  SAMRAT
//
//  Created by Mohsin Baloch on 17/06/21.
//

import UIKit

class MusicianListCell: UITableViewCell {
    @IBOutlet weak var viewBase: UIView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var imageViewProduct: UIImageView!
    @IBOutlet weak var imgControl: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDecription: UILabel!
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var progressCircle: CircularProgressBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewContent.layer.cornerRadius = 20.0
        viewContent.clipsToBounds = true
        
        roundView.layer.cornerRadius = 15.0
        roundView.clipsToBounds = true
        
        btnPlay.imageEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setImage(str: String?) {
        imageViewProduct.downloadImage(str: str)
    }
}
