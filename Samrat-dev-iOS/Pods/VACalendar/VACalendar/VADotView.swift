//
//  VADotView.swift
//  VACalendar
//
//  Created by Anton Vodolazkyi on 25.02.18.
//  Copyright © 2018 Vodolazkyi. All rights reserved.
//

import UIKit

class VADotView: UIView {
    
    init(size: CGFloat, color: UIColor) {
        
        let frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        super.init(frame: frame)
        let img = UIImageView(frame: frame)
        img.image = UIImage(imageLiteralResourceName: "line")
        img.contentMode = .scaleToFill
        img.backgroundColor = .clear
        self.addSubview(img)
        //layer.cornerRadius = frame.height / 2
//        isUserInteractionEnabled = false
        clipsToBounds = true
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
