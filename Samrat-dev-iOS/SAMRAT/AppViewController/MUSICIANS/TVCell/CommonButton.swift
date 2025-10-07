//
//  CommonButton.swift
//  SAMRAT
//
//  Created by Ajay Veer on 25 Feb 2022
//

import UIKit

class CommonButton: UITableViewCell {

    @IBOutlet var btnNext: UIButton!
    
    var onTapNextAction:(()->())? = nil
    @IBAction func btnNextAction(_ sender: UIButton) {
        if let nextAct = self.onTapNextAction {
            nextAct()
        }
        
    }
}
