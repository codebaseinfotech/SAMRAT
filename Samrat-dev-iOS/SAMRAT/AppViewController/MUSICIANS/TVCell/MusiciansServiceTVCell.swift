//
//  MusiciansTVCell.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 27/04/21.
//

import UIKit
import iOSDropDown
class MusiciansServiceTVCell: UITableViewCell {

    @IBOutlet weak var imgSelectedStatus: UIImageView!
    @IBOutlet weak var lblMusicianName: UILabel!
    @IBOutlet weak var lblMusicanDesc: UILabel!
    @IBOutlet weak var btnBook: UIButton!
   
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    @IBOutlet weak var txtDropDownHeight: NSLayoutConstraint!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblHours: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblLineView: UIView!
    
    @IBOutlet weak var lblDurationWidth: NSLayoutConstraint!
    @IBOutlet weak var txtDropDown: DropDown!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if Language.shared.isArabic {
            self.txtDropDown.semanticContentAttribute = .forceRightToLeft
            self.txtDropDown.textAlignment = .right
           
        } else {
            self.txtDropDown.semanticContentAttribute = .forceLeftToRight
            self.txtDropDown.textAlignment = .left
        }
        
        if Language.shared.isArabic {
            lblMusicianName.semanticContentAttribute = .forceRightToLeft
            lblMusicanDesc.semanticContentAttribute = .forceRightToLeft
            lblPrice.semanticContentAttribute = .forceRightToLeft
               //UITabBar.appearance().semanticContentAttribute = .forceRightToLeft
               //UIVisualEffectView.appearance().semanticContentAttribute = .forceRightToLeft
           } else {
               lblMusicianName.semanticContentAttribute = .forceLeftToRight
               lblMusicanDesc.semanticContentAttribute = .forceLeftToRight
               lblPrice.semanticContentAttribute = .forceLeftToRight
               //UIVisualEffectView.appearance().semanticContentAttribute = .forceLeftToRight
               //UITabBar.appearance().semanticContentAttribute = .forceLeftToRight
           }
        self.lblDuration.text = Localized("duration")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
