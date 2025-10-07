//
//  MusiciansTVCell.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 27/04/21.
//

import UIKit

class MusiciansTVCell: UITableViewCell {

    @IBOutlet weak var imgSelectedStatus: UIImageView!
    @IBOutlet weak var lblMusicianName: UILabel!
    @IBOutlet weak var lblMusicanDesc: UILabel!
    @IBOutlet weak var btnBook: UIButton!
    @IBOutlet var imgViewmusician: UIImageView!
    @IBOutlet weak var btnMoreInfo: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnMoreInfo.setTitle(Localized("More Info"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setImage(str: String?) {
        imgViewmusician.downloadImage(str: str)
    }
}
