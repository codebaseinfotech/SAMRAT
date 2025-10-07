import UIKit

class MusiciansTableViewCell: UITableViewCell {

    @IBOutlet weak var viewBase: UIView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var imageViewProduct: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDecription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewBase.layer.cornerRadius = 20.0
        viewBase.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
