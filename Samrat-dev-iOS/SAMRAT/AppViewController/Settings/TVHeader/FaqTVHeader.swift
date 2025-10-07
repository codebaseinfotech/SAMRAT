//
//  FaqTVHeader.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 27/04/21.
//

import UIKit

class FaqTVHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgStatus: UIImageView!
    
    var onTapHeaderAct:(()->())? = nil
    
    
    @IBAction func onTapHeaderAction(_ sender: UIControl) {
        if let getAct = self.onTapHeaderAct {
            getAct()
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
