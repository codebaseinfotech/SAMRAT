//
//  MusiciansTVFooter.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 30/04/21.
//

import UIKit

class MusiciansTVFooter: UITableViewHeaderFooterView {
    @IBOutlet var btnNext: UIButton!
    
    var onTapNextAction:(()->())? = nil
    @IBAction func btnNextAction(_ sender: UIButton) {
        if let nextAct = self.onTapNextAction {
            nextAct()
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

