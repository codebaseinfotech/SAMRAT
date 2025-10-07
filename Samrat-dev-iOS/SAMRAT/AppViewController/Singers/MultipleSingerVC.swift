//
//  MultipleSingerVC.swift
//  SAMRAT
//
//  Created by Macmini on 10/08/21.
//

import UIKit

class MultipleSingerVC: UIViewController , UITableViewDelegate, UITableViewDataSource, AlertViewDelegate {
    
    @IBOutlet var viewBG: UIImageView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            //MARK:- Tableview Cell init
            tableView.register(UINib.init(nibName: "MusiciansTVCell", bundle: nil), forCellReuseIdentifier: "MusiciansTVCell")
            tableView.register(UINib.init(nibName: "MusiciansTVFooter", bundle: nil), forCellReuseIdentifier: "MusiciansTVFooter")
        }
    }
    
    @IBOutlet weak var viewWA: UIView!
    
    var parentCatObj:CategoriesData? = nil
    var getSelectedDate:Date? = nil
    var categoriesDetails:CategoriesData? = nil
    var singerObjBasedOnCat:singersObj? = nil
    var selectedSinger:[singersData] = []
    var selectedSingers:[singersData] = []
    var settingsResponse:SettingResponse? = nil
    var isDataFetched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
        
        print("Aj print:- ", self.categoriesDetails?.id)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        //self.apiGetMusician()
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
        if (self.categoriesDetails?.id) != nil {
            self.apiGetSingerListBasedOnCategories()
        }
        
        if self.parentCatObj?.id == 21 {
            self.viewBG.image = UIImage(named: "wedding_cat_bg")
        } else if self.parentCatObj?.id == 23{
            self.viewBG.image = UIImage(named: "band_cat_bg")
        } else{
            
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
    
    override func viewWillAppear(_ animated: Bool) {
        if self.selectedSinger.count > 0 {
            tableView.reloadData()
        }
    }

    //MARK:- Get singer list based on categories
    func apiGetSingerListBasedOnCategories() {
        
        
        var parameter = [
            "category_id" : "\(self.categoriesDetails?.id ?? 0)",
            "device_type": deviceType
        ] as [String : Any]
        
        if self.getSelectedDate != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            let dateobj = engToArb(str:dateFormatter.string(from: (getSelectedDate)!))
           parameter["booking_date"] = dateobj
        }
        
        let selectedCountry = getSelectedCountry()
        if selectedCountry != nil {
            parameter["country_id"] = selectedCountry?.id
        }
        
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.singer, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    self.singerObjBasedOnCat = try? JSONDecoder().decode(singersObj.self, from: data)
                    
                    if self.singerObjBasedOnCat?.status == true {
                        self.isDataFetched = true
                        self.tableView.reloadData()
                    } else {
                        self.showAlert(title: Localized("alert"), message: self.singerObjBasedOnCat?.message ?? Localized("somethingWentWrong"))
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
    
    //MARK: BUTTON ACTIONS
    @objc func menuClick(_ sender:UIButton) {
        self.view.endEditing(true)
        print(self.navigationController?.viewControllers)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.isFromCalender = true
        fadeFrom()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y <= 0.0{
            self.viewBG.removeBlurToView()
        } else {
            let blur = (scrollView.contentOffset.y / 100)
            self.viewBG.addBlurToView(val: blur)
        }
    }
    
    //MARK:- Tableview delegate and datasource
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.frame.height * 0.5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let height = tableView.frame.height * 0.5
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: height))
        view.backgroundColor = .clear
        
        let lbl = UILabel(frame: CGRect(x: tableView.frame.width / 2 - 75, y: height - 50, width: 150, height: 40))
        lbl.backgroundColor = hexStringToUIColor(hex: "#CC8A65")
        lbl.textColor = .white
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl.textAlignment = .center
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 20
        if getSelectedDate != nil {
            let dateformater = DateFormatter()
            dateformater.dateFormat = "dd MMM yyyy"
            lbl.text = engToArb(str:self.convertDateFormater(dateformater.string(from: getSelectedDate!), oriDateFormate: "dd MMM yyyy", requiredDateFormate: "dd MMM yyyy"))
        }
        view.addSubview(lbl)
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.singerObjBasedOnCat?.data?.count ?? 0 == 0 && isDataFetched {
            self.tableView.setEmptyMessage(Localized("noDataFound"))
        } else {
            self.tableView.restore()
        }
        return self.singerObjBasedOnCat?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension//135
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MusiciansTVCell", for: indexPath) as! MusiciansTVCell
        let musicinsDetails = self.singerObjBasedOnCat?.data?[indexPath.row]
        let filterdSection = self.selectedSinger.filter({$0.id == musicinsDetails?.id ?? 0})
        if filterdSection.count > 0 {
            cell.imgSelectedStatus.isHighlighted = (filterdSection.contains(where: {$0.id == musicinsDetails?.id}))
        } else {
            cell.imgSelectedStatus.isHighlighted = false
        }
        cell.btnMoreInfo.isHidden = false
        cell.lblMusicianName.text = musicinsDetails?.name ?? ""
        cell.lblMusicanDesc.text = musicinsDetails?.description ?? ""
        cell.setImage(str: musicinsDetails?.image)
        cell.btnBook.addTarget(self, action: #selector(btnBookTapped(_:)), for: .touchUpInside)
        cell.btnBook.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard isDataFetched else {
            return UIView()
        }
        
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 80)
        let btn = UIButton(frame: CGRect(x: (tableView.frame.width / 2) - 50, y: 20, width: 100, height: 40))
        btn.addTarget(self, action: #selector(btnNextTapped(sender:)), for: .touchUpInside)
        btn.backgroundColor = hexStringToUIColor(hex: "#CC8A65")
//        btn.setTitle(Localized("next"), for: .normal)
        btn.setTitle(Localized("bookNow"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 20
        view.addSubview(btn)
        return view
        
        //if self.singerObjBasedOnCat?.data?.isEmpty ?? false {
//            let footerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "MusiciansTVFooter") as! MusiciansTVFooter
//            footerView.btnNext.setTitle(Localized("bookNow").uppercased(), for: .normal)
//            footerView.onTapNextAction = {
//                DispatchQueue.main.async {
//                    if self.selectedSinger.count == 0 {
//                        AlertView.instance.showAlert(title: Localized("alert"), message: NSAttributedString(string: Localized("pSelectMusician")), alertType: .oneButton)
//                        AlertView.instance.alertViewDelegate = self
//                        return
//                    }
//
//                    let arrayString = [
//                        Localized("singerSelectAlert1"),
//                        Localized("singerSelectAlert2"),
//                        Localized("singerSelectAlert3")
//                    ]
//                    AlertView.instance.showAlert(title: Localized("termsAndConditions"), arrMessages: arrayString, alertType: .twoButton)
//                    AlertView.instance.alertViewDelegate = self
//                }
//            }
//            return footerView
//        } else {
//            return UIView()
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MusiciansDetailsViewController.object()
        vc.selectedSingerDetails = self.singerObjBasedOnCat?.data?[indexPath.row]
        vc.objMultipleSinger = self
        vc.settingsResponse = self.settingsResponse
        vc.categoriesDetails = self.categoriesDetails
        fadeTo(vc)
    }
    
    @objc func btnNextTapped(sender: UIButton) {
        if self.selectedSinger.count == 0 {
            AlertView.instance.showAlert(title: Localized("alert"), message: NSAttributedString(string: Localized("SelectSinger")), alertType: .oneButton)
            AlertView.instance.alertViewDelegate = self
            return
        }
        
        let vc = MultipleSingersMusicianbookVC()
        vc.selectedBookingDate = self.getSelectedDate
        vc.selectedSingers = self.selectedSinger
        vc.categoriesDetails = self.categoriesDetails
        vc.parentCatObj = self.parentCatObj
        vc.isSelectedDefault = true
        fadeTo(vc)
        
//        let arrayString = [
//            Localized("singerSelectAlert1"),
//            Localized("singerSelectAlert2"),
//            Localized("singerSelectAlert3")
//        ]
//        AlertView.instance.showAlert(title: Localized("termsAndConditions"), arrMessages: arrayString, alertType: .twoButton)
//        AlertView.instance.alertViewDelegate = self
    }
    
    @IBAction func btnBookTapped(_ sender: UIButton){
        if let cell : MusiciansTVCell = sender.superview?.superview?.superview?.superview as? MusiciansTVCell {
            let indexPath = tableView.indexPath(for: cell)! as IndexPath
            
            let musicinsDetails = self.singerObjBasedOnCat?.data?[indexPath.row]
            let fileteredSection = self.selectedSinger.filter({$0.id == musicinsDetails?.id})
            
            if fileteredSection.count > 0 {
                if fileteredSection.contains(where: {$0.id == musicinsDetails?.id}) {
                    self.selectedSinger.removeAll(where: {$0.id == musicinsDetails?.id})
                    cell.imgSelectedStatus.isHighlighted = !cell.imgSelectedStatus.isHighlighted
                } else {
                    if let maxSinger = self.settingsResponse?.settings?.max_singer_selection,
                          self.selectedSinger.count >= Int(maxSinger) ?? 2 {
                        self.view.makeToast(Localized("Maximum singers selected"))
                        return
                    }
                    if let getMusician = musicinsDetails {
                        self.selectedSinger.removeAll(where: {$0.id == musicinsDetails?.id})
                        self.selectedSinger.append(getMusician)
                        cell.imgSelectedStatus.isHighlighted = !cell.imgSelectedStatus.isHighlighted
                    }
                }
            } else {
                if let maxSinger = self.settingsResponse?.settings?.max_singer_selection,
                      self.selectedSinger.count >= Int(maxSinger) ?? 2 {
                    self.view.makeToast(Localized("Maximum singers selected"))
                    return
                }
                let musicinsDetails = self.singerObjBasedOnCat?.data?[indexPath.row]
                if let getMusician = musicinsDetails {
                    self.selectedSinger.removeAll(where: {$0.id == musicinsDetails?.id})
                    self.selectedSinger.append(getMusician)
                    cell.imgSelectedStatus.isHighlighted = !cell.imgSelectedStatus.isHighlighted
                }
            }
            //self.tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            print("not click")
        }
    }
    
    func okayButtonTapped() {
//        if self.selectedSinger.count == 0 {
//            return
//        }
//        let vc = MultipleSingersMusicianbookVC()
//        vc.selectedBookingDate = self.getSelectedDate
//        vc.selectedSingers = self.selectedSinger
//        fadeTo(vc)
    }
    
    func cancleButtonTapped() {
        
    }
}
