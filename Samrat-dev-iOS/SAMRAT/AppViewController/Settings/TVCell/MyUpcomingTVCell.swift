//
//  MyUpcomingTVCell.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 06/05/21.
//

import UIKit

class MyUpcomingTVCell: UITableViewCell {

    @IBOutlet var lblDays: UILabel!
    @IBOutlet var lblMonthYear: UILabel!
    @IBOutlet var detailsContainView: UIView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var btnViewMore: UIButton!
    var booking: Bookings!
    var vc: MyBookingVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.detailsContainView.buttonShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func viewMorePressed(sender: UIButton) {
        vc.reloadCell(tag: tag)
    }
    
    func setData(booking: Bookings, vc: MyBookingVC) {
        self.booking = booking
        self.vc = vc
        lblDays.text = self.convertDateFormater(booking.booking_date ?? "", oriDateFormate: "yyyy-MM-dd", requiredDateFormate: "dd")
        if Language.shared.isArabic {
            lblMonthYear.text = self.convertDateFormater(booking.booking_date ?? "", oriDateFormate: "yyyy-MM-dd", requiredDateFormate: "yyyy MMMM")
        } else {
            lblMonthYear.text = self.convertDateFormater(booking.booking_date ?? "", oriDateFormate: "yyyy-MM-dd", requiredDateFormate: "MMMM yyyy")
        }
        stackView.spacing = 10
        stackView.distribution = .fill
        btnViewMore.setTitle( vc.currentIndex == tag ? Localized("View Less") : Localized("View More"), for: .normal)
        btnViewMore.layer.cornerRadius = btnViewMore.frame.height / 2
        btnViewMore.isHidden = booking.singers?.count == 1 || booking.singers?.isEmpty ?? true
        setViews()
    }
    
    func setViews() {
        stackView.subviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        if vc.currentIndex == tag {
            booking.singers?.forEach({ singer in
                let viw = getView(name: singer.name, cat: singer.category_name, desc: singer.description, img: singer.image)
                stackView.addArrangedSubview(viw)
//                viw.translatesAutoresizingMaskIntoConstraints = false
//                viw.leftAnchor.constraint(equalTo: stackView.leftAnchor).isActive = true
//                viw.rightAnchor.constraint(equalTo: stackView.rightAnchor).isActive = true
            })
        } else if !(booking.singers?.isEmpty ?? false) {
            let viw = getView(name: booking.singers?.first?.name, cat: booking.singers?.first?.category_name, desc: booking.singers?.first?.description, img: booking.singers?.first?.image)
            stackView.addArrangedSubview(viw)
//            viw.translatesAutoresizingMaskIntoConstraints = false
//            viw.leftAnchor.constraint(equalTo: stackView.leftAnchor).isActive = true
//            viw.rightAnchor.constraint(equalTo: stackView.rightAnchor).isActive = true
        }
    }
    
    func getView(name: String?, cat: String?, desc: String?, img: String?) -> UIStackView {
        let stackViewLabels = UIStackView()
        stackViewLabels.axis = .vertical
        stackViewLabels.spacing = 3
        stackViewLabels.distribution = .fill
        
        let lbl = UILabel()
        lbl.textColor = hexStringToUIColor(hex: "#CC8A65")
        lbl.text = name
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        
        let lbl2 = UILabel()
        lbl2.textColor = .white
        lbl2.text = cat
        lbl2.font = UIFont.systemFont(ofSize: 12)
        
        let lbl3 = UILabel()
        lbl3.textColor = .white
        lbl3.text = desc
        lbl3.numberOfLines = 3
        lbl3.font = UIFont.systemFont(ofSize: 12)
        
        stackViewLabels.addArrangedSubview(lbl)
        stackViewLabels.addArrangedSubview(lbl2)
        stackViewLabels.addArrangedSubview(lbl3)
        
        let stackViewH = UIStackView()
        stackViewH.axis = .horizontal
//        stackViewH.spacing = 10
//        stackViewH.distribution = .fill
        
        let imgView = UIImageView()
        imgView.downloadImage(str: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imgView.heightAnchor.constraint(equalTo: imgView.widthAnchor).isActive = true
        imgView.layer.cornerRadius = 10
        imgView.clipsToBounds = true
        
        stackViewH.addArrangedSubview(stackViewLabels)
        stackViewH.addArrangedSubview(imgView)
        
        return stackViewH
    }
}
