import UIKit
import Kingfisher
import MessageUI

class MusiciansDetailViewController: UIViewController, MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var mainViewPopup: UIView!
    @IBOutlet weak var mainSubPopup: UIView!
    
    @IBOutlet weak var lblwha: UILabel!
    @IBOutlet weak var lblChooseOption: UILabel!
    @IBOutlet weak var lblEmails: UILabel!
    @IBOutlet weak var btnCancle: UIButton!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    // Declare a variable which stores checked rows. UITableViewCell gets dequeued and restored as you scroll up and down, so it is best to store a reference of rows which has been checked
    var rowsWhichAreChecked = [NSIndexPath]()
    
    @IBOutlet var musicianImgView: UIImageView!
    @IBOutlet var imgPlaceholder: UIImageView!
    @IBOutlet var lblSingerName: UILabel!
    @IBOutlet var lblSingerDesc: UILabel!
    @IBOutlet var playBtn: UIButton!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var viewPlayer: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewWA: UIView!
    
    var servicesAmountObj: servicesAmtObj? = nil
    var isPlayingFromVC = false
    
    //MARK:- @IBOutlets
    @IBOutlet var btnBookNow: UIButton!{
        didSet{
            btnBookNow.layer.cornerRadius = 22.5
        }
    }
    @IBOutlet var viewGradient: UIView!{
        didSet{
            viewGradient.layer.cornerRadius = 30.0
            viewGradient.clipsToBounds = true
            //            viewGradient.applyGradient(colours: [UIColor.black,UIColor.clear])
        }
    }
    
    var selectedSingerDetails:singersData? = nil
    var selectedServicesData:[servicesData] = []
    var categoriesDetails: CategoriesData? = nil
    var parentCatObj:CategoriesData? = nil
    var singer_ServicesWithHour:[singer_Services] = []
    
    fileprivate var startRendering = Date()
    fileprivate var endRendering = Date()
    fileprivate var startLoading = Date()
    fileprivate var endLoading = Date()
    fileprivate var profileResult = ""
    
    //var player = AVPlayer()
    // Formatting time for display
    let timeFormatter = NumberFormatter()
    
    var radioOption:Int?// Only used :: if u are 2. RadioButton Functionality implement
    
    var settingsResponse:SettingResponse? = nil
    
    var objMultipleSinger : MultipleSingerVC? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
//        self.lblEmails.text = Localized("email")
//        self.lblwha.text = Localized("WhatsApp")
//        self.lblChooseOption.text = Localized("Choose Option")
//        
//        self.btnCancle.setTitle(Localized("Cancel"), for: .normal)
       
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
        
        print("Aj print:- ", self.categoriesDetails?.id)
        
        
        self.lblSingerName.isHidden = true
        self.lblSingerDesc.isHidden = true
        self.viewGradient.isHidden = true
        self.viewPlayer.isHidden = true
        self.btnBookNow.isHidden = true
        
        self.tableView.backgroundColor = UIColor.clear
        tableView.register(UINib(nibName: "MusicBarTableViewCell", bundle: nil), forCellReuseIdentifier: "MusicBarTableViewCell")
        tableView.register(UINib(nibName: "MusiciansServiceTVCell", bundle: nil), forCellReuseIdentifier: "MusiciansServiceTVCell")
        tableView.register(UINib.init(nibName: "CommonButton", bundle: nil), forCellReuseIdentifier: "CommonButton")
        
        //        self.title = Localized("SINGER").uppercased() //"SINGER"
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
        
        //Background image logic
        let url = URL(string: self.selectedSingerDetails?.detail_image ?? "")
        self.musicianImgView.kf.setImage(with: url,
                                         placeholder: nil,
                                         options: [.transition(.fade(0.3)),
                                                   .cacheOriginalImage,
                                                   .forceTransition]) { (_, _) in

        } completionHandler: { (_, _, _, _) in
            self.imgPlaceholder.isHidden = true
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
    
    @IBAction func clickedWA(_ sender: Any) {
        print("Button Tapped")
        
        if let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=\(CategoriesModel.shared.settingResponse?.settings?.whatsapp_number ?? "")&text=") {
            
            if UIApplication.shared.canOpenURL(whatsappURL) {
                UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y <= 0.0 {
            self.musicianImgView.removeBlurToView()
        } else {
            let blur = (scrollView.contentOffset.y / 100);
            self.musicianImgView.addBlurToView(val: blur)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.mainViewPopup.isHidden = true
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
    }
    
    
    @objc func menuClick(_ sender:UIButton) {
        //isPlaying = false
        self.tableView.reloadData()
        self.view.endEditing(true)
        fadeFrom()
    }
    
    @IBAction func clickedWhstapp(_ sender: Any) {
        
        self.mainSubPopup.slideOut(to: kFTAnimationBottom, in: self.mainSubPopup.superview, duration: 0.3, delegate: self, start: Selector("temp"), stop: Selector("temp"))
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.mainViewPopup.isHidden = true
        }
        
        openWithWhatsapp()
    }
    
    @IBAction func clickedEmaila(_ sender: Any) {
        
        self.mainSubPopup.slideOut(to: kFTAnimationBottom, in: self.mainSubPopup.superview, duration: 0.3, delegate: self, start: Selector("temp"), stop: Selector("temp"))
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.mainViewPopup.isHidden = true
        }
        
        openWithEmail()
    }
    
    @IBAction func clickedCanels(_ sender: Any) {
        
        self.mainSubPopup.slideOut(to: kFTAnimationBottom, in: self.mainSubPopup.superview, duration: 0.3, delegate: self, start: Selector("temp"), stop: Selector("temp"))
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.mainViewPopup.isHidden = true
        }
    }
    
}

extension MusiciansDetailViewController : AlertViewDelegate {
    func okayButtonTapped() {
      
        if self.categoriesDetails?.id == 28 || self.categoriesDetails?.id == 24 || self.categoriesDetails?.id == 29 {
            let bookNowVc = BookNowWothCalendarVCBottom()
            bookNowVc.selectedSinger = self.selectedSingerDetails
            bookNowVc.selectedServicesData = self.selectedServicesData
            bookNowVc.parentCatObj = self.parentCatObj
            bookNowVc.singer_ServicesWithHour = self.singer_ServicesWithHour
            bookNowVc.categoriesDetails = self.categoriesDetails
            fadeTo(bookNowVc)
        } else{
            let bookNowVc = BookNowWothCalendarVC()
            bookNowVc.selectedSinger = self.selectedSingerDetails
            bookNowVc.selectedServicesData = self.selectedServicesData
            bookNowVc.parentCatObj = self.parentCatObj
            bookNowVc.singer_ServicesWithHour = self.singer_ServicesWithHour
            bookNowVc.categoriesDetails = self.categoriesDetails
            fadeTo(bookNowVc)
        }
        
//        let bookNowVc = BookNowWothCalendarVC()
//        bookNowVc.selectedSinger = self.selectedSingerDetails
//        bookNowVc.selectedServicesData = self.selectedServicesData
//        bookNowVc.parentCatObj = self.parentCatObj
//        bookNowVc.singer_ServicesWithHour = self.singer_ServicesWithHour
//        bookNowVc.categoriesDetails = self.categoriesDetails
//        fadeTo(bookNowVc)
    }
    
    func cancleButtonTapped() {
        
    }
    
    
    
}


extension MusiciansDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0 {
            return 0
        } else if section == 1{
            return 1
        }
        else if section == 2{
            return selectedSingerDetails?.services?.count ?? 0
        }
        else if section == 3{
            return 1
        }
        else{
            return 0
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 0
        } else {
            //return 80
            return UITableView.automaticDimension
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4 //self.musicanResponseObj?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return tableView.frame.height * 0.45
        } else {
            return .leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            return UITableViewCell()
            
        } else if indexPath.section == 1 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "MusicBarTableViewCell", for: indexPath) as! MusicBarTableViewCell
            cell.lblSingerName.text = self.selectedSingerDetails?.name ?? ""
            cell.lblSingerDesc.text = self.selectedSingerDetails?.description ?? ""
            cell.urlString = self.selectedSingerDetails?.audio ?? ""
            cell.selectedSingerDetails = self.selectedSingerDetails
            
            cell.btnBookNoe.addTarget(self, action: #selector(btnBookNowNextTapped(_:)), for: .touchUpInside)
            cell.btnBookNoe.tag = indexPath.row
            cell.onCheckboxTapAction = { checkboxDetails in
                self.selectedServicesData = checkboxDetails
            }
            
            cell.onDDSelectionTapAction = { dropDownData in
                self.singer_ServicesWithHour = dropDownData
            }
            
            
            
            // cell.layoutIfNeeded()
            // cell.sizeToFit()
            
            //cell.isPlaying = self.isPlayingFromVC
            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.section == 2 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "MusiciansServiceTVCell", for: indexPath) as! MusiciansServiceTVCell
            
            cell.lblMusicianName.text = self.selectedSingerDetails?.services?[indexPath.row].title
            cell.lblMusicanDesc.text = self.selectedSingerDetails?.services?[indexPath.row].description
            
            let x : Int = self.selectedSingerDetails?.services?[indexPath.row].total_service_amount ?? 0
            let stringValue = "\(x) " + SelectedCurrency.shared.currentAppCurrency
            
            if parentCatObj?.id == 21
            {
                cell.lblPrice.isHidden = true
             }
            else{
                cell.lblPrice.isHidden = false
            }
            
            cell.lblPrice.text = stringValue
            cell.btnBook.tag = indexPath.row
            cell.btnBook.addTarget(self, action: #selector(btnBookTapped(_:)), for: .touchUpInside)
            
            let filterdSection = self.selectedServicesData.filter({$0.id == self.selectedSingerDetails?.services?[indexPath.row].id ?? 0})
            if filterdSection.count > 0 {
                cell.imgSelectedStatus.isHighlighted = (filterdSection.contains(where: {$0.id == self.selectedSingerDetails?.services?[indexPath.row].id}))
            } else {
                cell.imgSelectedStatus.isHighlighted = false
            }
            
            
            var dictionary:[String] = []
            if let item = self.selectedSingerDetails?.services?[indexPath.row].max_hr_array {
                dictionary.removeAll()
                for service in item {
                    dictionary.append(service.title ?? "")
                }
            }
            
            if Language.shared.isArabic {
                cell.lblDurationWidth.constant = 40
               
            } else {
                cell.lblDurationWidth.constant = 60
            }
            
            if self.selectedSingerDetails?.services?[indexPath.row].charge_type == 1{
             
                //cell.lblHours.text =  self.selectedSingerDetails?.services?[indexPath.row].max_hr_text
                
            //  Condition added as per android suggessted
                
                if self.selectedSingerDetails?.services?[indexPath.row].duration?.count == 0{
                    
                } else{
                    cell.lblHours.text =  self.selectedSingerDetails?.services?[indexPath.row].duration
                }
                
                
                if self.selectedSingerDetails?.services?[indexPath.row].duration?.count ?? 0 > 0 {
                    cell.lblDuration.isHidden = false
                    cell.txtDropDown.isHidden = true
                    cell.lblHours.isHidden = false
                    cell.txtDropDownHeight.constant = 35
                    cell.bottomContraint.constant = 8
                } else {
                    cell.lblDuration.isHidden = true
                    cell.txtDropDown.isHidden = true
                    cell.lblHours.isHidden = true
                    cell.txtDropDownHeight.constant = 0
                    cell.bottomContraint.constant = 12
                }
                
            } else{
                //cell.txtDropDown.isHidden = false
                //cell.lblHours.isHidden = true
                
                if self.selectedSingerDetails?.services?[indexPath.row].max_hr_array?.count ?? 0 > 0 {
                    cell.lblDuration.isHidden = false
                    cell.txtDropDown.isHidden = false
                    cell.lblHours.isHidden = true
                    cell.txtDropDownHeight.constant = 35
                    cell.bottomContraint.constant = 20
                } else {
                    cell.lblDuration.isHidden = true
                    cell.txtDropDown.isHidden = true
                    cell.lblHours.isHidden = true
                    cell.txtDropDownHeight.constant = 0
                    cell.bottomContraint.constant = 12
                }
                
                let x : Int = self.selectedSingerDetails?.services?[indexPath.row].id ?? 0
                let stringValue = "\(x)"
                
                let filterdSection = self.singer_ServicesWithHour.first(where: {$0.service_id == stringValue})
                
                
                cell.txtDropDown.optionArray = dictionary//["Option 1", "Option 2", "Option 3"]
                cell.txtDropDown.borderWidth = 2
                cell.txtDropDown.borderColor = Colors.snomoTransparant
                cell.txtDropDown.cornerRadius = 8
                cell.txtDropDown.backgroundColor = .clear
                cell.txtDropDown.textColor = .white
                cell.txtDropDown.arrowColor = Colors.snomoTransparant
                cell.txtDropDown.isSearchEnable = false
                cell.txtDropDown.text = filterdSection?.title ?? dictionary.first
                cell.txtDropDown.checkMarkEnabled = false
                cell.txtDropDown.selectedRowColor = .white//Colors.snomoTransparant
                cell.txtDropDown.checkMarkEnabled = true
                cell.txtDropDown.selectedIndex = 0
                
                
                let xnew : Int = self.selectedSingerDetails?.services?[indexPath.row].total_service_amount ?? 0
                let stringValuenew = "\(xnew) \(SelectedCurrency.shared.currentAppCurrency)"
                
                let selectedServiceNode : Int = self.selectedSingerDetails?.services?[indexPath.row].id ?? 0
                let serviceStringValue = "\(selectedServiceNode)"
                
                let selectedServiceNodeNew = self.singer_ServicesWithHour.first(where: {$0.service_id == serviceStringValue})
       
                
//                self.getTotalAmountFromAPI(singer_id: self.selectedSingerDetails?.id, service_id: x , service_hrs: selectedServiceNodeNew?.hrs) { issucess in
//                    if issucess {
//                        cell.lblPrice.text = "\(self.servicesAmountObj?.data!.total_service_amount ?? xnew) \(SelectedCurrency.shared.currentAppCurrency)"
//                    }
//
//                 }
                
//                let priceNew = self.calculatePrice(defaultTime: self.selectedSingerDetails?.services?[indexPath.row].min_hr ?? "00:00:00" , selectedTime: selectedServiceNodeNew?.hrs, additional_hour_price: self.selectedSingerDetails?.services?[indexPath.row].additional_hour_price, price: self.selectedSingerDetails?.services?[indexPath.row].total_service_amount)
//
//                cell.lblPrice.text = priceNew ?? stringValuenew
            
            }
            
            // After selection
            // The the Closure returns Selected Index and String
            // Current Aj
            cell.txtDropDown.didSelect{(selectedText , index ,id) in
                if self.selectedSingerDetails?.multiple_service_booking == 0 {
                    self.singer_ServicesWithHour.removeAll()
                    let filterdSection = self.selectedSingerDetails?.services?[indexPath.row].max_hr_array?.filter({$0.title == selectedText})
                    print("Selected String: \(selectedText) \n index: \(index) \n indexPath: \(indexPath.row)")
                    var obj = singer_Services()
                    let x : Int = self.selectedSingerDetails?.services?[indexPath.row].id ?? 0
                    let stringValue = "\(x)"
                    obj.service_id = stringValue
                    obj.hrs = filterdSection?.first?.value//selectedText
                    obj.title = filterdSection?.first?.title
                    self.singer_ServicesWithHour.append(obj)
                    
//                    let selectedValue = Double(filterdSection?[0].value ?? "0")
//                    let minValue = Double(self.selectedSingerDetails?.services?[indexPath.row].min_hr ?? "0")
//
//                    var difference =  selectedValue - minValue
                    
                   self.getTotalAmountFromAPI(singer_id: self.selectedSingerDetails?.id, service_id: x , service_hrs: filterdSection?.first?.value) { issucess in
                       if issucess {
                           cell.lblPrice.text = "\(self.servicesAmountObj?.data!.total_service_amount ?? 0) \(SelectedCurrency.shared.currentAppCurrency)"//priceNew
                       }
                       
                    }
                    
                  
                   // let priceNew = self.calculatePrice(defaultTime: self.selectedSingerDetails?.services?[indexPath.row].min_hr ?? "00:00:00" , selectedTime: filterdSection?.first?.value , additional_hour_price: self.selectedSingerDetails?.services?[indexPath.row].additional_hour_price, price: self.selectedSingerDetails?.services?[indexPath.row].total_service_amount)
                    
                    
                    
                    
                    
                } else{
                    
                    // let indexPath = tableView.indexPath(for: cell)! as IndexPath
                    
                    let dataToUpdate = self.selectedSingerDetails?.services?[indexPath.row].max_hr_array?.filter({$0.title == selectedText})
                    
                    let musicinsDetails = self.selectedSingerDetails?.services?[indexPath.row]
                    
                    let intID: String? = String(musicinsDetails?.id ?? 0)
                    
                    var fileteredSection = self.singer_ServicesWithHour.filter({$0.service_id == intID})
                    
                    if fileteredSection.count > 0 {
                        self.singer_ServicesWithHour.removeAll(where: {$0.service_id == intID})
                        self.singer_ServicesWithHour.append(singer_Services(service_id: intID, hrs: dataToUpdate?.first?.value, title: dataToUpdate?.first?.value))
                        //fileteredSection[0].hrs = dataToUpdate[0].value
                    } else {
                        
                    }
                    
                    let service_id_is : Int = self.selectedSingerDetails?.services?[indexPath.row].id ?? 0
                    
                    self.getTotalAmountFromAPI(singer_id: self.selectedSingerDetails?.id, service_id: service_id_is , service_hrs: dataToUpdate?.first?.value) { issucess in
                        if issucess {
                            cell.lblPrice.text = "\(self.servicesAmountObj?.data!.total_service_amount ?? 0) \(SelectedCurrency.shared.currentAppCurrency)"//priceNew
                        }
                        
                     }
                    
                }
                
                
                
            }
            
            if self.selectedSingerDetails?.services?.count == 1{
                
                cell.btnBook.isHidden = true
                cell.imgSelectedStatus.isHidden = true
                
                if selectedSingerDetails?.multiple_service_booking == 0 {
                    let rowsCount = self.tableView.numberOfRows(inSection: indexPath.section)
                    let serviceDetails = self.selectedSingerDetails?.services?[indexPath.row]
                    if let service = serviceDetails {
                        self.selectedServicesData.removeAll()
                        self.selectedServicesData.append(service)
                    }
                    
                   // self.tableView.reloadData()
                    
                    // Before selection data should be set
                    self.singer_ServicesWithHour.removeAll()
                    
                    let serviceDetailsData = self.selectedSingerDetails?.services?[indexPath.row]
                    
                    if serviceDetailsData?.charge_type == 1 {
                        
                        let value : Int = self.selectedSingerDetails?.services?[indexPath.row].id ?? 0
                        // crash
                        //self.singer_ServicesWithHour.append(singer_Services(service_id: "\(value)", hrs: serviceDetailsData?.max_hr, title:""))
                        
                        // Condition changes if charge type is 1 then send "00:00:00"
                        
                        self.singer_ServicesWithHour.append(singer_Services(service_id: "\(value)", hrs: "00:00:00", title:""))
                        
                    } else{
                        
                        let filterdSection = self.selectedSingerDetails?.services?[indexPath.row].max_hr_array?.filter({$0.title == cell.txtDropDown.text})
                        let value : Int = self.selectedSingerDetails?.services?[indexPath.row].id ?? 0
                        self.singer_ServicesWithHour.append(singer_Services(service_id: "\(value)", hrs: filterdSection?.first?.value, title:filterdSection?.first?.title ))
                    }
                } else{
                    
                    let selectedService = self.selectedSingerDetails?.services?[indexPath.row]
                    let fileteredService = self.selectedServicesData.filter({$0.id == selectedService?.id})
                    
                    let intID: String? = String(selectedService?.id ?? 0)
                    
                    if fileteredService.count > 0 {
                        self.selectedServicesData.removeAll(where: {$0.id == selectedService?.id})
                        cell.imgSelectedStatus.isHighlighted = !cell.imgSelectedStatus.isHighlighted
                        
                        self.singer_ServicesWithHour.removeAll(where: {$0.service_id == intID})
                        
                    } else {
                        let serviceDetails = self.selectedSingerDetails?.services?[indexPath.row]
                        if let getService = serviceDetails {
                            self.selectedServicesData.removeAll(where: {$0.id == serviceDetails?.id})
                            self.selectedServicesData.append(getService)
                            cell.imgSelectedStatus.isHighlighted = !cell.imgSelectedStatus.isHighlighted
                            
                            if serviceDetails?.charge_type == 1 {
                                
                                let value : Int = self.selectedSingerDetails?.services?[indexPath.row].id ?? 0
                                // crash
                               // self.singer_ServicesWithHour.append(singer_Services(service_id: "\(value)", hrs: serviceDetails?.max_hr, title:""))
                                
                                // Condition changes if charge type is 1 then send "00:00:00"
                                
                                self.singer_ServicesWithHour.append(singer_Services(service_id: "\(value)", hrs: "00:00:00", title:""))
                                
                                
                            } else{
                                let filterdSection = self.selectedSingerDetails?.services?[indexPath.row].max_hr_array?.filter({$0.title == cell.txtDropDown.text})
                                let value : Int = self.selectedSingerDetails?.services?[indexPath.row].id ?? 0
                                // crash
                                self.singer_ServicesWithHour.append(singer_Services(service_id: "\(value)", hrs: filterdSection?.first?.value, title:filterdSection?.first?.title))
                                
                            }
                            
                            
                        }
                    }
                }
                
            } else{
                cell.btnBook.isHidden = false
                cell.imgSelectedStatus.isHidden = false
            }
            
            
            
            return cell
        }
        else if indexPath.section == 3 {
            let footerView = self.tableView.dequeueReusableCell(withIdentifier: "CommonButton", for: indexPath) as! CommonButton
            footerView.btnNext.setTitle(Localized("next").uppercased(), for: .normal)
            
            //footerView.bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.40)
            if objMultipleSinger != nil {
                footerView.btnNext.setTitle(Localized("Select Singer").uppercased(), for: .normal)
            }
            else {
//                footerView.btnNext.setTitle(Localized("bookNow").uppercased(), for: .normal)
                
                //Wedding
                if parentCatObj?.id == 21
                {
                     footerView.btnNext.setTitle(Localized("Send a Request").uppercased(), for: .normal)
                 }
                else {
                    footerView.btnNext.setTitle(Localized("bookNow").uppercased(), for: .normal)
                 }
            }
            footerView.onTapNextAction = {
                
                if self.parentCatObj?.id == 21
                {
//                    if self.selectedServicesData.count > 0 {
//                        self.showActionSheet()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.mainViewPopup.isHidden = false
                    }
                            
                    self.mainSubPopup.slideIn(from: kFTAnimationBottom, in: self.mainSubPopup.superview, duration: 0.3, delegate: self, start: Selector("temp"), stop: Selector("temp"))
                    
//                    }
//                    else
//                    {
//                        self.showAlert(title: Localized("alert"), message: Localized("PleaseSelectService")) {
//                            
//                        }
//                    }
                }
                else
                {
                    if self.selectedServicesData.count > 0 {
                        DispatchQueue.main.async {
                            //isPlaying = false
                            
                            if SamratGlobal.loggedInUser()?.user == nil {
                                let loginVc = LoginViewController.object()
                                loginVc.isNeedtobackToScreen = true
                                self.fadeTo(loginVc)
                            }else {
                                if self.objMultipleSinger != nil {
                                    if let maxSinger = self.settingsResponse?.settings?.max_singer_selection,
                                       self.objMultipleSinger?.selectedSinger.count ?? 0 >= Int(maxSinger) ?? 2 {
                                        self.view.makeToast(Localized("Maximum singers selected"))
                                        return
                                    }
                                    self.objMultipleSinger?.selectedSinger.append((self.selectedSingerDetails)!)
                                    self.view.endEditing(true)
                                    self.navigationController?.popViewController(animated: true)
                                }
                                else {
                                    
                                    if self.categoriesDetails?.id == 28 || self.categoriesDetails?.id == 24 || self.categoriesDetails?.id == 29 {
                                        let bookNowVc = BookNowWothCalendarVCBottom()
                                        bookNowVc.selectedSinger = self.selectedSingerDetails
                                        bookNowVc.selectedServicesData = self.selectedServicesData
                                        bookNowVc.parentCatObj = self.parentCatObj
                                        bookNowVc.singer_ServicesWithHour = self.singer_ServicesWithHour
                                        bookNowVc.categoriesDetails = self.categoriesDetails
                                        self.fadeTo(bookNowVc)
                                    } else{
                                        let bookNowVc = BookNowWothCalendarVC()
                                        bookNowVc.selectedSinger = self.selectedSingerDetails
                                        bookNowVc.selectedServicesData = self.selectedServicesData
                                        bookNowVc.parentCatObj = self.parentCatObj
                                        bookNowVc.singer_ServicesWithHour = self.singer_ServicesWithHour
                                        bookNowVc.categoriesDetails = self.categoriesDetails
                                        self.fadeTo(bookNowVc)
                                    }

    //
    //                                let bookNowVc = BookNowWothCalendarVC()
    //                                bookNowVc.selectedSinger = self.selectedSingerDetails
    //                                bookNowVc.selectedServicesData = self.selectedServicesData
    //                                bookNowVc.singer_ServicesWithHour = self.singer_ServicesWithHour
    //                                bookNowVc.parentCatObj = self.parentCatObj
    //                                bookNowVc.categoriesDetails = self.categoriesDetails
    //                                self.fadeTo(bookNowVc)
                                    
                                }
                            }
                            
                        }
                    } else{
                        
                        self.showAlert(title: Localized("alert"), message: Localized("PleaseSelectService")) {
                            
                        }
                    }

                }
                    
                
                                
                
                
            }
            return footerView
            
        }
        else {
            return UITableViewCell()
        }
        
    }
   
    func showActionSheet() {
        let actionSheet = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
        
        // Add actions
        let optionOne = UIAlertAction(title:Localized("WhatsApp"), style: .default) { _ in
            print("Option 1 selected")
            
            self.openWithWhatsapp()
        }
        optionOne.setValue(UIColor(red: 204/255, green: 138/255, blue: 109/255, alpha: 1), forKey: "titleTextColor")

        let optionTwo = UIAlertAction(title: Localized("email"), style: .default) { _ in
            print("Option 2 selected")
            self.openWithEmail()
        }
        optionTwo.setValue(UIColor(red: 204/255, green: 138/255, blue: 109/255, alpha: 1), forKey: "titleTextColor")

        let cancelAction = UIAlertAction(title: Localized("Cancel"), style: .cancel)
        cancelAction.setValue(UIColor(red: 204/255, green: 138/255, blue: 109/255, alpha: 1), forKey: "titleTextColor")

        
        // Add actions to the sheet
        actionSheet.addAction(optionOne)
        actionSheet.addAction(optionTwo)
        actionSheet.addAction(cancelAction)
        
        if let firstSubview = actionSheet.view.subviews.first,
           let alertContentView = firstSubview.subviews.first {
            alertContentView.backgroundColor = UIColor(red: 226/255, green: 218/255, blue: 207/255, alpha: 1)
            alertContentView.layer.cornerRadius = 20
        }
        
        // For iPad compatibility (to prevent crashes)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX,
                                                  y: self.view.bounds.midY,
                                                  width: 0,
                                                  height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        // Present the ActionSheet
        present(actionSheet, animated: true, completion: nil)
    }
    
    func openWithWhatsapp() {
        
//        let phoneNumber = CategoriesModel.shared.settingResponse?.settings?.whatsapp_number ?? ""
//        
//        let phoneNumber = "+917096859504"
//        
//        var servicesList = ""
//        for service in self.selectedServicesData {
//            servicesList += "• \(service.title ?? "") \n  - \(service.description ?? "")\n\n"
//        }
//        
//            let message = """
//            Hello Samrat Team,
//            
//            I am interested in booking the following:
//            
//            Singer: \(self.selectedSingerDetails?.name ?? "")
//            
//            Selected Packages:
//            \(servicesList)
//            Please let us know the next steps to proceed with the booking.
//            """
//            let urlString = "https://wa.me/\(phoneNumber)?text=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
//            
//            if let whatsappURL = URL(string: urlString), UIApplication.shared.canOpenURL(whatsappURL) {
//                UIApplication.shared.open(whatsappURL)
//            } else {
//                print("WhatsApp not installed or invalid URL")
//            }
        
        
        let phoneNumber = CategoriesModel.shared.settingResponse?.settings?.whatsapp_number ?? ""
        
        var message = ""
        
        if Language.shared.isArabic == true
        {
            message = """
    مرحبا… 
    أنا مهتم بحجز الفنان \(self.selectedSingerDetails?.name ?? "")
"""
        }
        else
        {
            message = "Hello, \nI am interested to book \(self.selectedSingerDetails?.name ?? "")"
        }
        
        
         let urlString = "https://wa.me/\(phoneNumber)?text=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let whatsappURL = URL(string: urlString), UIApplication.shared.canOpenURL(whatsappURL) {
            UIApplication.shared.open(whatsappURL)
        } else {
            print("WhatsApp not installed or invalid URL")
        }
        
    }
    
    func openWithEmail() {
        
        let email = CategoriesModel.shared.settingResponse?.settings?.email ?? ""
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            // Set recipient email
            mail.setToRecipients([email])  // <-- replace with actual
            
            // Set subject
            mail.setSubject("Booking Inquiry")
            
            // Build full email message body
            var message = ""
            
            if Language.shared.isArabic == true
            {
                message = """
        مرحبا… 
        أنا مهتم بحجز الفنان \(self.selectedSingerDetails?.name ?? "")
    """
            }
            else
            {
                message = "Hello, \nI am interested to book \(self.selectedSingerDetails?.name ?? "")"
            }
            
            // Set message body
            mail.setMessageBody(message, isHTML: false)
            
            // Present mail composer
            present(mail, animated: true)
            
        } else {
            print("Mail services are not available")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? MusiciansServiceTVCell else {
                return
        }
        // Here we're checking if your cell is the last one
        if indexPath.row == tableView.numberOfRows(inSection: 2) - 1 {
            // if true -> then hide it
            cell.lblLineView.backgroundColor = .clear
        }
    }
    
    
    func getTotalAmountFromAPI(singer_id:Int?, service_id: Int?, service_hrs:String?, completion: @escaping (Bool) -> ()) {
        
        let selectedCountry = getSelectedCountry()
        let parameter = [
            "singer_id" : singer_id ?? 0,
            "service_id":service_id ?? 0,
            "service_hrs":service_hrs ?? "",
            "country_id": selectedCountry?.id ?? 0
        ] as [String : Any]

        
        APIManager.handler.PostRequest(url: ApiUrl.serviceAmount, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    self.servicesAmountObj = try? JSONDecoder().decode(servicesAmtObj.self, from: data)
                    print(self.servicesAmountObj ?? "Empty")
                    if self.servicesAmountObj?.status == true {
                        completion(true)
                        
                    }else {
                        completion(false)
                        self.showAlert(title: Localized("alert"), message: self.servicesAmountObj?.message ?? Localized("somethingWentWrong"))
                    }
                    
                }catch (let error) {
                    JSN.log("getTotalAmountFromAPI error ====>%@", error)
                }
                
                break
            case .failure(let error):
                JSN.log("getTotalAmountFromAPI failur error login api ===>%@", error)
                break
            }
            
        }
//        return "\(self.servicesAmountObj?.data?.total_service_amount ?? 0)"
    }
    
    
    func calculatePrice(defaultTime: String, selectedTime:String?, additional_hour_price:Int?, price:Int?) -> String{
        
        
        let timeFormatter =  DateFormatter()
        timeFormatter.dateFormat = "hh:mm:ss"
        
        guard let time1 = timeFormatter.date(from: selectedTime ?? "00:00:00"),
              let time2 = timeFormatter.date(from: defaultTime) else { return ""  }
        
        
        let dateDiff =  time1.timeIntervalSince(time2)
        let hour = dateDiff / 3600;
        //let minute = dateDiff.truncatingRemainder(dividingBy: 3600) / 60
        //let intervalInt = Int(dateDiff)
        
        
        let selectedTimeComponents = selectedTime?.components(separatedBy: ":")
        let defaultTimeComponents = defaultTime.components(separatedBy: ":")
        
        var selectedTimeComponentINT = Int(selectedTimeComponents?.first ?? "0") ?? 0
        var defaultTimeComponentsINT = Int(defaultTimeComponents.first ?? "0") ?? 0
        
        var diffrenceOfTimeIs = Double(selectedTimeComponentINT) - Double(defaultTimeComponentsINT)
        
                                                             
        let multiplyValue =  (additional_hour_price ?? 0) * (Int(diffrenceOfTimeIs))
        
        let finalValueToDisplay = (multiplyValue) + (price ?? 0)
        
        print("****")
        print("defaultTime:", defaultTime)
        print("selectedTime:", selectedTime)
       // self.tableView.reloadData()
        //cell.lblPrice.text = "\(finalValueToDisplay) KD"
        return "\(finalValueToDisplay) \(SelectedCurrency.shared.currentAppCurrency)"
        
    }
    
    @IBAction func btnBookNowNextTapped(_ sender: UIButton){
        
        
        
        DispatchQueue.main.async {
            //isPlaying = false
            
            if SamratGlobal.loggedInUser()?.user == nil {
                let loginVc = LoginViewController.object()
                loginVc.isNeedtobackToScreen = true
                self.fadeTo(loginVc)
            }else {
                
                if self.categoriesDetails?.id == 28 || self.categoriesDetails?.id == 24 || self.categoriesDetails?.id == 29 {
                    let bookNowVc = BookNowWothCalendarVCBottom()
                    bookNowVc.selectedSinger = self.selectedSingerDetails
                    bookNowVc.selectedServicesData = self.selectedServicesData
                    bookNowVc.parentCatObj = self.parentCatObj
                    bookNowVc.singer_ServicesWithHour = self.singer_ServicesWithHour
                    bookNowVc.categoriesDetails = self.categoriesDetails
                    self.fadeTo(bookNowVc)
                } else{
                    let bookNowVc = BookNowWothCalendarVC()
                    bookNowVc.selectedSinger = self.selectedSingerDetails
                    bookNowVc.selectedServicesData = self.selectedServicesData
                    bookNowVc.parentCatObj = self.parentCatObj
                    bookNowVc.singer_ServicesWithHour = self.singer_ServicesWithHour
                    bookNowVc.categoriesDetails = self.categoriesDetails
                    self.fadeTo(bookNowVc)
                }

//
//                let bookNowVc = BookNowWothCalendarVC()
//                bookNowVc.selectedSinger = self.selectedSingerDetails
//                bookNowVc.selectedServicesData = self.selectedServicesData
//                bookNowVc.parentCatObj = self.parentCatObj
//                bookNowVc.singer_ServicesWithHour = self.singer_ServicesWithHour
//                bookNowVc.categoriesDetails = self.categoriesDetails
//                self.fadeTo(bookNowVc)
                
                
            }
            
        }
        
    }
    
    @IBAction func btnBookTapped(_ sender: UIButton){
        
      
        if let cell : MusiciansServiceTVCell = sender.superview?.superview?.superview?.superview as? MusiciansServiceTVCell {
            let indexPath = tableView.indexPath(for: cell)! as IndexPath
            
            let singerDetails = self.selectedSingerDetails?.services?[indexPath.row]
            
            if selectedSingerDetails?.multiple_service_booking == 0 {
                let rowsCount = self.tableView.numberOfRows(inSection: indexPath.section)
                let serviceDetails = self.selectedSingerDetails?.services?[indexPath.row]
                if let service = serviceDetails {
                    self.selectedServicesData.removeAll()
                    self.selectedServicesData.append(service)
                }
                
                self.tableView.reloadData()
                
                // Before selection data should be set
                self.singer_ServicesWithHour.removeAll()
                
                let serviceDetailsData = self.selectedSingerDetails?.services?[indexPath.row]
                
                if serviceDetailsData?.charge_type == 1 {
                    
                    let value : Int = self.selectedSingerDetails?.services?[indexPath.row].id ?? 0
                    // crash
                    //self.singer_ServicesWithHour.append(singer_Services(service_id: "\(value)", hrs: serviceDetailsData?.max_hr, title:""))
                    
                    // Condition changes if charge type is 1 then send "00:00:00"
                    
                    self.singer_ServicesWithHour.append(singer_Services(service_id: "\(value)", hrs: "00:00:00", title:""))
                    
                } else{
                    
                    let filterdSection = self.selectedSingerDetails?.services?[indexPath.row].max_hr_array?.filter({$0.title == cell.txtDropDown.text})
                    let value : Int = self.selectedSingerDetails?.services?[indexPath.row].id ?? 0
                    self.singer_ServicesWithHour.append(singer_Services(service_id: "\(value)", hrs: filterdSection?.first?.value, title:filterdSection?.first?.title ))
                }
            } else{
                
                let indexPath = tableView.indexPath(for: cell)! as IndexPath
                let selectedService = self.selectedSingerDetails?.services?[indexPath.row]
                let fileteredService = self.selectedServicesData.filter({$0.id == selectedService?.id})
                
                let intID: String? = String(selectedService?.id ?? 0)
                
                if fileteredService.count > 0 {
                    self.selectedServicesData.removeAll(where: {$0.id == selectedService?.id})
                    cell.imgSelectedStatus.isHighlighted = !cell.imgSelectedStatus.isHighlighted
                    
                    self.singer_ServicesWithHour.removeAll(where: {$0.service_id == intID})
                    
                } else {
                    let serviceDetails = self.selectedSingerDetails?.services?[indexPath.row]
                    if let getService = serviceDetails {
                        self.selectedServicesData.removeAll(where: {$0.id == serviceDetails?.id})
                        self.selectedServicesData.append(getService)
                        cell.imgSelectedStatus.isHighlighted = !cell.imgSelectedStatus.isHighlighted
                        
                        if serviceDetails?.charge_type == 1 {
                            
                            let value : Int = self.selectedSingerDetails?.services?[indexPath.row].id ?? 0
                            // crash
                           // self.singer_ServicesWithHour.append(singer_Services(service_id: "\(value)", hrs: serviceDetails?.max_hr, title:""))
                            
                            // Condition changes if charge type is 1 then send "00:00:00"
                            
                            self.singer_ServicesWithHour.append(singer_Services(service_id: "\(value)", hrs: "00:00:00", title:""))
                            
                            
                        } else{
                            let filterdSection = self.selectedSingerDetails?.services?[indexPath.row].max_hr_array?.filter({$0.title == cell.txtDropDown.text})
                            let value : Int = self.selectedSingerDetails?.services?[indexPath.row].id ?? 0
                            // crash
                            self.singer_ServicesWithHour.append(singer_Services(service_id: "\(value)", hrs: filterdSection?.first?.value, title:filterdSection?.first?.title))
                            
                        }
                        
                        
                    }
                }
            }
            
            
            
        } else {
            print("not click")
        }
    }
    
}
