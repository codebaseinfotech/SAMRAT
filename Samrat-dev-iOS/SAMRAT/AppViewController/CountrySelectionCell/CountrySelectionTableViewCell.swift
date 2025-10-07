//
//  CountrySelectionTableViewCell.swift
//  SAMRAT
//
//  Created by Ajay Veer on 09/08/22.
//

import UIKit

class CountrySelectionTableViewCell: UITableViewCell {
    @IBOutlet weak var imgSelection: UIImageView!
    
    @IBOutlet weak var imgSelectedCountry: UIImageView!
    @IBOutlet weak var lblSelectedCountry: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
