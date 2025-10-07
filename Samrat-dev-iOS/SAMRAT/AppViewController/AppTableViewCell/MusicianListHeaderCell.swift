//
//  MusicianListHeaderCell.swift
//  SAMRAT
//
//  Created by Mohsin Baloch on 17/06/21.
//

import UIKit

class MusicianListHeaderCell: UITableViewHeaderFooterView {
    @IBOutlet weak var alrandiMainContainView: UIView!
    @IBOutlet weak var backViewTopConstrain: NSLayoutConstraint!
    @IBOutlet weak var backViewHeightConstrain: NSLayoutConstraint!
    @IBOutlet weak var alrandiImageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblChoose: UILabel!
    @IBOutlet weak var lblDefaultSelected: UILabel!
    @IBOutlet var backView : UIView!
    @IBOutlet var segmentOutlet: UISegmentedControl!
    @IBOutlet var segmentControl : HBSegmentedControl!
}
