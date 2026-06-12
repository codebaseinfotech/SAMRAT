//
//  OnlinePaymentVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 28/04/21.
//

import UIKit
import goSellSDK

class OnlinePaymentVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AlertViewDelegate {
    func okayButtonTapped() {
        
        if isErrorShowing == false
        {
            startKNetPayment()
        }
        else
        {
            isErrorShowing = false
        }
        
    }
    
    func cancleButtonTapped() {
        
    }
    
    @IBOutlet weak var imgLogo7: UIImageView!
    
    @IBOutlet weak var bookServicesLine: UIImageView!
    @IBOutlet weak var musiciansLine: UIImageView!
    
    @IBOutlet weak var viewSoundSystem: UIView!
    
    @IBOutlet weak var viewServices: UIView!
    
    @IBOutlet weak var imgBackground: UIImageView!
    
    @IBOutlet weak var lblSingerServices: UILabel!
    @IBOutlet weak var servicesTableView:  UITableView!{
        didSet {
            servicesTableView.register(UINib.init(nibName: "onlinePaymentMusiciansCell", bundle: nil), forCellReuseIdentifier: "onlinePaymentMusiciansCell")
        }
    }
    @IBOutlet weak var servicesView: UIView!
    var booking_price:String? = ""
    
    @IBOutlet weak var lblSoundSystemTitle: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var knetContainView: UIControl!
    
    @IBOutlet var paymentContainView: UIView!
    @IBOutlet var creditCardContainVire: UIControl!
    @IBOutlet var codContainView: UIControl!
    @IBOutlet var lblBookingAmount: UILabel!
    @IBOutlet var lblTotalAmount: UILabel!
    @IBOutlet weak var tblServices: UITableView!{
        didSet {
            tblServices.register(UINib.init(nibName: "ServicesCell", bundle: nil), forCellReuseIdentifier: "ServicesCell")
        }
    }
    @IBOutlet weak var tableviewSingers: UITableView! {
        didSet {
            tableviewSingers.register(UINib.init(nibName: "onlinePaymentMusiciansCell", bundle: nil), forCellReuseIdentifier: "onlinePaymentMusiciansCell")
        }
    }
    @IBOutlet var tableView: UITableView!{
        didSet {
            tableView.register(UINib.init(nibName: "onlinePaymentMusiciansCell", bundle: nil), forCellReuseIdentifier: "onlinePaymentMusiciansCell")
        }
    }
    @IBOutlet weak var soundSystemTableView: UITableView!{
        didSet {
            soundSystemTableView.register(UINib.init(nibName: "onlinePaymentMusiciansCell", bundle: nil), forCellReuseIdentifier: "onlinePaymentMusiciansCell")
        }
    }
    //    @IBOutlet var tableViewheightConstrain: NSLayoutConstraint!
    @IBOutlet var imgCashonDeliveryStatus: UIImageView!
    
    @IBOutlet var imCreditCardStatus: UIImageView!
    @IBOutlet var imgKnetStatus: UIImageView!
    @IBOutlet weak var SingersContainerView: UIView!
    @IBOutlet var musiciansContainView: UIView!
    
    @IBOutlet var lblBookingDetails: UILabel!
    
    @IBOutlet var lbldateTitle: UILabel!
    @IBOutlet var lblPaymentSummry: UILabel!
    
    @IBOutlet var lblSingerTitle: UILabel!
    @IBOutlet var lblTotalTitle: UILabel!
    @IBOutlet var lblBookingTitle: UILabel!
    @IBOutlet var lblBookingMessage: UILabel!
    @IBOutlet weak var lblOptionalExtraServices: UILabel!
    @IBOutlet var lblPaymentOptionTitle: UILabel!
    @IBOutlet var lblCashOnDelivery: UILabel!
    @IBOutlet var lblKnet: UILabel!
    @IBOutlet var lblCradit: UILabel!
    @IBOutlet var btnPay: UIButton!
    @IBOutlet var lblMusicianTitle: UILabel!
    
    @IBOutlet var stkvSingers: UIStackView!
    @IBOutlet var viewCancel: UIView!
    @IBOutlet var lblCancel: UILabel!
    @IBOutlet var lblTryAgain: UILabel!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewWA: UIView!
    
    
    
    var dicSelectedBand = SMBandsBand()
    
    var isFromCustom = false
    var isFromMultiple = false
    var getSelectedMusician:[musiciansDetails] = [] {
        didSet {
            musicianSet = Set.init(self.getSelectedMusician.map({$0.musician_category_id ?? 0}))
        }
    }
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
    
    var alradyServices = false
    
    var str_band_price_id = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (getSelectedMusician.count ?? 0) == 0
        {
            if (selectedSinger?.musicians?.count ?? 0) > 0
            {
                musicianSet = Set.init((self.selectedSinger?.musicians?.map({$0.musician_category_id ?? 0}))!)
            }
        }
        
        // Initailly hidden and only visible for samrat and wedding category
        self.viewSoundSystem.isHidden = true
        self.bookServicesLine.isHidden = true
        self.musiciansLine.isHidden = true
        
        if parentCatObj?.id == 1 {
            self.viewSoundSystem.isHidden = false
            self.bookServicesLine.isHidden = false
           // self.musiciansLine.isHidden = false
        } else if parentCatObj?.id == 21 {
            self.imgBackground.image = UIImage(named: "wedding_confirmation_page_bg")
            self.viewSoundSystem.isHidden = false
            self.bookServicesLine.isHidden = false
           // self.musiciansLine.isHidden = false
        } else if self.parentCatObj?.id == 23{
            self.imgBackground.image = UIImage(named: "band_confirmation_page_bg")
            
            if self.categoriesDetails?.id == 27 {
                self.imgBackground.image = UIImage(named: "band_tradional_booking_details")
            }
            if self.categoriesDetails?.id == 29 {
                self.imgBackground.image = UIImage(named: "SUB_WESTERN_BAND")
            }
            
            if self.categoriesDetails?.id == 24 {
                self.imgBackground.image = UIImage(named: "band_arabic_takh_booking")
            }
        } else
        {
            
        }
        
        
        let selectedCountry = getSelectedCountry()
        
        if selectedCountry?.country_en == "Saudi arabia"{
            // prev it was in viewdidload, Now keys dynamic
            //let secretKey = SecretKey(sandbox: "sk_test_JZu1kBnWwMGtyqROYc9DQbFe", production: "sk_live_3Q9E1mPr8tb0y6MjzuHXvDGN")
            let secretKey = SecretKey(sandbox: CategoriesModel.shared.settingResponse?.settings?.tap_secret_test_ios_ksa ?? "", production: CategoriesModel.shared.settingResponse?.settings?.tap_secret_live_ios_ksa ?? "")
            GoSellSDK.secretKey = secretKey
           // GoSellSDK.mode = .sandbox
            GoSellSDK.mode = .production
        } else{
            // prev it was in viewdidload, Now keys dynamic
            //let secretKey = SecretKey(sandbox: "sk_test_JZu1kBnWwMGtyqROYc9DQbFe", production: "sk_live_3Q9E1mPr8tb0y6MjzuHXvDGN")
            let secretKey = SecretKey(sandbox: CategoriesModel.shared.settingResponse?.settings?.tap_secret_test_ios_kwt ?? "", production: CategoriesModel.shared.settingResponse?.settings?.tap_secret_live_ios_kwt ?? "")
            GoSellSDK.secretKey = secretKey
           // GoSellSDK.mode = .sandbox
            GoSellSDK.mode = .production
        }

        
        
        print("Booking details:- ", self.categoriesDetails?.id)
        
        self.apiGetSettingDetails()
        self.apiGetServices()
        
        self.title = Localized("onlinePayment").uppercased() //"ONLINE PAYMENT"
        self.lblBookingTitle.text = Localized("bookingDetails")
        self.lblSingerTitle.text = !isFromMultiple || self.selectedSingers.count == 1 ? Localized("singerName") : Localized("singersName")
        self.lblMusicianTitle.text = Localized("musicians")
        self.lbldateTitle.text = Localized("date")
        
        self.lblPaymentOptionTitle.text = Localized("paymentOptions")
        self.lblTotalTitle.text = Localized("total")
        self.lblBookingTitle.text = Localized("bookingAmount")
        self.lblPaymentOptionTitle.text = Localized("bookingAmount")
        self.lblCashOnDelivery.text = Localized("cashOndelivery")
        self.lblKnet.text = Localized("knet")
        self.lblCradit.text = Localized("creditCard")
        
        lblPaymentSummry.text = Localized("total")
        lblOptionalExtraServices.text = Localized("Extra services")
        lblBookingDetails.text = Localized("bookingDetails")
        
        self.lblSoundSystemTitle.text = Localized("sound_system")
        self.btnPay.setTitle(Localized("pay"), for: .normal)
        lblBookingTitle.isHidden = true
        
        if self.selectedServicesData.count == 1{
            self.lblSingerServices.text = Localized("booked_Service")
        } else {
            self.lblSingerServices.text = Localized("booked_Services")
        }
       

        btnPay.layer.cornerRadius = btnPay.frame.height / 2
        
//        let button = PayButton(frame: CGRect(x: 100, y: 300, width: 100, height: 100))
//        button.backgroundColor = .red
//        self.view.addSubview(button) // or where you want it
//        btnPay.updateDisplayedState()
//        btnPay.delegate = self // or whatever
        
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.servicesTableView.delegate = self
        self.servicesTableView.dataSource = self
        self.tableviewSingers.delegate = self
        self.tableviewSingers.dataSource = self
        self.soundSystemTableView.delegate = self
        self.soundSystemTableView.dataSource = self
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableviewSingers.reloadData()
            self.servicesTableView.reloadData()
        }
        self.updateBasicDetails()
        self.imgKnetStatus.isHighlighted = true
        
        lblCancel.text = Localized("Cancelled")
        lblTryAgain.text = Localized("PlTryAg")
        
        viewCancel.isHidden = true
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
                viewWA.clipsToBounds = true
                
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                viewWA.addGestureRecognizer(panGesture)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func menuClick(_ sender:UIButton) {
        self.view.endEditing(true)
        fadeFrom()
    }
    
    @IBAction func btnpayAction(_ sender: UIButton) {
        showTermsAlert()
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
    
    func startKNetPayment() {
        
        callBookingCreate()
        
        
    }
    
    func updateBasicDetails() {
        //self.lblSingerName.text = self.selectedSinger?.name
        self.SingersContainerView.isHidden = false
        if self.isFromCustom == true {
            if (self.getSelectedMusician.count) <= 0 {
                self.musiciansContainView.isHidden = true
            }
        } else {
            if (self.selectedSinger?.musicians?.count ?? 0) <= 0 {
                self.musiciansContainView.isHidden = true
            }
        }
        
        if self.selectedServicesData.count > 0 {
            self.servicesView.isHidden = false
            self.musiciansContainView.isHidden = true
        } else {
            self.servicesView.isHidden = true
            self.musiciansContainView.isHidden = false
        }
        
        
        self.lblTotalAmount.text = (self.selectedSinger?.price ?? "") + " " + SelectedCurrency.shared.currentAppCurrency
//        self.lblTotalAmount.text = (self.selectedSinger?.single_price ?? "") + " " + "KD"
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "dd/MM/yyyy"
        self.lblDate.text = engToArb(str: formatter3.string(from: self.geSelectedDate ?? Date()))
    }
    
    
    
    func apiGetServices() {
        
        var strIds: String = ""
        if isFromMultiple {
            var strArray : [String] = []
            for i in self.selectedSingers {
                strArray.append("\(i.id ?? 0)")
            }
            strIds = strArray.joined(separator: ",")
        }
        else {
            strIds = ("\(self.selectedSinger?.id ?? 0)")
        }
        
        let selectedCountry = getSelectedCountry()
        let parameter = [
            "singer_ids": "\(strIds)",
            "country_id": selectedCountry?.id ?? 0
        ] as [String: Any]
                
            APIManager.handler.PostRequest(url: ApiUrl.BookingServices, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            switch result {
            case .success(let data):
                do {
                    if let getDara = data {
                        self.serviceResponse = try JSONDecoder().decode(ServiceResponse.self, from: getDara)
                        
                        let responseDict = try JSONSerialization.jsonObject(with: (getDara as NSData) as Data, options: .allowFragments) as AnyObject
                        print ("responseDict====\(responseDict)")
                        
                        if self.serviceResponse?.status == true {
                            if self.serviceResponse?.booking_service != nil {
                                if (self.serviceResponse?.booking_service?.count)! > 0 {
                                    self.tblServices.delegate = self
                                    self.tblServices.dataSource = self
                                    self.tblServices.reloadData()
                                    self.paymentSummary()
                                    self.viewServices.isHidden = false
                                    
                                } else{
                                    self.paymentSummary()
                                    self.viewServices.isHidden = true
                               }
                            }
                            
                        }else {
                            self.tblServices.delegate = self
                            self.tblServices.dataSource = self
                            self.tblServices.reloadData()
                            self.paymentSummary()
                            self.viewServices.isHidden = true
//                            self.showAlert(title: Localized("alert"), message: self.settingsResponse?.message ?? Localized("somethingWentWrong")) {
//
//                            }
                            //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
                        }
                    }
                } catch (let error) {
                    JSN.log("login uer ====>%@", error)
                }
                break
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                break
            }
        }
    }
    
    //MARK:- TableView delegate and datasource
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //        self.tableViewheightConstrain.constant = self.tableView.contentSize.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableviewSingers {
            return self.selectedSingers.count > 0 ? self.selectedSingers.count : 1
        } else if tableView == self.tblServices {
            return self.serviceResponse?.booking_service?.count ?? 0
        } else if tableView == self.servicesTableView {
            return self.selectedServicesData.count
        } else if tableView == self.soundSystemTableView {
            return 1
        }else {
            if self.isFromCustom == true {
                return musicianSet.count
            } else {
                return 1//(self.selectedSinger?.musicians?.count ?? 0)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "onlinePaymentMusiciansCell", for: indexPath) as! onlinePaymentMusiciansCell
        if tableView == self.tableviewSingers {
            cell.lblDescriptioon.isHidden = true
            if !isFromMultiple {
                let singer = self.selectedSinger
                cell.lblName.text = singer?.name
                //cell.lblDescriptioon.text = ""
            } else {
                let singer = self.selectedSingers[indexPath.row]
                cell.lblName.text = singer.name
                //cell.lblDescriptioon.text = ""
            }
        } else if tableView == self.servicesTableView {
            cell.lblDescriptioon.isHidden = true
            let singer = self.selectedServicesData[indexPath.row]
            cell.lblName.text = singer.title
            
        } else if tableView == self.tblServices {
            let cell = self.tblServices.dequeueReusableCell(withIdentifier: "ServicesCell", for: indexPath) as! ServicesCell
            let singer = self.serviceResponse?.booking_service?[indexPath.row]
            cell.lblServiceName.text = "\(singer?.title ?? "")"
            cell.lblNewDetail.text = singer?.description ?? ""
            cell.lblPriceTag.text = String(describing: (singer?.price)!)  + " \(SelectedCurrency.shared.currentAppCurrency)"
            let filterdSection = self.selectedService.filter({$0.id == singer?.id ?? 0})
            if filterdSection.count > 0 {
                cell.imgSelection.isHighlighted = (filterdSection.contains(where: {$0.id == singer?.id}))
            } else {
                cell.imgSelection.isHighlighted = false
            }
            return cell
        }else if tableView == self.soundSystemTableView {
            
            if alradyServices == true
            {

                if categoriesDetails?.id == 1
                {
                    cell.lblName.text = ""
                    self.imgLogo7.isHidden = true
                    self.imgLogo7.image = nil
                    self.lblSoundSystemTitle.isHidden = true
                    self.viewSoundSystem.isHidden = true
                    
                    self.musiciansLine.isHidden = true
                    self.bookServicesLine.isHidden = true

                }
                else
                {
                    if getSelectedCountry()?.country == "Kuwait" || getSelectedCountry()?.country == "Kuwait ar"
                    {

                        self.musiciansLine.isHidden = false
                        
                        if str_band_price_id == ""
                        {
                            
                            if dicSelectedBand.id == 2
                            {
                                cell.lblName.text = Localized("chooseDefault")
                                self.imgLogo7.image = UIImage(named: "SAMRAT_LOGO")
                            }
                            else
                            {
                                cell.lblName.text = Localized("alrandy_art_production")
                                self.imgLogo7.image = UIImage(named: "ic_alrandi")

                            }
                        }
                        else
                        {
                            if dicSelectedBand.id == 1
                            {
                                cell.lblName.text = Localized("alrandy_art_production")
                                self.imgLogo7.image = UIImage(named: "ic_alrandi")
                            }
                            else
                            {
                                cell.lblName.text = Localized("chooseDefault")
                                self.imgLogo7.image = UIImage(named: "SAMRAT_LOGO")
                            }
                            
                        }
                    }
                    else
                    {
                        cell.lblName.text = ""
                        self.imgLogo7.isHidden = true
                        self.imgLogo7.image = nil
                        self.lblSoundSystemTitle.isHidden = true
                        self.viewSoundSystem.isHidden = true
                        
                        self.musiciansLine.isHidden = true
                    }
                }
                
            }
            else
            {
                if getSelectedCountry()?.country == "Kuwait" || getSelectedCountry()?.country == "Kuwait ar"
                {

                    self.musiciansLine.isHidden = false
                    
                    if str_band_price_id == ""
                    {
                        
                        if dicSelectedBand.id == 2
                        {
                            cell.lblName.text = Localized("chooseDefault")
                            self.imgLogo7.image = UIImage(named: "SAMRAT_LOGO")
                        }
                        else
                        {
                            cell.lblName.text = Localized("alrandy_art_production")
                            self.imgLogo7.image = UIImage(named: "ic_alrandi")

                        }
                    }
                    else
                    {
                        if dicSelectedBand.id == 1
                        {
                            cell.lblName.text = Localized("alrandy_art_production")
                            self.imgLogo7.image = UIImage(named: "ic_alrandi")
                        }
                        else
                        {
                            cell.lblName.text = Localized("chooseDefault")
                            self.imgLogo7.image = UIImage(named: "SAMRAT_LOGO")
                        }
                        
                    }
                }
                else
                {
                    cell.lblName.text = ""
                    self.imgLogo7.isHidden = true
                    self.imgLogo7.image = nil
                    self.lblSoundSystemTitle.isHidden = true
                    self.viewSoundSystem.isHidden = true
                    
                    self.musiciansLine.isHidden = true
                }
            }

            
        }else {
            if self.isFromCustom == true {
                let catId = musicianSet[musicianSet.index(musicianSet.startIndex, offsetBy: indexPath.row)]
                print("cell set \(musicianSet)")
                print("catId \(catId)")
                
                let musicians = self.getSelectedMusician.filter({ $0.musician_category_id == catId })
                
                if (getSelectedMusician.count ?? 0) == 0
                {
                    if (selectedSinger?.musicians?.count ?? 0) > 0
                    {
                        musicianSet = Set.init((self.selectedSinger?.musicians?.map({$0.musician_category_id ?? 0}))!)
                        
                        let musicians77 = self.selectedSinger?.musicians?.filter({ $0.musician_category_id == catId })
                        
                        cell.lblName.text = (musicians77?.first?.category_name ?? musicians77?.first?.category_name_ar ?? "") + " - "
                        
                        cell.lblDescriptioon.text = musicians77.map({ $0.first?.name ?? ""})
                        cell.lblDescriptioon.isHidden = false

                    }
                    else
                    {
                        cell.lblName.text = selectedSinger?.id == 25 ? Localized("Yousef AlOmani") : Localized("Default Musician")
                        
                        cell.lblDescriptioon.isHidden = true
                        cell.lblDescriptioon.text = ""
                    }
                }
                else
                {
                    if musicians.count == 0
                    {
                        cell.lblName.text = selectedSinger?.id == 25 ? Localized("Yousef AlOmani") : Localized("Default Musician")

                        cell.lblDescriptioon.isHidden = true
                        cell.lblDescriptioon.text = ""
                    }
                    else
                    {
                        cell.lblName.text = (musicians.first?.category_name ?? musicians.first?.category_name_ar ?? "") + " - "
                        cell.lblDescriptioon.text = musicians.map({ $0.name ?? ""}).joined(separator: "\n")
                        cell.lblDescriptioon.isHidden = false
                    }
                }
                
               
                print("mapssss \(cell.lblDescriptioon.text ?? "")")
                //cell.lblDescriptioon.text = ""//musicianDetails.name ?? ""
            } else {
                //let musicianDetails = self.selectedSinger?.musicians?[indexPath.row]
                
                if categoriesDetails?.id == 1
                {
                    
                    cell.lblName.text = Localized("SAMRAT Musician")
                }
                else
                {
                    
                    cell.lblName.text = selectedSinger?.id == 25 ? Localized("Yousef AlOmani") : Localized("Default Musician")//Localized("Default Musician")//(Language.shared.isArabic ? (musicianDetails?.category_name_ar ?? "") : (musicianDetails?.category_name ?? "")) + " - " + (musicianDetails?.name)!
                }
               
                //cell.lblName.text = musicianDetails?.category_name ?? ""
                //cell.lblDescriptioon.text = musicianDetails?.name ?? ""
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "ServicesCell", for: indexPath)
        if tableView == tblServices {
            let service = self.serviceResponse?.booking_service?[indexPath.row]
            let filterSelection = self.selectedService.filter({$0.id == service?.id})
            if filterSelection.count > 0 {
                if filterSelection.contains(where: {$0.id == service?.id}) {
                    self.selectedService.removeAll(where: {$0.id == service?.id})
                } else {
                    if let getMusician = service {
                        self.selectedService.removeAll(where: {$0.id == service?.id})
                        self.selectedService.append(getMusician)
                    }
                }
            } else {
                if let getMusician = service {
                    self.selectedService.removeAll(where: {$0.id == service?.id})
                    self.selectedService.append(getMusician)
                }
            }
            self.paymentSummary()
            self.tblServices.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    @IBAction func onTapCashOnDelivery(_ sender: UIControl) {
        self.paymentSelectedStatus()
        self.imgCashonDeliveryStatus.isHighlighted = true
    }
    
    @IBAction func onTapknetAction(_ sender: UIControl) {
        self.paymentSelectedStatus()
        self.imgKnetStatus.isHighlighted = true
        
    }
    
    @IBAction func creditCardAction(_ sender: UIControl) {
        self.paymentSelectedStatus()
        self.imCreditCardStatus.isHighlighted = true
        
    }
    
    func paymentSelectedStatus() {
        self.imgCashonDeliveryStatus.isHighlighted = false
        self.imgKnetStatus.isHighlighted = false
        self.imCreditCardStatus.isHighlighted = false
    }
    
    //MARK:- Payment Summary SERVICE COST
    func paymentSummary() {
        var musicianIds = ""
        if self.isFromCustom == true {
            musicianIds = self.getSelectedMusician.map({"\($0.id ?? 0)"}).joined(separator: ",")
            
            if (getSelectedMusician.count ?? 0) == 0
            {
                if (selectedSinger?.musicians?.count ?? 0) > 0
                {
                    musicianIds = (self.selectedSinger?.musicians?.map({"\($0.id ?? 0)"}) ?? []).joined(separator: ",")
                    
                    musicianSet = Set.init((self.selectedSinger?.musicians?.map({$0.musician_category_id ?? 0}))!)
                }
            }
            
        } else {
          //  musicianIds = (self.selectedSinger?.musicians?.map({"\($0.id ?? 0)"}) ?? []).joined(separator: ",")
            
            if isFromMultiple {
                var strArray : [String] = []
                for i in self.selectedSingers {
                    strArray.append("\(i.id ?? 0)")
                }
                musicianIds = strArray.joined(separator: ",")
            }
            else {
                musicianIds = ("\(self.selectedSinger?.id ?? 0)")
            }
            
        }
        
        var serviceIds = ""
        var strserviceArray : [String] = []
        
        for i in self.selectedService {
            strserviceArray.append("\(i.id ?? 0)")
        }
        serviceIds = strserviceArray.joined(separator: ",")
        
        print(musicianIds)
        
        var strIds: String = ""
        if isFromMultiple {
            var strArray : [String] = []
            for i in self.selectedSingers {
                strArray.append("\(i.id ?? 0)")
            }
            strIds = strArray.joined(separator: ",")
        }
        else {
            strIds = ("\(self.selectedSinger?.id ?? 0)")
        }
        
        var singerServices: [[String:String]] = []

        if self.singer_ServicesWithHour.count > 0{

                for service in self.singer_ServicesWithHour {
                    var singerServices1: [String:String] = [:]
                    singerServices1 = ["service_id": "\(service.service_id ?? "")", "hrs": "\(service.hrs ?? "")"]
                    singerServices.append(singerServices1)
                }

//            do {
//                let result = try? JSONDecoder().decode([String:String].self, from: self.singer_ServicesWithHour)
//                print(result)
//            } catch {
//                print(error)
//            }

//            let myDict = self.singer_ServicesWithHour.reduce(into: [String: String]()) {
//                //$0[$1.service_id!] = $1.hrs
//                $0["service_id"] = $1.service_id
//                $0["hrs"] = $1.hrs
//
//            }

            let service_id = self.singer_ServicesWithHour[0].service_id!
            let hrs = self.singer_ServicesWithHour[0].hrs!

           // singerServices = [["service_id": service_id, "hrs": hrs]]

        }

        // Build singers array for v10 API
        var singersArray: [[String: Any]] = []

        if isFromMultiple {
            for singer in self.selectedSingers {
                var singerDict: [String: Any] = [:]
                singerDict["singer_id"] = "\(singer.id ?? 0)"
                singerDict["is_service"] = singer.is_service ?? 0

                // Find services that belong to this singer
                var thisSingerServices: [[String: String]] = []
                if singer.is_service == 1, let singerAvailableServices = singer.services {
                    // Get service IDs that belong to this singer
                    let singerServiceIds = singerAvailableServices.map { $0.id ?? 0 }

                    // First try singer_ServicesWithHour
                    if self.singer_ServicesWithHour.count > 0 {
                        for service in self.singer_ServicesWithHour {
                            if let serviceIdStr = service.service_id,
                               let serviceId = Int(serviceIdStr),
                               singerServiceIds.contains(serviceId) {
                                thisSingerServices.append([
                                    "service_id": serviceIdStr,
                                    "hrs": service.hrs ?? "00:00:00"
                                ])
                            }
                        }
                    }

                    // If still empty, check selectedServicesData
                    if thisSingerServices.count == 0 && self.selectedServicesData.count > 0 {
                        for service in self.selectedServicesData {
                            if let serviceId = service.id, singerServiceIds.contains(serviceId) {
                                thisSingerServices.append([
                                    "service_id": "\(serviceId)",
                                    "hrs": "00:00:00"
                                ])
                            }
                        }
                    }

                    // If still empty, use singer's first available service (default)
                    if thisSingerServices.count == 0 {
                        if let firstService = singerAvailableServices.first, let serviceId = firstService.id {
                            thisSingerServices.append([
                                "service_id": "\(serviceId)",
                                "hrs": "00:00:00"
                            ])
                        }
                    }
                }
                singerDict["singer_services"] = thisSingerServices
                singersArray.append(singerDict)
            }
        } else {
            // Single singer
            var singerDict: [String: Any] = [:]
            singerDict["singer_id"] = "\(self.selectedSinger?.id ?? 0)"
            singerDict["is_service"] = self.selectedSinger?.is_service ?? 0
            singerDict["singer_services"] = singerServices
            singersArray.append(singerDict)
        }

        var parameters:[String : Any] = [:]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString : String = engToArb(str: dateFormatter.string(from: self.geSelectedDate ?? Date()))
        
       
        if self.singer_ServicesWithHour.count > 0 {
            
            if str_band_price_id == ""
            {
                parameters = [
                    "singer_id": strIds,
                    "musician_ids":musicianIds,
                    "is_default_musicians": isFromCustom == false ? 1 : 0,
                    "device_type": deviceType,
                    "is_default_services": 0,
                    "booking_date": dateString,
                    "booking_type": self.selectedServicesData.count > 0 ? "2":"1",
                    "singer_services": self.singer_ServicesWithHour.count > 0 ? singerServices : NSNull(),
                    "service_ids":serviceIds == "" ? NSNull() : serviceIds as Any]  as [String : Any]
            }
            else
            {
                parameters = [
                    "band_price_id": str_band_price_id,
                    "singer_id": strIds,
                    "musician_ids":musicianIds,
                    "is_default_musicians": isFromCustom == false ? 1 : 0,
                    "device_type": deviceType,
                    "is_default_services": 0,
                    "booking_date": dateString,
                    "booking_type": self.selectedServicesData.count > 0 ? "2":"1",
                    "singer_services": self.singer_ServicesWithHour.count > 0 ? singerServices : NSNull(),
                    "service_ids":serviceIds == "" ? NSNull() : serviceIds as Any]  as [String : Any]
            }
            
           
            
        } else{
            
            if str_band_price_id == ""
            {
                parameters = [
                    "singer_id": strIds,
                    "musician_ids":musicianIds,
                    "is_default_musicians": isFromCustom == false ? 1 : 0,
                    "device_type": deviceType,
                    "is_default_services": 0,
                    "booking_date": dateString,
                    "booking_type": self.selectedServicesData.count > 0 ? "2":"1",
                    "service_ids":serviceIds == "" ? NSNull() : serviceIds as Any]  as [String : Any]
            }
            else
            {
                parameters = [
                    "band_price_id": str_band_price_id,
                    "singer_id": strIds,
                    "musician_ids":musicianIds,
                    "is_default_musicians": isFromCustom == false ? 1 : 0,
                    "device_type": deviceType,
                    "is_default_services": 0,
                    "booking_date": dateString,
                    "booking_type": self.selectedServicesData.count > 0 ? "2":"1",
                    "service_ids":serviceIds == "" ? NSNull() : serviceIds as Any]  as [String : Any]
            }
            
            
        }
        
        let selectedCountry = getSelectedCountry()
        if selectedCountry != nil {
            parameters["country_id"] = selectedCountry?.id
        }

        // Add singers array for v10 API
        parameters["singers"] = singersArray
        
        print("parameters \(parameters)")

        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.Paymentoption, params: parameters, isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let responseObject = data else {return}
                    let responseDict = try JSONSerialization.jsonObject(with: (responseObject as NSData) as Data, options: .allowFragments) as AnyObject
                    print ("responseDict====\(responseDict)")
                    if let resultDic : NSDictionary = responseDict as? NSDictionary {
                        if let amount = resultDic.object(forKey: "total_amount") as? String {
                            self.lblTotalAmount.text = amount + " " + SelectedCurrency.shared.currentAppCurrency
                        }
                    }
                    
                    if let resultDic1 : NSDictionary = responseDict as? NSDictionary {
                        if let minimum_booking = resultDic1.object(forKey: "minimum_booking") as? NSDictionary {
                            if let booking_price = minimum_booking.object(forKey: "booking_price") as? String {
                                self.booking_price = booking_price
                                self.lblBookingMessage.text = Localized("Booking amount mesage").replacingOccurrences(of: "200", with: "\(booking_price) \(SelectedCurrency.shared.currentAppCurrency)")
                            }
                            
                        }
                    }
                    
                    //                    let bookingResponse = try? JSONDecoder().decode(createBookingObj.self, from: data)
                    //
                    //                    if bookingResponse?.status == true {
                    //                        let paymentvc = PaymentSuccessVC()
                    //                        paymentvc.getResponseMsg = bookingResponse
                    //                        self.navigationController?.pushViewController(paymentvc, animated: true)
                    //                    }else {
                    ////                        self.showAlert(title: Localized("alert"), message: bookingResponse?.message ?? Localized("somethingWentWrong"))
                    //                        AlertView.instance.showAlert(title: Localized("alert"), message: NSAttributedString(string: bookingResponse?.message ?? Localized("somethingWentWrong")), alertType: .oneButton)
                                            //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
                    //                    }
                }
                catch (let error) {
                    JSN.log("login uer ====>%@", error)
                }
                break
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                break
            }
        }
    }
    
    //MARK:- Checkout API Calling
    
    func callBookingCreate() {
       
//        let parameter = [
//            "payment_amount": self.booking_price ?? 0,
//            "singer_booking_id": isFromMultiple ? "\(self.selectedSingers.map({ "\($0.id ?? 0)" }).joined(separator: ","))" : "\(self.selectedSinger?.id ?? 0)",
//        ]  as [String : Any]
           
        var musicianIds = ""
        if self.isFromCustom == true
        {
            musicianIds = self.getSelectedMusician.map({"\($0.id ?? 0)"}).joined(separator: ",")
        }
        else
        {
           // musicianIds = (self.selectedSinger?.musicians?.map({"\($0.id ?? 0)"}) ?? []).joined(separator: ",")
          
            if isFromMultiple {
                var strArray : [String] = []
                for i in self.selectedSingers {
                    strArray.append("\(i.id ?? 0)")
                }
                musicianIds = strArray.joined(separator: ",")
            }
            else {
                musicianIds = (self.selectedSinger?.musicians?.map({"\($0.id ?? 0)"}) ?? []).joined(separator: ",")
            }
        }
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "yyyy-MM-dd"
        let bookingDate =  engToArb(str: formatter3.string(from: self.geSelectedDate ?? Date()))
        
       
        //"singer_category_id": self.categoriesDetails?.id,  added 4 march 2022 as per bacnekd changes
        
        
        var singerServices: [[String:String]] = []
        
        if self.singer_ServicesWithHour.count > 0{
              
                for service in self.singer_ServicesWithHour {
                    var singerServices1: [String:String] = [:]
                    singerServices1 = ["service_id": "\(service.service_id ?? "")", "hrs": "\(service.hrs ?? "")"]
                    singerServices.append(singerServices1)
                }

//            do {
//                let result = try? JSONDecoder().decode([String:String].self, from: self.singer_ServicesWithHour)
//                print(result)
//            } catch {
//                print(error)
//            }
            
//            let myDict = self.singer_ServicesWithHour.reduce(into: [String: String]()) {
//                //$0[$1.service_id!] = $1.hrs
//                $0["service_id"] = $1.service_id
//                $0["hrs"] = $1.hrs
//
//            }
            
            let service_id = self.singer_ServicesWithHour[0].service_id!
            let hrs = self.singer_ServicesWithHour[0].hrs!

           // singerServices = [["service_id": service_id, "hrs": hrs]]

        }

        // Build singers array for v10 API
        var singersArrayCreate: [[String: Any]] = []
        if isFromMultiple {
            for singer in self.selectedSingers {
                var singerDict: [String: Any] = [:]
                singerDict["singer_id"] = "\(singer.id ?? 0)"
                singerDict["is_service"] = singer.is_service ?? 0

                // Find services that belong to this singer
                var thisSingerServices: [[String: String]] = []
                if singer.is_service == 1, let singerAvailableServices = singer.services {
                    // Get service IDs that belong to this singer
                    let singerServiceIds = singerAvailableServices.map { $0.id ?? 0 }

                    // First try singer_ServicesWithHour
                    if self.singer_ServicesWithHour.count > 0 {
                        for service in self.singer_ServicesWithHour {
                            if let serviceIdStr = service.service_id,
                               let serviceId = Int(serviceIdStr),
                               singerServiceIds.contains(serviceId) {
                                thisSingerServices.append([
                                    "service_id": serviceIdStr,
                                    "hrs": service.hrs ?? "00:00:00"
                                ])
                            }
                        }
                    }

                    // If still empty, check selectedServicesData
                    if thisSingerServices.count == 0 && self.selectedServicesData.count > 0 {
                        for service in self.selectedServicesData {
                            if let serviceId = service.id, singerServiceIds.contains(serviceId) {
                                thisSingerServices.append([
                                    "service_id": "\(serviceId)",
                                    "hrs": "00:00:00"
                                ])
                            }
                        }
                    }

                    // If still empty, use singer's first available service (default)
                    if thisSingerServices.count == 0 {
                        if let firstService = singerAvailableServices.first, let serviceId = firstService.id {
                            thisSingerServices.append([
                                "service_id": "\(serviceId)",
                                "hrs": "00:00:00"
                            ])
                        }
                    }
                }
                singerDict["singer_services"] = thisSingerServices
                singersArrayCreate.append(singerDict)
            }
        } else {
            var singerDict: [String: Any] = [:]
            singerDict["singer_id"] = "\(self.selectedSinger?.id ?? 0)"
            singerDict["is_service"] = self.selectedSinger?.is_service ?? 0
            singerDict["singer_services"] = singerServices
            singersArrayCreate.append(singerDict)
        }

        var parameter = ["":""] as [String : Any]
        
        if appDelegate.isFromBackPaymentScreen == true
        {
            if str_band_price_id == ""
            {
                parameter = [
                    "booking_date": bookingDate,//"2021-09-25"
                    "booking_type": self.selectedServicesData.count > 0 ? "2":"1",
                    "is_default_musicians": !isFromCustom,
                    "is_default_services": 0,
                    "musician_ids":musicianIds,
                    "payment_amount": self.booking_price?.replacingOccurrences(of: ",", with: "") ?? 0,
                    "payment_type":"knet",
                    "singer_id": isFromMultiple ? "\(self.selectedSingers.map({ "\($0.id ?? 0)" }).joined(separator: ","))" : "\(self.selectedSinger?.id ?? 0)",
                    "singer_services": self.singer_ServicesWithHour.count > 0 ? singerServices : [],
                 //   "transaction_id": id,
                    "service_ids": selectedService.map({"\($0.id ?? 0)"}).joined(separator: ","),
                    "singer_category_id": self.categoriesDetails?.id ?? 0,
                    "card_type":"",
                    "card_number":"",
                    "card_exp_month":"",
                    "card_exp_year":"",
                    "singer_booking_id": appDelegate.singer_booking_id,
                    "device_type": deviceType
                ]  as [String : Any]
            }
            else
            {
                parameter = [
                    "band_price_id": str_band_price_id,
                    "booking_date": bookingDate,//"2021-09-25"
                    "booking_type": self.selectedServicesData.count > 0 ? "2":"1",
                    "is_default_musicians": !isFromCustom,
                    "is_default_services": 0,
                    "musician_ids":musicianIds,
                    "payment_amount": self.booking_price?.replacingOccurrences(of: ",", with: "") ?? 0,
                    "payment_type":"knet",
                    "singer_id": isFromMultiple ? "\(self.selectedSingers.map({ "\($0.id ?? 0)" }).joined(separator: ","))" : "\(self.selectedSinger?.id ?? 0)",
                    "singer_services": self.singer_ServicesWithHour.count > 0 ? singerServices : [],
                 //   "transaction_id": id,
                    "service_ids": selectedService.map({"\($0.id ?? 0)"}).joined(separator: ","),
                    "singer_category_id": self.categoriesDetails?.id ?? 0,
                    "card_type":"",
                    "card_number":"",
                    "card_exp_month":"",
                    "card_exp_year":"",
                    "singer_booking_id": appDelegate.singer_booking_id,
                    "device_type": deviceType
                ]  as [String : Any]
            }
            
            
        }
        else
        {
            if str_band_price_id == ""
            {
                parameter = [
                    "booking_date": bookingDate,//"2021-09-25"
                    "booking_type": self.selectedServicesData.count > 0 ? "2":"1",
                    "is_default_musicians": !isFromCustom,
                    "is_default_services": 0,
                    "musician_ids":musicianIds,
                    "payment_amount": self.booking_price?.replacingOccurrences(of: ",", with: "") ?? 0,
                    "payment_type":"knet",
                    "singer_id": isFromMultiple ? "\(self.selectedSingers.map({ "\($0.id ?? 0)" }).joined(separator: ","))" : "\(self.selectedSinger?.id ?? 0)",
                    "singer_services": self.singer_ServicesWithHour.count > 0 ? singerServices : [],
                 //   "transaction_id": id,
                    "service_ids": selectedService.map({"\($0.id ?? 0)"}).joined(separator: ","),
                    "singer_category_id": self.categoriesDetails?.id ?? 0,
                    "card_type":"",
                    "card_number":"",
                    "card_exp_month":"",
                    "card_exp_year":"",
                    "device_type": deviceType
                ]  as [String : Any]
            }
            else
            {
                parameter = [
                    "band_price_id": str_band_price_id,
                    "booking_date": bookingDate,//"2021-09-25"
                    "booking_type": self.selectedServicesData.count > 0 ? "2":"1",
                    "is_default_musicians": !isFromCustom,
                    "is_default_services": 0,
                    "musician_ids":musicianIds,
                    "payment_amount": self.booking_price?.replacingOccurrences(of: ",", with: "") ?? 0,
                    "payment_type":"knet",
                    "singer_id": isFromMultiple ? "\(self.selectedSingers.map({ "\($0.id ?? 0)" }).joined(separator: ","))" : "\(self.selectedSinger?.id ?? 0)",
                    "singer_services": self.singer_ServicesWithHour.count > 0 ? singerServices : [],
                 //   "transaction_id": id,
                    "service_ids": selectedService.map({"\($0.id ?? 0)"}).joined(separator: ","),
                    "singer_category_id": self.categoriesDetails?.id ?? 0,
                    "card_type":"",
                    "card_number":"",
                    "card_exp_month":"",
                    "card_exp_year":"",
                    "device_type": deviceType
                ]  as [String : Any]
            }
            
        }
        
            //        "start_time":"12:00:00",
            //        "end_time":"13:00:00",
            
            //"payment_amount":self.settingsResponse?.settings?.minimum_booking_payment ?? "50",  previous code
           
        let selectedCountry = getSelectedCountry()
        if selectedCountry != nil {
            parameter["country_id"] = selectedCountry?.id
            parameter["currency_id"] = selectedCountry?.currency?.id
        }

        // Add singers array for v10 API
        parameter["singers"] = singersArrayCreate

        JSN.log("create bookingapi param==>%@", parameter)

        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.createBooking, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    JSN.log("create booking api reasponse ==>%@", String(data: data, encoding: .utf8))
                    
                    if appDelegate.singer_booking_id != ""
                    {
                        let bookingResponse = try? JSONDecoder().decode(createBookingObjOld.self, from: data)

                        if bookingResponse?.status == true {

                            let booking_id = "\(String(describing: bookingResponse?.singer_booking_id))"
                            let number = Int(booking_id.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
                            appDelegate.singer_booking_id = "\(number ?? 0)"

                            self.booking_transaction_message = bookingResponse?.message ?? ""

                            // New payment flow logic
                            if bookingResponse?.is_cod == 1 {
                                // COD - Go to Payment Success Page directly
                                if self.parentCatObj?.id == 21 || self.parentCatObj?.id == 23 {
                                    let paymentvc = WeddingMusiciaPaymentSucessVC()
                                    paymentvc.getResponseMsgOld = bookingResponse
                                    paymentvc.catId = self.parentCatObj?.id ?? 0
                                    paymentvc.subCatId = self.categoriesDetails?.id ?? 0
                                    self.fadeTo(paymentvc)
                                } else {
                                    let paymentvc = PaymentSuccessVC()
                                    paymentvc.catId = self.parentCatObj?.id ?? 0
                                    paymentvc.getResponseMsgOld = bookingResponse
                                    self.fadeTo(paymentvc)
                                }
                            } else if bookingResponse?.payment != nil {
                                // KNET WebView
                                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyBoard.instantiateViewController(withIdentifier: "WebPaymentVC") as! WebPaymentVC
                                vc.dicCreateBookingObjOld = bookingResponse!
                                vc.dicParentCatObj = self.parentCatObj
                                vc.categoriesDetails = self.categoriesDetails
                                self.navigationController?.pushViewController(vc, animated: true)
                            } else {
                                // Saudi Arabia payment flow
                                ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
                                self.dicCreateBookingObjOld = bookingResponse!
                                let sessionPayment = Session()
                                sessionPayment.delegate = self
                                sessionPayment.dataSource = self
                                sessionPayment.appearance = self
                                sessionPayment.start()
                            }

                        }
                        else
                        {
                            self.isErrorShowing = true
                            AlertView.instance.showAlert(title: Localized("alert"), message: NSAttributedString(string: bookingResponse?.message ?? Localized("somethingWentWrong")), alertType: .oneButton)
                            AlertView.instance.alertViewDelegate = self
                        }
                    }
                    else
                    {
                        let bookingResponse = try? JSONDecoder().decode(createBookingObj.self, from: data)

                        if bookingResponse?.status == true {

                            self.booking_transaction_message = bookingResponse?.message ?? ""

                            let booking_id = "\(String(describing: bookingResponse?.singer_booking_id))"
                            let number = Int(booking_id.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
                            appDelegate.singer_booking_id = "\(number ?? 0)"

                            // New payment flow logic
                            if bookingResponse?.is_cod == 1 {
                                // COD - Go to Payment Success Page directly
                                if self.parentCatObj?.id == 21 || self.parentCatObj?.id == 23 {
                                    let paymentvc = WeddingMusiciaPaymentSucessVC()
                                    paymentvc.getResponseMsg = bookingResponse
                                    paymentvc.catId = self.parentCatObj?.id ?? 0
                                    paymentvc.subCatId = self.categoriesDetails?.id ?? 0
                                    self.fadeTo(paymentvc)
                                } else {
                                    let paymentvc = PaymentSuccessVC()
                                    paymentvc.catId = self.parentCatObj?.id ?? 0
                                    paymentvc.getResponseMsg = bookingResponse
                                    self.fadeTo(paymentvc)
                                }
                            } else if bookingResponse?.payment != nil {
                                // KNET WebView
                                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyBoard.instantiateViewController(withIdentifier: "WebPaymentVC") as! WebPaymentVC
                                vc.dicCreateBookingObj = bookingResponse!
                                vc.dicParentCatObj = self.parentCatObj
                                vc.categoriesDetails = self.categoriesDetails
                                self.navigationController?.pushViewController(vc, animated: true)
                            } else {
                                // Saudi Arabia payment flow
                                ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
                                self.dicCreateBookingObj = bookingResponse!
                                let sessionPayment = Session()
                                sessionPayment.delegate = self
                                sessionPayment.dataSource = self
                                sessionPayment.appearance = self
                                sessionPayment.start()
                            }

                        }
                        else
                        {
                            self.isErrorShowing = true
                            AlertView.instance.showAlert(title: Localized("alert"), message: NSAttributedString(string: bookingResponse?.message ?? Localized("somethingWentWrong")), alertType: .oneButton)
                            AlertView.instance.alertViewDelegate = self
                        }
                    }
                    
                    
//                    if bookingResponse?.status == true {
//
//                    if self.parentCatObj?.id == 21 || self.parentCatObj?.id == 23 {
//                        let paymentvc = WeddingMusiciaPaymentSucessVC()
//                        paymentvc.getResponseMsg = bookingResponse
//                        paymentvc.catId = self.parentCatObj?.id ?? 0
//                        paymentvc.subCatId = self.categoriesDetails?.id ?? 0
//                        paymentvc.retryPayment = {
//                            self.startKNetPayment()
//                        }
//                        self.fadeTo(paymentvc)
//                    } else{
//                        let paymentvc = PaymentSuccessVC()
//                        paymentvc.catId = self.parentCatObj?.id ?? 0
//                        paymentvc.getResponseMsg = bookingResponse
//                        paymentvc.retryPayment = {
//                            self.startKNetPayment()
//                        }
//                        self.fadeTo(paymentvc)
//                    }
//
//
//                    }else {
//                        //                        self.showAlert(title: Localized("alert"), message: bookingResponse?.message ?? Localized("somethingWentWrong"))
//                        AlertView.instance.showAlert(title: Localized("alert"), message: NSAttributedString(string: bookingResponse?.message ?? Localized("somethingWentWrong")), alertType: .oneButton)
//                        AlertView.instance.alertViewDelegate = self
//                        //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
//                    }
                }
                catch (let error) {
                    JSN.log("login uer ====>%@", error)
                }
                break
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                break
            }
        }
    }
    
//    func apiPay(id: String) {
//
//        var musicianIds = ""
//        if self.isFromCustom == true
//        {
//            musicianIds = self.getSelectedMusician.map({"\($0.id ?? 0)"}).joined(separator: ",")
//        }
//        else
//        {
//            musicianIds = (self.selectedSinger?.musicians?.map({"\($0.id ?? 0)"}) ?? []).joined(separator: ",")
//        }
//        let formatter3 = DateFormatter()
//        formatter3.dateFormat = "yyyy-MM-dd"
//        let bookingDate =  formatter3.string(from: self.geSelectedDate ?? Date())
//
//
//        //"singer_category_id": self.categoriesDetails?.id,  added 4 march 2022 as per bacnekd changes
//
//
//        var singerServices: [[String:String]] = []
//
//        if self.singer_ServicesWithHour.count > 0{
//
//                for service in self.singer_ServicesWithHour {
//                    var singerServices1: [String:String] = [:]
//                    singerServices1 = ["service_id": "\(service.service_id ?? "")", "hrs": "\(service.hrs ?? "")"]
//                    singerServices.append(singerServices1)
//                }
//
////            do {
////                let result = try? JSONDecoder().decode([String:String].self, from: self.singer_ServicesWithHour)
////                print(result)
////            } catch {
////                print(error)
////            }
//
////            let myDict = self.singer_ServicesWithHour.reduce(into: [String: String]()) {
////                //$0[$1.service_id!] = $1.hrs
////                $0["service_id"] = $1.service_id
////                $0["hrs"] = $1.hrs
////            }
//
//            let service_id = self.singer_ServicesWithHour[0].service_id!
//            let hrs = self.singer_ServicesWithHour[0].hrs!
//
//           // singerServices = [["service_id": service_id, "hrs": hrs]]
//
//        }
//
//        var parameter = [
//            "booking_date": bookingDate,//"2021-09-25"
//            "booking_type": self.selectedServicesData.count > 0 ? "2":"1",
//            "is_default_musicians": !isFromCustom,
//            "is_default_services": 0,
//            "musician_ids":musicianIds,
//            "payment_amount": self.booking_price ?? 0,
//            "payment_type":"knet",
//            "singer_id": isFromMultiple ? "\(self.selectedSingers.map({ "\($0.id ?? 0)" }).joined(separator: ","))" : "\(self.selectedSinger?.id ?? 0)",
//            "singer_services": self.singer_ServicesWithHour.count > 0 ? singerServices : [],
//            "transaction_id": id,
//            "service_ids": selectedService.map({"\($0.id ?? 0)"}).joined(separator: ","),
//            "singer_category_id": self.categoriesDetails?.id ?? 0,
//            "card_type":"",
//            "card_number":"",
//            "card_exp_month":"",
//            "card_exp_year":"",
//            "device_type": deviceType
//        ]  as [String : Any]
//            //        "start_time":"12:00:00",
//            //        "end_time":"13:00:00",
//
//            //"payment_amount":self.settingsResponse?.settings?.minimum_booking_payment ?? "50",  previous code
//
//        let selectedCountry = getSelectedCountry()
//        if selectedCountry != nil {
//            parameter["country_id"] = selectedCountry?.id
//            parameter["currency_id"] = selectedCountry?.currency?.id
//        }
//        JSN.log("create bookingapi param==>%@", parameter)
//
//        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
//        APIManager.handler.PostRequest(url: ApiUrl.createBooking, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
//            ActivityIndicatorWithLabel.shared.hideProgressView()
//            switch result {
//            case .success(let data):
//                do {
//                    guard let data = data else {return}
//                    JSN.log("create booking api reasponse ==>%@", String(data: data, encoding: .utf8))
//                    let bookingResponse = try? JSONDecoder().decode(createBookingObj.self, from: data)
//
////                    if bookingResponse?.status == true {
//
//                    if self.parentCatObj?.id == 21 || self.parentCatObj?.id == 23 {
//                        let paymentvc = WeddingMusiciaPaymentSucessVC()
//                      //  paymentvc.getResponseMsg = bookingResponse
//                        paymentvc.catId = self.parentCatObj?.id ?? 0
//                        paymentvc.subCatId = self.categoriesDetails?.id ?? 0
//                        paymentvc.retryPayment = {
//                            self.startKNetPayment()
//                        }
//                        self.fadeTo(paymentvc)
//                    } else{
//                        let paymentvc = PaymentSuccessVC()
//                        paymentvc.catId = self.parentCatObj?.id ?? 0
//                        paymentvc.getResponseMsg = bookingResponse
//                        paymentvc.retryPayment = {
//                            self.startKNetPayment()
//                        }
//                        self.fadeTo(paymentvc)
//                    }
//
//
////                    }else {
////                        //                        self.showAlert(title: Localized("alert"), message: bookingResponse?.message ?? Localized("somethingWentWrong"))
////                        AlertView.instance.showAlert(title: Localized("alert"), message: NSAttributedString(string: bookingResponse?.message ?? Localized("somethingWentWrong")), alertType: .oneButton)
////                        AlertView.instance.alertViewDelegate = self
////                        //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
////                    }
//                }
//                catch (let error) {
//                    JSN.log("login uer ====>%@", error)
//                }
//                break
//            case .failure(let error):
//                JSN.log("failur error login api ===>%@", error)
//                break
//            }
//        }
//    }
    
    //MARK:- Contact US API Calling
    fileprivate func apiGetSettingDetails() {
        APIManager.handler.GetRequest(url: ApiUrl.settings, isLoader: true, header: nil, controller: self) { (result) in
            switch result {
            case .success(let data):
                do {
                    if let getDara = data {
                        self.settingsResponse = try JSONDecoder().decode(SettingResponse.self, from: getDara)
                        CategoriesModel.shared.settingResponse = self.settingsResponse
                        if self.settingsResponse?.status == true {
                            
//                            let selectedCountry = getSelectedCountry()
//                            
//                            if selectedCountry?.country_en == "Saudi arabia"{
//                                // prev it was in viewdidload, Now keys dynamic
//                                //let secretKey = SecretKey(sandbox: "sk_test_JZu1kBnWwMGtyqROYc9DQbFe", production: "sk_live_3Q9E1mPr8tb0y6MjzuHXvDGN")
//                                let secretKey = SecretKey(sandbox: self.settingsResponse?.settings?.tap_secret_test_ios_ksa ?? "", production: self.settingsResponse?.settings?.tap_secret_test_ios_ksa ?? "")
//                                GoSellSDK.secretKey = secretKey
//                                GoSellSDK.mode = .sandbox
//                                //GoSellSDK.mode = .production
//                            } else{
//                                // prev it was in viewdidload, Now keys dynamic
//                                //let secretKey = SecretKey(sandbox: "sk_test_JZu1kBnWwMGtyqROYc9DQbFe", production: "sk_live_3Q9E1mPr8tb0y6MjzuHXvDGN")
//                                let secretKey = SecretKey(sandbox: self.settingsResponse?.settings?.tap_secret_test_ios_kwt ?? "", production: self.settingsResponse?.settings?.tap_secret_live_ios_kwt ?? "")
//                                GoSellSDK.secretKey = secretKey
//                                GoSellSDK.mode = .sandbox
//                                //GoSellSDK.mode = .production
//                            }
                            
                            
                            let bookingAmount = (Double(self.selectedSinger?.price ?? "0") ?? 0) *
                            (Double(self.booking_price ?? "0") ?? 1)
                            //(Double(self.settingsResponse?.settings?.minimum_booking_payment ?? "1.0") ?? 1)
                            let calculateBookingAmount = bookingAmount/100
                            //                            let calculateBookingAmount = bookingAmount/50.0
                            //if let amount = self.settingsResponse?.settings?.minimum_booking_payment,
//                            if let amount = self.booking_price,
//                               let dbAmount = Double(amount) {
//                                self.lblBookingAmount.text = String(format: "%.3f", dbAmount) + " KD"
//                            }
                            //self.lblBookingAmount.text = String(describing: Double((self.settingsResponse?.settings?.minimum_booking_payment)!)!) + " " + "KD"
                            if self.settingsResponse?.settings?.is_cod_enable == "1" {
                                self.codContainView.isHidden = false
                            }
                            
                            if self.settingsResponse?.settings?.is_online_payment_enable == "1" {
                                self.knetContainView.isHidden = false
                                self.creditCardContainVire.isHidden = false
                            }
                            
                            if self.settingsResponse?.settings?.is_cod_enable == "0" && self.settingsResponse?.settings?.is_online_payment_enable == "0" {
                                self.paymentContainView.isHidden = false
                            }
                            
                        }else {
                            self.showAlert(title: Localized("alert"), message: self.settingsResponse?.message ?? Localized("somethingWentWrong")) {

                            }
                            
                            
                                // Maintenance changes
//                                guard let window = UIApplication.shared.keyWindow else {
//                                         return
//                                     }
//                                     let frontViewController = MaintenanceViewController.object()
//                             //        let frontViewController = TabBarViewController.object() //TabBarController.object()
//                                     let frontNavigationController = UINavigationController(rootViewController: frontViewController)
//                                     frontNavigationController.setNavigationBarHidden(false, animated: false)
//                                     self.view.window?.rootViewController = frontNavigationController
//
//                                     let options: UIView.AnimationOptions = .transitionCrossDissolve
//                                     let duration: TimeInterval = 1
//                                     UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: { completed in
//                                         // maybe do something on completion here
//                                     })
                                
                            
                            
                            
                            //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
                        }
                    }
                }catch (let error) {
                    JSN.log("login uer ====>%@", error)
                }
                break
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                break
            }
        }
    }
    
    func showHideCancelView() {//title: String?, msg: String?
        topConstraint.constant = -75
//        lblCancel.text = title
//        lblTryAgain.text = ms
        UIView.transition(with: viewCancel, duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.viewCancel.isHidden = false
                            self.topConstraint.constant = 0
                          })
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { timer in
            timer.invalidate()
            self.viewCancel.isHidden = true
        }
    }
}

extension OnlinePaymentVC: SessionDelegate, SessionDataSource {
    var customer: Customer? {
        return self.newCustomer
    }
    var newCustomer: Customer? {
        var emailAddress:EmailAddress? = nil
        do {
            emailAddress = try EmailAddress(emailAddressString: SamratGlobal.loggedInUser()?.user?.email ?? "")
        } catch let error {
            JSN.log("error==>%@", error.localizedDescription)
        }
//        let emailAddress = try! EmailAddress(emailAddressString: SamratGlobal.loggedInUser()?.user?.email ?? "")
        //let phoneNumber = try! PhoneNumber(isdNumber: "965", phoneNumber: SamratGlobal.loggedInUser()?.user?.mobile_no ?? "")
        // Prev only one country now its for different so need to change static
        // send code
        let countryCode = (SamratGlobal.loggedInUser()?.user?.country_code ?? "").isEmpty ? "965" : (SamratGlobal.loggedInUser()?.user?.country_code ?? "965")
        let phoneNum = (SamratGlobal.loggedInUser()?.user?.mobile_no ?? "").isEmpty ? "": (SamratGlobal.loggedInUser()?.user?.mobile_no ?? "")
        JSN.log("phone number ==>%@,==>%@", countryCode,phoneNum)
        let phoneNumber = try! PhoneNumber(isdNumber: countryCode, phoneNumber: phoneNum)
        return try? Customer(emailAddress:  emailAddress,
                             phoneNumber:   phoneNumber,
                             firstName:     SamratGlobal.loggedInUser()?.user?.name ?? "",
                             middleName:    "",
                             lastName:      "")
    }
    var mode: TransactionMode {
        return .purchase
    }
    var currency: Currency? {
//        return .with(isoCode: "KWD")
        return .with(isoCode: SelectedCurrency.shared.currentAppCurrencyCode)
    }
    
    internal var paymentType: PaymentType {
         
        return .card
     }
    
    var amount: Decimal {
        //if let amount = self.settingsResponse?.settings?.minimum_booking_payment, let dbAmount = Double(amount) {
//        if let amount = self.booking_price, let dbAmount = Double(amount) {
//            return Decimal(dbAmount)
//        }
        
        if let amount = self.booking_price?.replacingOccurrences(of: ",", with: ""), let dbAmount = Double(amount) {
                          return Decimal(dbAmount)
                } else{
                    return 0.0
                }
 
        //return Decimal(self.booking_price ?? 0.0)
    }
    
    func sessionIsStarting(_ session: SessionProtocol) {
        print("sessionIsStarting")
    }
    
    func sessionHasStarted(_ session: SessionProtocol) {
        print("sessionHasStarted")
        ActivityIndicatorWithLabel.shared.hideProgressView()
    }
    
    func sessionHasFailedToStart(_ session: SessionProtocol) {
        print("sessionHasFailedToStart")
        ActivityIndicatorWithLabel.shared.hideProgressView()
    }
    
    func authorizationSucceed(_ authorize: Authorize, on session: SessionProtocol) {
        print("authorizationSucceed \(authorize)")
    }
    
    func authorizationFailed(with authorize: Authorize?, error: TapSDKError?, on session: SessionProtocol) {
        print("authorizationFailed \(authorize)")
        ActivityIndicatorWithLabel.shared.hideProgressView()
    }
    
    func jsonToString(json: AnyObject)
    {
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: .utf8) // the data will be converted to the string
            print(convertedString!) // <-- here is ur string
            
        } catch let myJSONError {
            print(myJSONError)
        }
        
    }

    func paymentSucceed(_ charge: Charge, on session: SessionProtocol)
    {
        JSN.log("payment identifire ==>%@", charge.identifier)
        
        var type = "1"
        
        if charge.card?.brand == .masterCard
        {
            type = "1"
        }
        else if charge.card?.brand == .visa
        {
            type = "2"
        }
        else if charge.card?.brand == .americanExpress
        {
            type = "3"
        }
        
        let dicDaya = NSMutableDictionary()
        dicDaya.setValue(charge.identifier, forKey: "identifier")
        dicDaya.setValue(charge.apiVersion, forKey: "apiVersion")
        dicDaya.setValue(charge.amount, forKey: "amount")
        
        let dicDatacurrency = NSMutableDictionary()
        dicDatacurrency.setValue(charge.currency.isoCode, forKey: "isoCode")
        dicDaya.setValue(dicDatacurrency, forKey: "currency")

        let dicDatacustomer = NSMutableDictionary()
        dicDatacustomer.setValue(charge.customer.identifier, forKey: "identifier")
        dicDatacustomer.setValue(charge.customer.emailAddress?.value, forKey: "emailAddress")
        dicDatacustomer.setValue(charge.customer.phoneNumber?.phoneNumber, forKey: "phoneNumber")
        dicDatacustomer.setValue(charge.customer.firstName, forKey: "firstName")
        dicDatacustomer.setValue(charge.customer.middleName, forKey: "middleName")
        dicDatacustomer.setValue(charge.customer.lastName, forKey: "lastName")
        dicDatacustomer.setValue(charge.customer.descriptionText, forKey: "description")
         dicDatacustomer.setValue(charge.customer.title, forKey: "title")
        dicDatacustomer.setValue(charge.customer.nationality, forKey: "nationality")
         dicDaya.setValue(dicDatacustomer, forKey: "customer")

        
        dicDaya.setValue(charge.isLiveMode, forKey: "isLiveMode")
        dicDaya.setValue(charge.cardSaved, forKey: "cardSaved")
        dicDaya.setValue(charge.object, forKey: "object")
        
        
        let dicDatacard = NSMutableDictionary()
        dicDatacard.setValue(charge.card?.identifier, forKey: "identifier")
        dicDatacard.setValue(charge.card?.object, forKey: "object")
        dicDatacard.setValue(charge.card?.firstSixDigits, forKey: "firstSixDigits")
        dicDatacard.setValue(charge.card?.lastFourDigits, forKey: "lastFourDigits")
        dicDatacard.setValue(charge.card?.fingerprint, forKey: "fingerprint")
        dicDatacard.setValue(charge.card?.cardholderName, forKey: "cardholderName")
        dicDatacard.setValue(type, forKey: "cardType")
        dicDaya.setValue(dicDatacard, forKey: "card")
     
        dicDaya.setValue(charge.requires3DSecure, forKey: "requires3DSecure")
        dicDaya.setValue(charge.transactionDetails.url, forKey: "transactionDetails")
        dicDaya.setValue(charge.transactionDetails.timeZone, forKey: "transactionDetails")
        dicDaya.setValue(charge.descriptionText, forKey: "description")
        dicDaya.setValue(charge.metadata, forKey: "metadata")
        
        
        let dicDatareference = NSMutableDictionary()
        dicDatareference.setValue(charge.reference?.acquirer, forKey: "acquirer")
        dicDatareference.setValue(charge.reference?.gatewayReference, forKey: "gatewayReference")
        dicDatareference.setValue(charge.reference?.paymentReference, forKey: "paymentReference")
        dicDatareference.setValue(charge.reference?.trackingNumber, forKey: "trackingNumber")
        dicDatareference.setValue(charge.reference?.transactionNumber, forKey: "transactionNumber")
        dicDatareference.setValue(charge.reference?.orderNumber, forKey: "orderNumber")
        dicDatareference.setValue(charge.reference?.gosellID, forKey: "gosellID")
        dicDaya.setValue(dicDatareference, forKey: "reference")

        
        let dicDatareceiptSettings = NSMutableDictionary()
        dicDatareceiptSettings.setValue(charge.receiptSettings?.identifier, forKey: "identifier")
        dicDatareceiptSettings.setValue(charge.receiptSettings?.email, forKey: "email")
        dicDatareceiptSettings.setValue(charge.receiptSettings?.sms, forKey: "sms")
        dicDaya.setValue(dicDatareceiptSettings, forKey: "receiptSettings")
        
        let dicDataresponse = NSMutableDictionary()
        dicDataresponse.setValue(charge.response?.code, forKey: "code")
        dicDataresponse.setValue(charge.response?.message, forKey: "message")
        dicDaya.setValue(dicDataresponse, forKey: "response")
        
        var convertedString = ""
        
        
        if let theJSONData = try?  JSONSerialization.data(
              withJSONObject: dicDaya,
              options: .prettyPrinted
              ),
              let theJSONText = String(data: theJSONData,
                                       encoding: String.Encoding.ascii) {
                  print("JSON string = \n\(theJSONText)")
            
            convertedString = theJSONText
            }

                
//        do {
//            let data1 =  try JSONSerialization.data(withJSONObject: dicDaya, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
//            convertedString = String(data: data1, encoding: .utf8)! // the data will be converted to the string
//            print(convertedString) // <-- here is ur string
//
//        } catch let myJSONError {
//            print(myJSONError)
//        }
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let Dform = DateFormatter()
        Dform.dateFormat = "yyyy-MM-dd"
        let strDate = Dform.string(from: charge.transactionDetails.creationDate)
        
       
        
        callTransactionStore(singer_booking_id: appDelegate.singer_booking_id, payment_amount: "\(charge.amount)", transaction_id: charge.identifier, transaction_date: strDate, gateway_response_json: convertedString, card_type: type, card_number: charge.card?.lastFourDigits ?? "")
    }
  
    
    func callTransactionStore(singer_booking_id: String,payment_amount: String,transaction_id: String,transaction_date: String,gateway_response_json: String,card_type: String,card_number: String) {
        
        let parameter = [
            "singer_booking_id":singer_booking_id,
            "payment_type":"card",
            "payment_amount":payment_amount.replacingOccurrences(of: ",", with: ""),
            "transaction_id":transaction_id,
            "card_type":card_type,
            "card_number":card_number,
            "gateway_response_json":gateway_response_json,
            "currency_id": "\(getSelectedCountry()?.currency_id ?? 0)",
            "transcation_date":transaction_date
        ]  as [String : Any]
        JSN.log("create transactionStore param==>%@", parameter)
        
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.transactionStore, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    JSN.log("transactionStore api reasponse ==>%@", String(data: data, encoding: .utf8))
                    
                    let dicTransaction = try JSONDecoder().decode(SettingResponse.self, from: data)

                    if dicTransaction.status == true
                    {
                        appDelegate.singer_booking_id = ""
                        if self.parentCatObj?.id == 21 || self.parentCatObj?.id == 23 {
                            let paymentvc = WeddingMusiciaPaymentSucessVC()
                            paymentvc.strMessage = self.booking_transaction_message
                            paymentvc.catId = self.parentCatObj?.id ?? 0
                            paymentvc.subCatId = self.categoriesDetails?.id ?? 0
                            paymentvc.strType = 1
                            paymentvc.retryPayment = {
                                self.navigationController?.popViewController(animated: true)
                            }
                            self.fadeTo(paymentvc)
                        }
                        else
                        {
                            let paymentvc = PaymentSuccessVC()
                            paymentvc.catId = self.parentCatObj?.id ?? 0
                            paymentvc.strMessage = self.booking_transaction_message
                            paymentvc.strType = 1
                            paymentvc.retryPayment = {
                                self.navigationController?.popViewController(animated: true)
                            }
                            self.fadeTo(paymentvc)
                        }
                        
                    }
                    
                    
   
                }
                catch (let error) {
                    JSN.log("login uer ====>%@", error)
                }
                break
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                break
            }
        }
        
    }
    
    func paymentFailed(with charge: Charge?, error: TapSDKError?, on session: SessionProtocol) {
        if charge?.status == ChargeStatus.cancelled {
            showHideCancelView()
            return
        }
        print("paymentFailed \(charge) \(error)")
        
        if self.parentCatObj?.id == 21 || self.parentCatObj?.id == 23 {
            let paymentvc = WeddingMusiciaPaymentSucessVC()
            paymentvc.catId = self.parentCatObj?.id ?? 0
            paymentvc.subCatId = self.categoriesDetails?.id ?? 0
            paymentvc.strType = 0
           /// paymentvc.getResponseMsg = nil
            paymentvc.retryPayment = {
                self.startKNetPayment()
            }
            self.fadeTo(paymentvc)
        } else{
            let paymentvc = PaymentSuccessVC()
            paymentvc.getResponseMsg = nil
            paymentvc.catId = self.parentCatObj?.id ?? 0
            paymentvc.strType = 0
            paymentvc.retryPayment = {
                self.startKNetPayment()
            }
            self.fadeTo(paymentvc)
        }
        
//        let paymentvc = PaymentSuccessVC()
//        paymentvc.getResponseMsg = nil
//        paymentvc.retryPayment = {
//            self.startKNetPayment()
//        }
//        self.fadeTo(paymentvc)
    }
    
    func applePaymentCanceled(on session: SessionProtocol) {
        print("applePaymentCanceled \(session)")
        self.showAlert(title: Localized("alert"), message: Localized("Payment Cancelled")) {
            
        }
    }
    
    func showTermsAlert() {
//        let arrayString = [
//            Localized("singerSelectAlert1"),
//            Localized("singerSelectAlert2"),
//            Localized("singerSelectAlert3")
//        ]
        let arrayString = [
            Localized("singerSelectAlert4").replacingOccurrences(of: "200", with: "\(self.booking_price ?? "0") \(SelectedCurrency.shared.currentAppCurrency)"),
            Localized("singerSelectAlert5"),
            Localized("singerSelectAlert6"),
            Localized("singerSelectAlert7"),
            Localized("singerSelectAlert9"),
            Localized("singerSelectAlert10")
        ]
//                let attStr = add(stringList: arrayString, font: UIFont.systemFont(ofSize: 15))
//                AlertView.instance.showAlert(title: Localized("termsAndConditions"), message: attStr, alertType: .twoButton)
        AlertView.instance.showAlert(title: Localized("termsAndConditions"), arrMessages: arrayString, alertType: .twoButton)
        AlertView.instance.alertViewDelegate = self
    }
}

extension OnlinePaymentVC: SessionAppearance {
    func appearanceMode(for session: SessionProtocol) -> SDKAppearanceMode {
        return .windowed
    }
    
    func headerTextColor(for session: SessionProtocol) -> UIColor? {
        return .black
    }
    
    func headerFont(for session: SessionProtocol) -> UIFont {
        return UIFont.systemFont(ofSize: 17)
    }
    
    func cardInputFieldsTextColor(for session: SessionProtocol) -> UIColor? {
        return .black
    }
    
    func cardInputFieldsInvalidTextColor(for session: SessionProtocol) -> UIColor? {
        return .red
    }
    
    func cardInputFieldsPlaceholderColor(for session: SessionProtocol) -> UIColor? {
        return .gray
    }
    
    func cardInputSaveCardSwitchOffTintColor(for session: SessionProtocol) -> UIColor? {
        return .lightGray
    }
    
    func cardInputSaveCardSwitchOnTintColor(for session: SessionProtocol) -> UIColor? {
        return .green
    }
    
    func isSecurityIconVisibleOnTapButton(for session: SessionProtocol) -> Bool {
        return true
    }
    
    func isLoaderVisibleOnTapButtton(for session: SessionProtocol) -> Bool {
        return true
    }
    
    func tapButtonBackgroundColor(for state: UIControl.State, session: SessionProtocol) -> UIColor? {
        return .lightGray
    }
    
    func sessionShouldShowStatusPopup(_ session: SessionProtocol) -> Bool {
        return false
    }
}

extension UIViewController
{
    func engToArb(str: String) -> String
    {
        var objString = str
        
        objString = objString.replacingOccurrences(of: "٠", with: "0")
        objString = objString.replacingOccurrences(of: "١", with: "1")
        objString = objString.replacingOccurrences(of: "٢", with: "2")
        objString = objString.replacingOccurrences(of: "٣", with: "3")
        objString = objString.replacingOccurrences(of: "٤", with: "4")
        objString = objString.replacingOccurrences(of: "٥", with: "5")
        objString = objString.replacingOccurrences(of: "٦", with: "6")
        objString = objString.replacingOccurrences(of: "٧", with: "7")
        objString = objString.replacingOccurrences(of: "٨", with: "8")
        objString = objString.replacingOccurrences(of: "٩", with: "9")

        return objString
    }
}
