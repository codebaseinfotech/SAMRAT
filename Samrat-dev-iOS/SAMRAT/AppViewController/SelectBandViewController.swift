//
//  SelectBandViewController.swift
//  SAMRAT
//
//  Created by Ankit Gabani on 31/03/23.
//

import UIKit
import MarqueeLabel

class SelectBandViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var viewWA: UIView!
    
    var arrBand: [SMBandsBand] = [SMBandsBand]()
    
    var selecetdIndex = -1
    
    var objSelectedID = 0
    
    var isFromCustom = false
    var isFromMultiple = false
    var getSelectedMusician:[musiciansDetails] = [] {
        didSet {
            musicianSet = Set.init(self.getSelectedMusician.map({$0.musician_category_id ?? 0}))
        }
    }
    
    var isSingerServicesWithHour = false
   
    var selectedSinger:singersData? = nil
    var geSelectedDate:Date? = nil
    var selectedSingers:[singersData] = []
    var selectedService:[serviceDetails] = []
    var settingsResponse:SettingResponse? = nil
    var serviceResponse:ServiceResponse? = nil
    var selectedServicesData:[servicesData] = []
    
    var singer_ServicesWithHour:[singer_Services] = []
    
    var categoriesDetails: CategoriesData? = nil
    var parentCatObj:CategoriesData? = nil
    var singer_services = [String:String]()
    
    var musicianSet: Set<Int> = []
    
    var isErrorShowing = false
    
    var dicCreateBookingObj = createBookingObj()
    
    var dicCreateBookingObjOld = createBookingObjOld()
    var booking_transaction_message = ""
    
    var isSelectedDefault = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)

        
        self.lblTitle.text = Localized("Choose sound system")
        
        btnNext.setTitle(Localized("next").uppercased(), for: .normal)
        
        tblView.delegate = self
        tblView.dataSource = self
        
        self.title = Localized("Sound System").uppercased()
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
        callGetSingerList()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func clickedWA(_ sender: Any) {
        print("Button Tapped")
        
        if let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=\(CategoriesModel.shared.settingResponse?.settings?.whatsapp_number ?? "")&text=") {
            
            if UIApplication.shared.canOpenURL(whatsappURL) {
                UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        // Get the translation (movement) of the drag
        let translation = gesture.translation(in: view)
        
        // Update the center of the view by adding the translation
        var newCenter = CGPoint(x: viewWA.center.x + translation.x, y: viewWA.center.y + translation.y)
        
        // Get the safe area insets (top, bottom, left, right)
        let safeAreaInsets = view.safeAreaInsets
        
        // Define boundaries within the safe area
        let minX = safeAreaInsets.left + viewWA.frame.width / 2
        let maxX = view.bounds.width - safeAreaInsets.right - viewWA.frame.width / 2
        let minY = safeAreaInsets.top + viewWA.frame.height / 2
        let maxY = view.bounds.height - safeAreaInsets.bottom - viewWA.frame.height / 2
        
        // Ensure the new center stays within the boundaries of the safe area
        newCenter.x = max(minX, min(newCenter.x, maxX))
        newCenter.y = max(minY, min(newCenter.y, maxY))
        
        // Set the new center for the movable view
        viewWA.center = newCenter
        
        // Reset the translation to 0 after applying the change
        gesture.setTranslation(.zero, in: view)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @objc func menuClick(_ sender:UIButton) {
        self.view.endEditing(true)
        fadeFrom()
    }
   
    @IBAction func clickedNext(_ sender: Any) {
        
        if selecetdIndex == -1
        {
            self.showAlert(title: Localized("alert"), message: Localized("Choose sound system"))
        }
        else
        {
            if self.isSelectedDefault == true {
                
                let onlilePaymentVc = OnlinePaymentVC()
                onlilePaymentVc.isFromCustom = false
                onlilePaymentVc.selectedSinger = self.selectedSinger
                onlilePaymentVc.isFromMultiple = self.isFromMultiple
                onlilePaymentVc.selectedSingers = self.selectedSingers
                onlilePaymentVc.geSelectedDate = self.geSelectedDate
                onlilePaymentVc.categoriesDetails = self.categoriesDetails
                onlilePaymentVc.getSelectedMusician = self.getSelectedMusician
                onlilePaymentVc.parentCatObj = self.parentCatObj
                onlilePaymentVc.str_band_price_id = "\(self.objSelectedID)"
                onlilePaymentVc.dicSelectedBand = arrBand[self.selecetdIndex]
                onlilePaymentVc.musicianSet = self.musicianSet
                onlilePaymentVc.singer_ServicesWithHour = self.singer_ServicesWithHour
                onlilePaymentVc.selectedServicesData = self.selectedServicesData
                self.fadeTo(onlilePaymentVc)
            } else {
                
                let onlinePaymentVc = OnlinePaymentVC()
                onlinePaymentVc.isFromCustom = true
                onlinePaymentVc.isFromMultiple = self.isFromMultiple
                onlinePaymentVc.geSelectedDate = self.geSelectedDate
                onlinePaymentVc.selectedSinger = self.selectedSinger
                onlinePaymentVc.selectedSingers = self.selectedSingers
                onlinePaymentVc.getSelectedMusician = self.getSelectedMusician
                onlinePaymentVc.categoriesDetails = self.categoriesDetails
                onlinePaymentVc.parentCatObj = self.parentCatObj
                onlinePaymentVc.str_band_price_id = "\(self.objSelectedID)"
                onlinePaymentVc.dicSelectedBand = arrBand[self.selecetdIndex]
                onlinePaymentVc.musicianSet = self.musicianSet
                onlinePaymentVc.selectedServicesData = self.selectedServicesData
                onlinePaymentVc.singer_ServicesWithHour = self.singer_ServicesWithHour
                self.fadeTo(onlinePaymentVc)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrBand.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "BandListTableCell") as! BandListTableCell
        
        let dicData = arrBand[indexPath.row]
        
        cell.lblName.text = dicData.title ?? ""
        
        cell.lblName.type = .continuous
        cell.lblName.trailingBuffer = 18
        cell.lblName.setNeedsLayout()
        
        if indexPath.row == 0
        {
            cell.imgBrand.image = UIImage(named: "ic_alrandi")
        }
        else
        {
            cell.imgBrand.image = UIImage(named: "SAMRAT_LOGO")
        }
        
        if selecetdIndex == indexPath.row
        {
            cell.imgSelecte.image = UIImage(named: "select")
            cell.lblName.type = .continuous
            cell.lblName.trailingBuffer = 18
            cell.lblName.setNeedsLayout()

        }
        else
        {
            cell.imgSelecte.image = UIImage(named: "unselect")
            cell.lblName.type = .continuous
            cell.lblName.trailingBuffer = 18
            cell.lblName.setNeedsLayout()

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let dicData = arrBand[indexPath.row]
        objSelectedID = dicData.id
        selecetdIndex = indexPath.row
        tblView.reloadData()
    }
    
    func callGetSingerList()
    {
        APIClient.sharedInstance.showIndicator()
        
        let param = ["":""]
        
        APIClient.sharedInstance.MakeAPICallWithAuthHeaderPost(ApiUrl.GET_BOOOKING_BANDS, parameters: param) { response, error, statusCode in
            
            print("STATUS CODE \(String(describing: statusCode))")
            print("RESPONSE \(String(describing: response))")
            
            if error == nil
            {
                APIClient.sharedInstance.hideIndicator()
                
                let status =  response?.value(forKey: "status") as? Int
                let message =  response?.value(forKey: "message") as? String
                
                if status == 1
                {
                    if let objResponse = response
                    {
                        let arrData =  objResponse.value(forKey: "bands") as? NSArray
                        
                        self.arrBand.removeAll()
                        
                        if (arrData?.count ?? 0) > 0
                        {
                            for objSinger in arrData!
                            {
                                let dicSingerData = SMBandsBand(fromDictionary: objSinger as! NSDictionary)
                                self.arrBand.append(dicSingerData)
                            }
                        }
                        
                        self.tblView.reloadData()
                    }
                    
                }
                else
                {
                    self.arrBand.removeAll()
                    self.tblView.reloadData()
                    
                    self.view.makeToast(message)
                }
                
            }
            else
            {
                APIClient.sharedInstance.hideIndicator()
                let message =  response?.value(forKey: "message") as? String
                self.view.makeToast(message)
            }
            
            
        }
    }
}

class BandListTableCell: UITableViewCell {
    
    @IBOutlet weak var imgBrand: UIImageView!
    @IBOutlet weak var imgSelecte: UIImageView!
    @IBOutlet weak var lblName: MarqueeLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
