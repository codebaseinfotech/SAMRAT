//
//  MUSICIANSVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 27/04/21.
//

import UIKit

class MUSICIANSVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AlertViewDelegate {
    func okayButtonTapped() {
        
    }
    
    func cancleButtonTapped() {
        
    }
    
    @IBOutlet var lblNoDataFound: UILabel!
    @IBOutlet var viewBG: UIImageView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            //MARK:- Tableview Header class init
            tableView.register(UINib.init(nibName: "MusicianListHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "MusicianListHeaderCell")
            //MARK:- Tableview Cell init
            tableView.register(UINib.init(nibName: "MusiciansTVCell", bundle: nil), forCellReuseIdentifier: "MusiciansTVCell")
            //MARK:- Tableview Footer view init
            tableView.register(UINib.init(nibName: "MusiciansTVFooter", bundle: nil), forHeaderFooterViewReuseIdentifier: "MusiciansTVFooter")
        }
    }
    
    @IBOutlet weak var viewWA: UIView!
    
    
    var selectedMusician:[musiciansDetails] = []
    var selectedSinger:singersData? = nil
    var getSelectedDate:Date? = nil
    var musicanObj:musicianRespoObj? = nil
    var selectedSingers:[singersData] = []
    var isFromMultiple = false
    var isSelectedDefault: Bool = false
    var categoriesDetails: CategoriesData? = nil
    var parentCatObj:CategoriesData? = nil
    
    var isNoData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
        
        print("Aj print:- ", self.categoriesDetails?.id)
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        self.apiGetMusician()
        
        self.title = Localized("musicians").uppercased() //"MUSICIAN"
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: Localized("done"), style: .done, target: self, action: #selector(onLinePayment(_:)))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y <= 0.0 {
            self.viewBG.removeBlurToView()
        } else {
            let blur = (scrollView.contentOffset.y / 100);
            self.viewBG.addBlurToView(val: blur)
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
    
    @objc func menuClick(_ sender:UIButton) {
        self.view.endEditing(true)
        fadeFrom()
    }
    @IBAction func clickedWA(_ sender: Any) {
        print("Button Tapped")
        
        if let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=\(CategoriesModel.shared.settingResponse?.settings?.whatsapp_number ?? "")&text=") {
            
            if UIApplication.shared.canOpenURL(whatsappURL) {
                UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func onTapChnageTab(_ sender: UISegmentedControl) {
//        let type = (sender.selectedSegmentIndex + 1)
//        self.apiGetBookingLists()
        
        isSelectedDefault = !isSelectedDefault
        
        if isSelectedDefault == false
        {
            if self.musicanObj?.status == true {
                if (self.musicanObj?.data?.count ?? 0) <= 0 {
                    self.isNoData = true
                    self.lblNoDataFound.text = Localized("noDataFound")
                    self.showAlert(title: Localized("alert"), message: Localized("noDataFound")) {
                    }
                }
            }
        }
        
        tableView.isScrollEnabled = !isSelectedDefault
        UIView.transition(with: tableView, duration: 1.0,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.tableView.reloadData()
        }, completion: nil)
//        self.lblNoDataFound.isHidden = true
//        if (self.upcomingResObj.count <= 0) && self.bookingType == 1 {
//            self.apiGetBookingLists()
//        }else if (self.previousResObj.count <= 0) && self.bookingType == 2 {
//            self.apiGetBookingLists()
//        }
//        self.tableView.reloadData()
    }
    
    //MARK:- Tableview delegate and datasource
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if self.isSelectedDefault == false
        {
            if self.isNoData == true
            {
                return 1
            }
            else
            {
                return isSelectedDefault ? 1 : self.musicanObj?.data?.count ?? 0
            }
        }
        else
        {
            return isSelectedDefault ? 1 : self.musicanObj?.data?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.isSelectedDefault == false
        {
            if self.isNoData == true
            {
                return 0
            }
            else
            {
                return isSelectedDefault ? 0 : self.musicanObj?.data?[section].musicians?.count ?? 0

            }
        }
        else
        {
            return isSelectedDefault ? 0 : self.musicanObj?.data?[section].musicians?.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MusiciansTVCell", for: indexPath) as! MusiciansTVCell
        let musicinsDetails = self.musicanObj?.data?[indexPath.section].musicians?[indexPath.row]
        let filterdSection = self.selectedMusician.filter({$0.musician_category_id == musicinsDetails?.musician_category_id ?? 0})
        if filterdSection.count > 0 {
            cell.imgSelectedStatus.isHighlighted = (filterdSection.contains(where: {$0.id == musicinsDetails?.id}))
        } else {
            cell.imgSelectedStatus.isHighlighted = false
        }
        cell.btnMoreInfo.isHidden = true
        cell.lblMusicianName.text = musicinsDetails?.name ?? ""
        cell.lblMusicanDesc.text = musicinsDetails?.description ?? ""
        cell.setImage(str: musicinsDetails?.image)
        cell.btnBook.addTarget(self, action: #selector(btnBookTapped(_:)), for: .touchUpInside)
        cell.btnBook.layer.name = "\(indexPath.section),\(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "MusicianListHeader") as! MusicianListHeader
//        let musicanDetails = self.musicanObj?.data?[section]
//        headerView.lblTitle.text = musicanDetails?.name ?? ""
//        headerView.lblChoose.text = musicanDetails?.description ?? ""
//        return headerView
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MusicianListHeaderCell") as! MusicianListHeaderCell
        let rect = CGRect(x: headerView.bounds.origin.x, y: headerView.bounds.origin.y + 350, width: headerView.bounds.width, height: headerView.bounds.height + 350)
        headerView.backView.isHidden = isSelectedDefault
        headerView.lblTitle.isHidden = isSelectedDefault
        headerView.lblChoose.isHidden = isSelectedDefault
        headerView.backView.layer.cornerRadius = 20
        if Language.shared.isArabic {
            headerView.backView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        if section == 0 {
            headerView.backgroundView = UIView(frame: rect)
            headerView.segmentControl.isHidden = false
            
            if getSelectedCountry()?.country == "Kuwait" || getSelectedCountry()?.country == "Kuwait ar"
            {
                if categoriesDetails?.id == 1
                {
                    headerView.lblDefaultSelected.text = "\n\n\n\n\(Localized("SAMRAT Musician"))"
                    headerView.alrandiImageView.isHidden = true
                    headerView.alrandiImageView.isHidden = true
                }
                else
                {
                    headerView.lblDefaultSelected.text = selectedSinger?.id == 25 ? Localized("Yousef AlOmani") : Localized("Default Musician")
                    headerView.alrandiImageView.isHidden = false
                    headerView.alrandiImageView.isHidden = !isSelectedDefault
                }
            }
            else
            {
                if categoriesDetails?.id == 1
                {
                    headerView.lblDefaultSelected.text = "\n\n\n\n\(Localized("SAMRAT Musician"))"
                    headerView.alrandiImageView.isHidden = true
                    headerView.alrandiImageView.isHidden = true
                }
                else
                {
                    headerView.lblDefaultSelected.text = selectedSinger?.id == 25 ? Localized("Yousef AlOmani") : Localized("Default Musician")
                    headerView.alrandiImageView.isHidden = false
                    headerView.alrandiImageView.isHidden = !isSelectedDefault
                }
            }
            
            if (self.musicanObj?.data?.count ?? 0) == 0
            {
                headerView.segmentControl.items = [Localized("chooseDefault")]
                headerView.segmentControl.selectedIndex = 0

            }
            else
            {
                headerView.segmentControl.items = [Localized("chooseCustom"), Localized("chooseDefault")]
                headerView.segmentControl.selectedIndex = isSelectedDefault ? 1 : 0
            }

            headerView.alrandiMainContainView.isHidden = false
            headerView.lblDefaultSelected.numberOfLines = 0
            headerView.alrandiMainContainView.isHidden = !isSelectedDefault
            headerView.lblDefaultSelected.isHidden = !isSelectedDefault
            headerView.backViewHeightConstrain.constant = (isSelectedDefault == true) ? 0 : 40.0
            headerView.backViewTopConstrain.constant = (isSelectedDefault == true) ? 30 : 30.0
            headerView.segmentControl.removeTarget(self, action: #selector(onTapChnageTab(_:)), for: .valueChanged)
            headerView.segmentControl.addTarget(self, action: #selector(onTapChnageTab(_:)), for: .valueChanged)
            headerView.segmentControl.font = UIFont.systemFont(ofSize: 14)
            headerView.segmentControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
            headerView.segmentControl.padding = 0
        } else{
            headerView.backgroundView = UIView(frame: headerView.bounds)
            headerView.segmentControl.isHidden = true
            headerView.alrandiImageView.isHidden = true
            headerView.alrandiMainContainView.isHidden = true
            headerView.lblDefaultSelected.isHidden = true
        }
        
        if self.isSelectedDefault == false
        {
            if self.isNoData == true
            {
                headerView.backViewHeightConstrain.constant = 0
                headerView.backViewTopConstrain.constant = 30
                headerView.backView.isHidden = true
                headerView.lblTitle.isHidden = true
                headerView.lblChoose.isHidden = true
            }
        }
        
        headerView.backgroundView?.backgroundColor = UIColor.clear
        
        if self.musicanObj?.data?.count ?? 0 > 0 {
            let musicanDetails = self.musicanObj?.data?[section]
            headerView.lblTitle.text = musicanDetails?.name
            headerView.lblChoose.text = Language.shared.isArabic ?  (musicanDetails?.selection_label_ar ?? "") : (musicanDetails?.selection_label ?? "")
            
        }
        
//        if (musicanDetails?.min_selection ?? 0) == 0 && (musicanDetails?.max_selection ?? 0) == 0 {
//            headerView.lblChoose.text = Localized("Optional")
//        } else if (musicanDetails?.min_selection ?? 0) == (musicanDetails?.max_selection ?? 0) {
//            headerView.lblChoose.text = "\(Localized("Choose")) \(musicanDetails?.min_selection ?? 0)"
//        } else if (musicanDetails?.min_selection ?? 0) == 1 && (musicanDetails?.max_selection ?? 0) == 0 {
//            headerView.lblChoose.text = "No Limit"
//        } else if (musicanDetails?.min_selection ?? 0) == 1 && (musicanDetails?.max_selection ?? 0) > 0 {
//            headerView.lblChoose.text = "\(Localized("Max Musician Selected")) \(musicanDetails?.max_selection ?? 0)"
//        } else {
//            headerView.lblChoose.isHidden = true
//        }
       
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.setSelection(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return isSelectedDefault ? tableView.frame.height * 0.89 : tableView.frame.height * 0.5
        } else {
            return 60.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isSelectedDefault {
            return 60
        }
        return ((((self.musicanObj?.data?.count ?? 0)) - 1) == section) ? 60 : 0
//        return 60.0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if ((self.musicanObj?.data?.count ?? 0) - 1) == section || isSelectedDefault {
            let footerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "MusiciansTVFooter") as! MusiciansTVFooter
            footerView.btnNext.setTitle(Localized("next").uppercased(), for: .normal)
            footerView.onTapNextAction = {
                DispatchQueue.main.async {
                    var musician: musiciansObj?
                    self.musicanObj?.data?.reversed().forEach({ musiciansObj in
                        let sameMusicians = self.selectedMusician.filter({$0.musician_category_id == musiciansObj.id}).count
                        if let min_selection = musiciansObj.min_selection,
                           min_selection > 0,
                           sameMusicians < min_selection {
                            musician = musiciansObj
                        }
                    })
                    if musician != nil && !self.isSelectedDefault {
                        self.showMinAlert(min: musician?.min_selection ?? 0, name: musician?.name)
                    } else if self.selectedMusician.count == 0 && !self.isSelectedDefault {
                        AlertView.instance.showAlert(title: Localized("alert"), message: NSAttributedString(string: Localized("pSelectMusician")), alertType: .oneButton)
                        AlertView.instance.alertViewDelegate = self
                    } else {
                        
                        var isFromCus = false
                        
                        if self.isSelectedDefault == true
                        {
                            isFromCus = false
                        }
                        else
                        {
                            isFromCus = true
                        }
                        
                        if getSelectedCountry()?.country == "Kuwait" || getSelectedCountry()?.country == "Kuwait ar"
                        {
                            if self.categoriesDetails?.id == 1
                            {
                                let selectBandVc = SelectBandViewController.object()
                                selectBandVc.isFromCustom = isFromCus
                                selectBandVc.selectedSinger = self.selectedSinger
                                selectBandVc.geSelectedDate = self.getSelectedDate
                                selectBandVc.categoriesDetails = self.categoriesDetails
                                selectBandVc.parentCatObj = self.parentCatObj
                                selectBandVc.isSelectedDefault = self.isSelectedDefault
                                selectBandVc.getSelectedMusician = self.selectedMusician
                                self.fadeTo(selectBandVc)

                            }
                            else
                            {
                                
                                var musicianIds = ""
                                if self.isSelectedDefault == false {
                                    
                                    musicianIds = self.selectedMusician.map({"\($0.id ?? 0)"}).joined(separator: ",")
                                    
                                    if (self.selectedMusician.count ?? 0) == 0
                                    {
                                        if (self.selectedSinger?.musicians?.count ?? 0) > 0
                                        {
                                            musicianIds = (self.selectedSinger?.musicians?.map({"\($0.id ?? 0)"}) ?? []).joined(separator: ",")
                                        }
                                    }
                                    
                                } else {
                                    musicianIds = (self.selectedSinger?.musicians?.map({"\($0.id ?? 0)"}) ?? []).joined(separator: ",")
                                }
                                
                                if musicianIds == ""
                                {
                                    AlertView.instance.showAlert(title: Localized("alert"), message: NSAttributedString(string: Localized("pSelectMusicianfield")), alertType: .oneButton)
                                    AlertView.instance.alertViewDelegate = self
                                }
                                else
                                {
                                    
                                    let onlinePaymentVc = OnlinePaymentVC()
                                    onlinePaymentVc.isFromCustom = isFromCus
                                    onlinePaymentVc.isFromMultiple = self.isFromMultiple
                                    onlinePaymentVc.geSelectedDate = self.getSelectedDate
                                    onlinePaymentVc.selectedSinger = self.selectedSinger
                                    onlinePaymentVc.selectedSingers = self.selectedSingers
                                    onlinePaymentVc.categoriesDetails = self.categoriesDetails
                                    onlinePaymentVc.parentCatObj = self.parentCatObj
                                    onlinePaymentVc.getSelectedMusician = self.selectedMusician
                                    self.fadeTo(onlinePaymentVc)
                                }
                                
                            }
                        }
                        else
                        {
                            
                            var musicianIds = ""
                                    if self.isSelectedDefault == false {
                                        
                                        musicianIds = self.selectedMusician.map({"\($0.id ?? 0)"}).joined(separator: ",")
                                        
                                        if (self.selectedMusician.count ?? 0) == 0
                                        {
                                            if (self.selectedSinger?.musicians?.count ?? 0) > 0
                                            {
                                                musicianIds = (self.selectedSinger?.musicians?.map({"\($0.id ?? 0)"}) ?? []).joined(separator: ",")
                                            }
                                        }
                                        
                                    } else {
                                        musicianIds = (self.selectedSinger?.musicians?.map({"\($0.id ?? 0)"}) ?? []).joined(separator: ",")
                                    }
                            
                            if musicianIds == ""
                            {
                                AlertView.instance.showAlert(title: Localized("alert"), message: NSAttributedString(string: Localized("pSelectMusicianfield")), alertType: .oneButton)
                                AlertView.instance.alertViewDelegate = self
                            }
                            else
                            {
                                let onlinePaymentVc = OnlinePaymentVC()
                                onlinePaymentVc.isFromCustom = isFromCus
                                onlinePaymentVc.isFromMultiple = self.isFromMultiple
                                onlinePaymentVc.geSelectedDate = self.getSelectedDate
                                onlinePaymentVc.selectedSinger = self.selectedSinger
                                onlinePaymentVc.selectedSingers = self.selectedSingers
                                onlinePaymentVc.getSelectedMusician = self.selectedMusician
                                onlinePaymentVc.categoriesDetails = self.categoriesDetails
                                onlinePaymentVc.parentCatObj = self.parentCatObj
                                self.fadeTo(onlinePaymentVc)
                            }
                            
                           
                        }
                        
 
                        
                    }
                }
            }
            return footerView
        }else {
            return UIView()
        }
    }
    
    @IBAction func btnBookTapped(_ sender: UIButton) {
        if let name = sender.layer.name?.split(separator: ",") {
            setSelection(indexPath: IndexPath(row: Int(name.last ?? "0") ?? 0, section: Int(name.first ?? "0") ?? 0))
        }
    }
    
    func setSelection(indexPath: IndexPath) {
        let musicinsDetails = self.musicanObj?.data?[indexPath.section].musicians?[indexPath.row]
        let fileteredSection = self.selectedMusician.filter({$0.musician_category_id == musicinsDetails?.musician_category_id})
        
        if fileteredSection.contains(where: {$0.id == musicinsDetails?.id}) {
            self.selectedMusician.removeAll(where: {$0.id == musicinsDetails?.id})
            if let cell = tableView.cellForRow(at: indexPath) as? MusiciansTVCell {
                cell.imgSelectedStatus.isHighlighted = !cell.imgSelectedStatus.isHighlighted
            }
        } else if let max = musicanObj?.data?[indexPath.section].max_selection,
                  max > 0,
                  (fileteredSection.count) >= max {
            showMaxAlert(max: max, name: self.musicanObj?.data?[indexPath.section].name)
        }
//        else if let min = musicanObj?.data?[indexPath.section].min_selection,
//                  min > 0,
//                  (fileteredSection.count) < min {
//            showMaxAlert(max: min, name: self.musicanObj?.data?[indexPath.section].name)
//        }
        else if let getMusician = musicinsDetails {
            self.selectedMusician.append(getMusician)
            if let cell = tableView.cellForRow(at: indexPath) as? MusiciansTVCell {
                cell.imgSelectedStatus.isHighlighted = !cell.imgSelectedStatus.isHighlighted
            }
        }
    }
    
    func showMinAlert(min: Int, name: String?) {
        var str = "Select Minimum1";
        if min == 2 {
            str = "Select Minimum2";
        } else if min > 2 {
            str = "Select Minimum3";
        }
        
        let msg = Localized(str).replacingOccurrences(of: "%d", with: "\(min)").replacingOccurrences(of: "%s", with: "\(name ?? "")");
        AlertView.instance.showAlert(title: Localized("alert"), message: NSAttributedString(string: msg), alertType: .oneButton)
        AlertView.instance.alertViewDelegate = self
    }
    
    func showMaxAlert(max: Int, name: String?) {
        let msg = Localized("Choose upto Message").replacingOccurrences(of: "%d", with: "\(max)").replacingOccurrences(of: "%s", with: "\(name ?? "")");
        AlertView.instance.showAlert(title: Localized("alert"), message: NSAttributedString(string: msg), alertType: .oneButton)
        AlertView.instance.alertViewDelegate = self
    }
    
    //MARK:- API Get Musician List
    func apiGetMusician() {
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let dateobj = engToArb(str:dateFormatter.string(from: (getSelectedDate)!))
        let selectedCountry = getSelectedCountry()
        APIManager.handler.PostRequest(url: ApiUrl.getMusicians, params: ["user_id": SamratGlobal.loggedInUser()?.user?.id ?? 0,
                                                                          "device_type": deviceType,
                                                                          "singer_id": selectedSinger?.id ?? 0,
                                                                          "date": dateobj,
                                                                          "country_id": selectedCountry?.id ?? 0], isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
                switch result {
                case .success(let data):
                    do {
                        guard let data = data else {return}
                        JSN.log("Data printed ===>%@", String(data: data, encoding: .utf8))
                        self.musicanObj = try? JSONDecoder().decode(musicianRespoObj.self, from: data)

                       // if self.musicanObj?.status == true {
//                            if (self.musicanObj?.data?.count ?? 0) <= 0 {
//                                self.lblNoDataFound.text = Localized("noDataFound")
//                                self.lblNoDataFound.isHidden = false
//                                self.tableView.isHidden = true
//                            } else {
                                self.lblNoDataFound.isHidden = true
                                self.tableView.isHidden = false
                           // }
                            self.tableView.reloadData()
//                        } else {
//                            self.lblNoDataFound.isHidden = true
//                            //self.showAlert(title: Localized("alert"), message: UserModel.shared.objUser?.message ?? "Please check email & Password")
//                            self.showAlert(title: Localized("alert"), message: UserModel.shared.objUser?.message ?? Localized("somethingWentWrong"))
//                            //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
//                        }
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
}
