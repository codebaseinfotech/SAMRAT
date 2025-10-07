//
//  onlinePaymentMusiciansCell.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 28/04/21.
//

import UIKit

class onlinePaymentMusiciansCell: UITableViewCell {

    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblDescriptioon: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
