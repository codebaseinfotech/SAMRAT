//
//  AlertView.swift
//  Yummi
//
//  Created by Mohsin Baloch on 22/07/20.
//  Copyright © 2020 HypeTen. All rights reserved.
//

import Foundation
import UIKit

protocol AlertViewDelegate{
    func okayButtonTapped()
    
    func cancleButtonTapped()
}

class AlertView : UIView{
    static let instance = AlertView()
    
    var alertViewDelegate : AlertViewDelegate?
    
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var btnStackView: UIStackView!
    @IBOutlet weak var btnCancel: UIButton!{
        didSet{
            btnCancel.addTarget(self, action: #selector(btnCancleTapped(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet weak var btnOkay: UIButton!{
        didSet{
            btnOkay.addTarget(self, action: #selector(btnOkayTapped(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var alertView: UIView!
    var okCompletion: (() -> ())? = nil
    var cancelCompletion: (() -> ())? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("AlertView", owner: self, options: nil)
        commonInit()
    }
    
    @IBAction func btnCancleTapped (_ sender: UIButton){
        parentView.removeFromSuperview()
        cancelCompletion?()
//        if Language.shared.isArabic {
//            alertViewDelegate?.okayButtonTapped()
//        } else {
            alertViewDelegate?.cancleButtonTapped()
//        }
    }
    
    @IBAction func btnOkayTapped (_ sender: UIButton){
        parentView.removeFromSuperview()
        okCompletion?()
//        if Language.shared.isArabic {
//            alertViewDelegate?.cancleButtonTapped()
//        } else {
            alertViewDelegate?.okayButtonTapped()
//        }
    }
    
    private func commonInit(){
//        btnOkay.layer.cornerRadius = 8
//        btnOkay.layer.masksToBounds = true
        
        parentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        parentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        alertView.clipsToBounds = true
//        okbuttonCenterConstraint.constant = 0
//        alertBoxHeghtConstraint.constant = 365
//        alertView.layer.cornerRadius = 16
//        alertView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum AlertType{
        case twoButton
        case oneButton
    }
    
    func showAlert(title: String, arrMessages: [String], alertType: AlertType, firstButton: String = Localized("Agree"), secondButton: String = Localized("Cancel")){
        self.lblTitle.text = title
        self.lblMessage.text = nil
        self.lblMessage.layoutIfNeeded()
        okCompletion = nil
        cancelCompletion = nil
        
        stackView.subviews.forEach { vie in
            if vie.isKind(of: UIStackView.self) {
                stackView.removeArrangedSubview(vie)
                vie.removeFromSuperview()
            }
            if vie.isKind(of: UILabel.self) {
                if vie.tag == 222 {
                    stackView.removeArrangedSubview(vie)
                    vie.removeFromSuperview()
                }
            }
        }
        
//        arrMessages.forEach { val in
//            stackView.addArrangedSubview(addLabel(str: val))
//        }
        stackView.spacing = 0
        for (I,V) in arrMessages.enumerated() {
            JSN.log("print ===>%@", I)
            JSN.log("print ===>%@", V)
            let lbl3 = UILabel()
            lbl3.textColor = .clear
            lbl3.text = "  "
            lbl3.tag = 222
            if Language.shared.isArabic {
                lbl3.textAlignment = .right
            }
            lbl3.numberOfLines = 1
            lbl3.layer.name = "dynamiclabel"
            lbl3.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            
            stackView.addArrangedSubview(addLabel(str: V))
            if I == 0 || I == 3 || I == 4 || I == 5  {
                stackView.addArrangedSubview(lbl3)
            }
        }
        
        
        switch alertType {
        case .twoButton:
            if Language.shared.isArabic {
                btnStackView.removeArrangedSubview(btnOkay)
                btnStackView.setNeedsLayout()
                btnStackView.layoutIfNeeded()
                
                btnStackView.insertArrangedSubview(btnOkay, at: 0)
                btnStackView.setNeedsLayout()
            } else {
                btnStackView.removeArrangedSubview(btnOkay)
                btnStackView.setNeedsLayout()
                btnStackView.layoutIfNeeded()
                
                btnStackView.insertArrangedSubview(btnOkay, at: 1)
                btnStackView.setNeedsLayout()
            }
            btnCancel.isHidden = false
            self.lblMessage.textAlignment = Language.shared.isArabic ? .right : .left
            self.btnOkay.setTitle(firstButton, for: .normal)
            self.btnCancel.setTitle(secondButton, for: .normal)
            
//            self.btnOkay.backgroundColor = Language.shared.isArabic ? .white : hexStringToUIColor(hex: "#CC8A65")
//            self.btnCancel.backgroundColor = Language.shared.isArabic ? hexStringToUIColor(hex: "#CC8A65") : .white
//            self.btnCancel.setTitleColor(Language.shared.isArabic ? .white : hexStringToUIColor(hex: "#CC8A65"), for: .normal)
//            self.btnOkay.setTitleColor(Language.shared.isArabic ? hexStringToUIColor(hex: "#CC8A65") : .white, for: .normal)
        case .oneButton:
            btnCancel.isHidden = true
            self.btnOkay.setTitle(Localized("ok"), for: .normal)
            self.lblMessage.textAlignment = .center
            self.btnOkay.backgroundColor = hexStringToUIColor(hex: "#CC8A65")
            self.btnOkay.setTitleColor(.white, for: .normal)
        }
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(parentView)
    }
    
    func addLabel(str: String) -> UIStackView {
        let stackViewLabels = UIStackView()
        stackViewLabels.axis = .horizontal
        stackViewLabels.spacing = 3
        stackViewLabels.distribution = .fillProportionally
        stackViewLabels.alignment = .top
        
        let lbl = UILabel()
        lbl.textColor = hexStringToUIColor(hex: "#CC8A65")
        
        if Localized("singerSelectAlert6") == str {
            lbl.text = " "
            stackViewLabels.frame.origin.x = 10
        } else if Localized("singerSelectAlert7") == str {
            lbl.text = " "
            stackViewLabels.frame.origin.x = 10
        } else{
            lbl.text = "\u{2022}"
        }
        
        
        lbl.layer.name = "dynamiclabel"
        lbl.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.widthAnchor.constraint(equalToConstant: 15).isActive = true
        lbl.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        let lbl2 = UILabel()
        lbl2.textColor = .black
        
        
//        if Localized("singerSelectAlert6") == str {
//            lbl2.text = "- \(str)"
//        } else if Localized("singerSelectAlert7") == str {
//            lbl2.text = "- \(str)"
//        } else{
            lbl2.text = str
        //}
        
        if Language.shared.isArabic {
            lbl2.textAlignment = .right
        }
        lbl2.numberOfLines = 0
        lbl2.layer.name = "dynamiclabel"
        lbl2.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        
        stackViewLabels.addArrangedSubview(lbl)
        stackViewLabels.addArrangedSubview(lbl2)
        
        return stackViewLabels
    }
    
    func showAlert(title: String, message: NSAttributedString, alertType: AlertType, firstButton: String = Localized("ok"), secondButton: String = Localized("Cancel"),isChangePlace:Bool = false, okHandler:(() -> ())? = nil, cancelHandler:(() -> ())? = nil) {
        self.lblTitle.text = title
        self.lblMessage.attributedText = message
        self.lblMessage.layoutIfNeeded()
        self.okCompletion = okHandler
        self.cancelCompletion = cancelHandler
//        alertBoxHeghtConstraint.constant = self.lblMessage.bounds.height + 110
        
        stackView.subviews.forEach { vie in
            if vie.isKind(of: UIStackView.self) {
                stackView.removeArrangedSubview(vie)
                vie.removeFromSuperview()
            }
        }
        
        switch alertType {
        case .twoButton:
            btnCancel.isHidden = false
//            okbuttonCenterConstraint.constant = 60
            self.lblMessage.textAlignment = .center //Language.shared.isArabic ? .right : .left
            if isChangePlace == true {
                self.btnCancel.setTitle(firstButton, for: .normal)
                self.btnOkay.setTitle(secondButton, for: .normal)
                
                self.btnOkay.backgroundColor = hexStringToUIColor(hex: "#CC8A65")
                self.btnCancel.backgroundColor = .white
                self.btnCancel.setTitleColor(hexStringToUIColor(hex: "#CC8A65"), for: .normal)
                self.btnOkay.setTitleColor(.white, for: .normal)
            }else {
                self.btnOkay.setTitle(firstButton, for: .normal)
                self.btnCancel.setTitle(secondButton, for: .normal)
                self.btnOkay.backgroundColor = hexStringToUIColor(hex: "#CC8A65")
                self.btnCancel.backgroundColor = .white
                self.btnCancel.setTitleColor(hexStringToUIColor(hex: "#CC8A65"), for: .normal)
                self.btnOkay.setTitleColor(.white, for: .normal)
            }
        case .oneButton:
            btnCancel.isHidden = true
            self.btnOkay.setTitle(firstButton, for: .normal)
//            okbuttonCenterConstraint.constant = 0
            self.lblMessage.textAlignment = .center
            self.btnOkay.backgroundColor = hexStringToUIColor(hex: "#CC8A65")
            self.btnOkay.setTitleColor(.white, for: .normal)
        }
        UIApplication.topViewController()?.view.addSubview(parentView)
        //UIApplication.shared.keyWindow?.addSubview(parentView)
    }
}
