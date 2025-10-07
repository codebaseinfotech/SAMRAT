//
//  ServicesCell.swift
//  SAMRAT
//
//  Created by Macmini on 13/08/21.
//

import UIKit

class ServicesCell: UITableViewCell {

    @IBOutlet weak var imgSelection: UIImageView!
    @IBOutlet weak var lblServiceName: UILabel!
    @IBOutlet weak var lblNewDetail: UILabel!
    @IBOutlet weak var lblPriceTag: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
