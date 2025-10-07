//
//  CatSingerListVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 03/05/21.
//

import UIKit
import VACalendar
import Toast_Swift
class CatSingerListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet var viewBG : UIImageView!
    @IBOutlet var segmentOutlet: UISegmentedControl!
    @IBOutlet var segmentControl : HBSegmentedControl!
    @IBOutlet var tableView: UITableView!{
        didSet {
            tableView.register(UINib.init(nibName: "SingerTVCell", bundle: nil), forCellReuseIdentifier: "SingerTVCell")
        }
    }
    
    @IBOutlet var lblNoDataFound: UILabel!

    @IBOutlet weak var calendarDateView: UIView!
    @IBOutlet var btnBookNow: UIButton!
    @IBOutlet var calanderContainView: UIView!
    @IBOutlet var lblBookingDate: UILabel!
    
    @IBOutlet weak var viewWA: UIView!
    var selectedSinger:singersData? = nil
    var parentCatObj:CategoriesData? = nil
    
    let defaultCalendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        //calendar.locale = Language.shared.isArabic ? Locale(identifier: "ar_KW") : Locale(identifier: "en_GB")
        return calendar
    }()
    
    var calendarView: VACalendarView!
    var selectedBookingDate : Date?
    
    
    @IBOutlet weak var weekDaysView: VAWeekDaysView! {
        didSet {
            let appereance = VAWeekDaysViewAppearance(symbolsType: .short, weekDayTextColor: .black, calendar: defaultCalendar)
            weekDaysView.appearance = appereance
        }
    }
    
    @IBOutlet weak var monthHeaderView: VAMonthHeaderView!{
        didSet {
            let dateFormate = DateFormatter()
            dateFormate.dateFormat = "LLLL"
            let appereance = VAMonthHeaderViewAppearance(
                previousButtonImage: UIImage.init(named: "left-arrow")!,
                nextButtonImage: UIImage.init(named: "right-arrow")!,
                dateFormatter: dateFormate
            )
            monthHeaderView.delegate = self
            monthHeaderView.appearance = appereance
        }
    }
    
    var categoriesDetails: CategoriesData? = nil
    var singerObjBasedOnCat: singersObj? = nil
    var settingsResponse: SettingResponse? = nil
    var dateArray:[Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
        
        print("Aj print:- ", self.categoriesDetails?.id)
//        self.title = Localized("singersList").uppercased() //"SINGERS"
        calendarDateView.isHidden = true
        self.tableView.isHidden = false
        AppConstant.shared.firstTimeCat = false
        self.title = self.categoriesDetails?.name?.uppercased() ?? ""
        
        if self.parentCatObj?.id == 21 {
            self.viewBG.image = UIImage(named: "wedding_cat_bg")
        } else if self.parentCatObj?.id == 23{
            //self.viewBG.image = UIImage(named: "band_cat_bg")
            
            if self.categoriesDetails?.id == 24 {
                self.viewBG.image = UIImage(named: "SAMRAT_MYACCOUNT")
                
            }else if self.categoriesDetails?.id == 29 {
                self.viewBG.image = UIImage(named: "SUB_WESTERN_BAND")
            } else if self.categoriesDetails?.id == 28 {
                self.viewBG.image = UIImage(named: "band_yemeni_singers")
            } else if self.categoriesDetails?.id == 27 {
                self.viewBG.image = UIImage(named: "band_traditinal_singers")
            } else{
                self.viewBG.image = UIImage(named: "band_other_singers")
            }
            
        } else if self.parentCatObj?.id == 30 {
            self.viewBG.image = UIImage(named: "DSC00701")
        } else{
            
        }
        
        
       
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        self.btnBookNow.setTitle(Localized("next").uppercased(), for: .normal)
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "SAMRAT_CATBG") ?? UIImage())
        self.tableView.backgroundColor = UIColor.clear

        self.tableView.delegate = self
        self.tableView.dataSource = self

//        self.segmentOutlet.isHidden = true
        self.segmentControl.isHidden = true
        self.lblBookingDate.text = Localized("bookingDate")
        self.segmentOutlet.setTitle(Localized("Single Singer"), forSegmentAt: 0)
        self.segmentOutlet.setTitle(Localized("Multiple Singers"), forSegmentAt: 1)
        self.segmentOutlet.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        
        //Custom Segment Class
        segmentControl.items = [Localized("Single Singer"), Localized("Multiple Singers")]
        segmentControl.font = UIFont.systemFont(ofSize: 14)
        segmentControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segmentControl.selectedIndex = 0
        segmentControl.padding = 0
        
        segmentControl.addTarget(self, action: #selector(self.onSegmentValueChange(_:)), for: .valueChanged)
        //MARK: CALENDAR VIEW SETUP
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyy"
        
        let startDate = Date()
        
        var dateComponent = DateComponents()
        let futureDate = Calendar.current.date(byAdding: .year, value: 2, to: startDate)
        
        let cal = Calendar.current
        let compo = cal.dateComponents([.year, .month], from: Date())
        let startOfMonth = cal.date(from: compo)! as Date
       
        print(startOfMonth)
        
        let calendar = VACalendar(
            startDate: startDate,
            endDate: futureDate,
            selectedDate: Date(),
            calendar: defaultCalendar)
        
        calendarView = VACalendarView(frame: .zero, calendar: calendar)
        calendarView.showDaysOut = true
        calendarView.selectionStyle = .single
        calendarView.monthDelegate = monthHeaderView
        calendarView.dayViewAppearanceDelegate = self
        calendarView.monthViewAppearanceDelegate = self
        calendarView.calendarDelegate = self
        calendarView.scrollDirection = .horizontal
        calendarView.isScrollEnabled = false
        //Restrict Date
        
        let endavailables = futureDate!
        
        let components = Calendar.current.dateComponents([.day], from: startDate, to: endavailables)
        let numberOfDays = components.day ?? 0
        let dates = (0...numberOfDays).compactMap {
            return Calendar.current.date(byAdding: .day, value: $0, to: startDate)
        }
        
        let availability = DaysAvailability.some(dates)
        calendarView.setAvailableDates(availability)
        self.calanderContainView.addSubview(self.calendarView)
        self.calanderContainView.addSubview(calendarView)
        self.monthHeaderView.backgroundColor = #colorLiteral(red: 0.8430671096, green: 0.5282273293, blue: 0.3670781851, alpha: 0.5) //Colors.snomoTransparant
        
//        calendarView.translatesAutoresizingMaskIntoConstraints = false
//        calendarView.leftAnchor.constraint(equalTo: calanderContainView.leftAnchor).isActive = true
//        calendarView.rightAnchor.constraint(equalTo: calanderContainView.rightAnchor).isActive = true
//        calendarView.topAnchor.constraint(equalTo: calanderContainView.topAnchor).isActive = true
//        calendarView.bottomAnchor.constraint(equalTo: calanderContainView.bottomAnchor).isActive = true
//
//        calendarView.setup()
        
        if singerObjBasedOnCat?.data == nil {
            if (self.categoriesDetails?.id) != nil {
                updateTableContentInset()
                self.apiGetSingerListBasedOnCategories()
            }
            self.apiGetSettingDetails()
        } else {
//            if CategoriesModel.shared.settingResponse?.settings?.multiple_singer_booking == "1" {
//                self.segmentOutlet.isHidden = false
//                self.segmentControl.isHidden = false
//            }
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
    
    @IBAction func viewWA(_ sender: Any) {
        print("Button Tapped")
        
        if let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=\(CategoriesModel.shared.settingResponse?.settings?.whatsapp_number ?? "")&text=") {
            
            if UIApplication.shared.canOpenURL(whatsappURL) {
                UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        appDelegate.isFromBackPaymentScreen = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if segmentControl.selectedIndex == 1 {
            if calendarView.frame == .zero {
                calendarView.frame = CGRect(
                    x: self.calanderContainView.bounds.origin.x,
                    y: self.calanderContainView.bounds.origin.y,
                    width: self.calanderContainView.bounds.width,
                    height: self.calanderContainView.bounds.height)
                calendarView.setup()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    //MARK:- Contact US API Calling
    fileprivate func apiGetSettingDetails() {
        APIManager.handler.GetRequest(url: ApiUrl.settings, isLoader: false, header: nil, controller: self) { (result) in
            switch result {
            case .success(let data):
                do {
                    if let getDara = data {
                        self.settingsResponse = try JSONDecoder().decode(SettingResponse.self, from: getDara)
                        CategoriesModel.shared.settingResponse = try JSONDecoder().decode(SettingResponse.self, from: getDara)
                        if self.settingsResponse?.status == true {
//                            if self.settingsResponse?.settings?.multiple_singer_booking == "1" {
//                                self.segmentOutlet.isHidden = false
//                                self.segmentControl.isHidden = false
//                                //self.tableView.isHidden = true
//                                //self.calendarDateView.isHidden = false
//                            }
                        } else {
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
                                
                            
                           
                        }
                        //self.tableView.reloadData()
                    }
                } catch (let error) {
                    JSN.log("login uer ====>%@", error)
                }
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
            }
        }
    }
    
    //MARK:- API GET BOOKINGS
    func apiGetBookingLists(curentDate: Date = Date()) {
        
        let selectedCountry = getSelectedCountry()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let dateString : String = dateFormatter.string(from: curentDate)
        print(dateString)
        
        let parameter = [
            "page" : "1",
            "type":"1",
            "device_type":deviceType,
            "singer_id": selectedSinger?.id ?? 0,
            "country_id": selectedCountry?.id ?? 0,
            "date": "\(dateString)"
        ] as [String : Any]
        
        self.calendarView.selectDates([])
        self.selectedBookingDate = nil
        
        DispatchQueue.asyncAfter(deadline: 0.01) {
            ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        }
        APIManager.handler.PostRequest(url: ApiUrl.getBokkingsDates, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else { return }
                    let getBookingObj = try JSONDecoder().decode(BookingResObj.self, from: data)
                    if getBookingObj.status == true {
                        self.dateArray.removeAll()
                        if (getBookingObj.data) != nil {
                            var supl: [(Date, [VADaySupplementary])] = []
                            for i in 0..<(getBookingObj.data?.count)! {
                                let obj = (getBookingObj.data?[i])!
                                if obj.booking_date != nil {
                                    print(obj.booking_date as Any)
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                                    let dateobj = dateFormatter.date(from: (obj.booking_date)!)
                                    if dateobj != nil {
                                        print(dateFormatter.string(from: dateobj!))
                                        self.dateArray.append(dateobj!)
                                        supl.append(((dateobj)!,[VADaySupplementary.bottomDots([.blue])]))
                                    }
                                }
                            }
                            
                            dateFormatter.dateFormat = "yyyy-MM"
                            let dttt : String = dateFormatter.string(from: Date())
                            if dttt == dateString {
                                let forrrr = DateFormatter(locale: .current, dateFormat: "yyyy-MM-dd")
                                forrrr.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                                let dt2 = forrrr.string(from: Date().addingTimeInterval(24*60*60))
                                var newDt = forrrr.date(from: dt2)!
                                var intVal = 30
                                
                                while intVal > 1 {
                                    let curdttt: String = DateFormatter(locale: .current, dateFormat: "dd").string(from: newDt)
                                    intVal = Int(curdttt) ?? 0
                                    if !self.dateArray.contains(newDt) {
                                        print(newDt)
                                        self.dateArray.append(newDt)
                                        supl.append((newDt, [VADaySupplementary.bottomDots([.blue])]))
                                    }
                                    newDt = newDt.addingTimeInterval(-24*60*60)
                                }
                            }
                            
                            if self.dateArray.count > 0 {
                                DispatchQueue.main.async {
                                    self.calendarView.setSupplementaries(supl)
                                    //self.calendarView.selectDates(self.dateArray)
                                }
                            }
//                            dateFormatter.dateFormat = "yyyy-MM-dd"
//                            let dates = self.dateArray.map({dateFormatter.string(from: $0)})
//                            let curDt = dateFormatter.string(from: Date())
//
//                            if !dates.contains(curDt) && dttt == dateString {
//                                self.calendarView.selectDates([Date()])
//                                self.selectedDate(Date())
//                            }
                        } else {
                            self.showAlert(title: Localized("alert"), message: getBookingObj.message ?? Localized("somethingWentWrong"))
                        }
                    } else {
                        self.showAlert(title: Localized("alert"), message: getBookingObj.message ?? Localized("somethingWentWrong"))
                    }
                } catch (let error) {
                    JSN.log("login uer ====>%@", error)
                }
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
            }
        }
    }
    
    //MARK: BUTTON ACTIONS
    @IBAction func onNext(_ sender: UIButton) {
        if selectedBookingDate == nil {
            //showToastMessage(strMessage: msgSelectDate)
            //self.view.makeToast(Localized("Please select Date"))
            self.showAlert(title: Localized("alert"), message: Localized("Please select Date")) {
              }
//            let str = "To confirm the reservation, an amount of 50 KD must be paid, which will be returned in case of disagreement. \n \u{2022} In case of cancelation , we must be notified at least 24 hours before the concert, \n and there will be a 5% deduction of the total amount. \n \u{2022} An SMS message will be sent within 24 hours to confirm your order, with a link to pay the full amount."
//                showThemeAlert(msgTitle: alertTitle, msg: str) { issucess in
//                    print(issucess)
//                }
            return
        }
        let vc = MultipleSingerVC()
        vc.getSelectedDate = self.selectedBookingDate
        vc.categoriesDetails = self.categoriesDetails
        vc.settingsResponse = self.settingsResponse
        vc.parentCatObj = self.parentCatObj
        fadeTo(vc)
    }
    
    @objc func menuClick(_ sender:UIButton) {
        self.view.endEditing(true)
        fadeFrom()
    }

    @IBAction func onSegmentValueChange(_ sender: AnyObject) {
        if sender.tag == 99, let hb = sender as? HBSegmentedControl {
            if hb.selectedIndex == 0 {
                UIView.transition(with: self.calendarDateView, duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.calendarDateView.isHidden = true
                                  })
                UIView.transition(with: self.tableView, duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.tableView.isHidden = false
                              })
            } else {
                self.segmentControl.selectedIndex = 1
                self.segmentOutlet.selectedSegmentIndex = 1
//                self.segmentControl.isHidden = false
//                self.calendarDateView.isHidden = false
//                self.tableView.isHidden = true
//
                UIView.transition(with: self.segmentControl, duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.segmentControl.isHidden = false
                                  })
                UIView.transition(with: self.calendarDateView, duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.calendarDateView.isHidden = false
                              })
                UIView.transition(with: self.tableView, duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.tableView.isHidden = true
                              })
                self.apiGetBookingLists()
            }
        } else {
            if segmentControl.selectedIndex == 0 {
                UIView.transition(with: self.segmentControl, duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.segmentControl.isHidden = true
                                  })
                UIView.transition(with: self.calendarDateView, duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.calendarDateView.isHidden = true
                              })
                UIView.transition(with: self.tableView, duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.tableView.isHidden = false
                                    self.tableView.reloadData()
                              })
//                self.calendarDateView.isHidden = true
//                self.tableView.isHidden = false
//                self.segmentControl.isHidden = true
            }else{
                UIView.transition(with: self.calendarDateView, duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.calendarDateView.isHidden = false
                                  })
                UIView.transition(with: self.tableView, duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.tableView.isHidden = true
                              })
//                self.calendarDateView.isHidden = false
//                self.tableView.isHidden = true
                self.apiGetBookingLists()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y <= 0.0 {
            self.viewBG.removeBlurToView()
        } else {
            let blur = (scrollView.contentOffset.y / 100);
            self.viewBG.addBlurToView(val: blur)
        }
    }
    
    //MARK:- Tableview delegate and datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.singerObjBasedOnCat?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SingerTVCell", for: indexPath) as! SingerTVCell
        let singerDetails = self.singerObjBasedOnCat?.data?[indexPath.row]
        cell.lblTitle.text = singerDetails?.name
        cell.lblDecription.text = singerDetails?.description
        cell.lblDecription.numberOfLines = 4
        let readmoreFont = UIFont.systemFont(ofSize: 11)//UIFont(name: "Helvetica-Oblique", size: 11.0)
        let readmoreFontColor = UIColor.init(hexString: "CC8A65")! //UIColor.blue
        DispatchQueue.main.async {
            
            let numberOfLinesMax = cell.lblDecription.maxNumberOfLines
            
            if numberOfLinesMax > 3 {
                cell.lblDecription.addTrailing(with: "... ", moreText: Localized("Read More"), moreTextFont: readmoreFont, moreTextColor: readmoreFontColor)
            } else{
                //cell.lblDecription.addTrailing(with: "... ", moreText: Localized("Read More"), moreTextFont: readmoreFont, moreTextColor: readmoreFontColor)
            }
            
            
        }
        
        cell.setImage(str: singerDetails?.image)
        cell.btnBook.addTarget(self, action: #selector(btnBookTapped(_:)), for: .touchUpInside)
        cell.btnBook.tag = indexPath.row
        cell.btnBook.setTitle(Localized("bookNow"), for: .normal)
//        cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1)
        return cell
    }
    
    @IBAction func btnBookTapped(_ sender: UIButton){
//        let vc = MusiciansDetailsViewController.object()
        
        if self.singerObjBasedOnCat?.data?[sender.tag].services?.count == 0 {
            let vc = MusiciansDetailsViewController.object()
            vc.selectedSingerDetails = self.singerObjBasedOnCat?.data?[sender.tag]
            vc.parentCatObj = self.parentCatObj
            vc.categoriesDetails = self.categoriesDetails
            fadeTo(vc)
        } else{
            let vc = MusiciansDetailViewController.object()
            vc.selectedSingerDetails = self.singerObjBasedOnCat?.data?[sender.tag]
            //vc.selectedSingerDetails?.services?[0].priceNew = self.singerObjBasedOnCat?.data?[sender.tag].services?[0].price
            vc.parentCatObj = self.parentCatObj
            vc.categoriesDetails = self.categoriesDetails
            fadeTo(vc)
        }
        
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let vc = MusiciansDetailsViewController.object()
        if self.singerObjBasedOnCat?.data?[indexPath.row].services?.count == 0 {
            let vc = MusiciansDetailsViewController.object()
            vc.selectedSingerDetails = self.singerObjBasedOnCat?.data?[indexPath.row]
            vc.categoriesDetails = self.categoriesDetails
            vc.parentCatObj = self.parentCatObj
            fadeTo(vc)
        } else{
            let vc = MusiciansDetailViewController.object()
            vc.selectedSingerDetails = self.singerObjBasedOnCat?.data?[indexPath.row]
           // vc.selectedSingerDetails?.services?[0].priceNew = self.singerObjBasedOnCat?.data?[indexPath.row].services?[0].price
            vc.parentCatObj = self.parentCatObj
            vc.categoriesDetails = self.categoriesDetails
            fadeTo(vc)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.frame.height * 0.5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        
        let seg = HBSegmentedControl(frame: CGRect(x: (tableView.frame.width / 2) - 125, y: tableView.frame.height * 0.5 - 40, width: 250, height: 40))
        
        let out = UISegmentedControl()
        out.insertSegment(withTitle: Localized("Single Singer"), at: 0, animated: true)
        out.insertSegment(withTitle: Localized("Multiple Singers"), at: 1, animated: true)
        out.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        
        
        if (self.singerObjBasedOnCat?.data?.count ?? 0) <= 0
        {
            view.isHidden = true
        }
        else
        {
            view.isHidden = false
        }
        
        
        //Custom Segment Class
        seg.items = [Localized("Single Singer"), Localized("Multiple Singers")]
        seg.font = UIFont.systemFont(ofSize: 14)
        seg.borderColor = UIColor(white: 1.0, alpha: 0.3)
        seg.selectedIndex = 0
        seg.padding = 0
        seg.addTarget(self, action: #selector(self.onSegmentValueChange(_:)), for: .valueChanged)
        out.addTarget(self, action: #selector(self.onSegmentValueChange(_:)), for: .valueChanged)
        seg.tag = 99
        out.tag = 99
        seg.addSubview(out)
        view.addSubview(seg)
        
        seg.isHidden = true
        out.isHidden = true
        
            // Previous login now below added new flow and logic
//        if CategoriesModel.shared.settingResponse?.settings?.multiple_singer_booking == "1" {
//            seg.isHidden = false
//            out.isHidden = false
//        }
        // Code added by AJ - IF no data then not required
        if self.singerObjBasedOnCat?.data?.count == 0{
            seg.isHidden = true
            out.isHidden = true
        }
        
        // Hide show segment control
        if self.categoriesDetails?.allow_multiple_singer_bookings == 1 {
            seg.isHidden = false
            out.isHidden = false
        } else{
            seg.isHidden = true
            out.isHidden = true
        }
        
        
        return view
    }
    
    func updateTableContentInset() {
//        let numRows = self.tableView.numberOfRows(inSection: 0)
//        var contentInsetTop = self.tableView.bounds.size.height
//        for i in 0..<numRows {
//            let rowRect = self.tableView.rectForRow(at: IndexPath(item: i, section: 0))
//            contentInsetTop -= rowRect.size.height
//            if contentInsetTop <= 0 {
//                contentInsetTop = 0
//                break
//            }
//        }
//        self.tableView.contentInset = UIEdgeInsets(top: contentInsetTop,left: 0,bottom: 0,right: 0)
        
//        self.tableView.transform = CGAffineTransform (scaleX: 1,y: -1)
//        tableView.setContentOffset(.zero, animated: true)
    }
    
    //MARK:- Get singer list based on categories
    func apiGetSingerListBasedOnCategories() {
//        SVProgressHUD.show()
        
       
        var parameter = [
            "category_id" : "\(self.categoriesDetails?.id ?? 0)",
            "device_type":deviceType
        ] as [String : Any]
        
        let selectedCountry = getSelectedCountry()
        if selectedCountry != nil {
            parameter["country_id"] = selectedCountry?.id
        }
        
        if AppConstant.shared.firstTimeCat{
            ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        }
        
        APIManager.handler.PostRequest(url: ApiUrl.singer, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
//            SVProgressHUD.dismiss()
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    JSN.log("create booking api reasponse ==>%@", String(data: data, encoding: .utf8))
                    
                    self.singerObjBasedOnCat = try? JSONDecoder().decode(singersObj.self, from: data)
                    
                    if self.singerObjBasedOnCat?.status == true {
                        if (self.singerObjBasedOnCat?.data?.count ?? 0) <= 0 {
                            self.lblNoDataFound.text = Localized("noDataFound")
                            self.lblNoDataFound.isHidden = false
                            self.tableView.separatorColor = UIColor.clear
                            self.tableView.isHidden = true
                        }else {
                            self.lblNoDataFound.isHidden = true
                            self.tableView.isHidden = false
                        }
                        self.tableView.reloadData()
                        self.updateTableContentInset()

                    }else {
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
}

extension CatSingerListVC: VADayViewAppearanceDelegate {
    
    func textColor(for state: VADayState) -> UIColor {
        switch state {
        case .out:
            return .lightGray//UIColor(red: 214 / 255, green: 214 / 255, blue: 219 / 255, alpha: 1.0)
        case .selected:
            return .white
        case .unavailable:
            return .lightGray
        default:
            return .white
        }
    }
    
    func textBackgroundColor(for state: VADayState) -> UIColor {
        switch state {
        case .selected:
            return UIColor.init(hexString: "CC8A65")! //theamColor
        default:
            return .clear
        }
    }
    
    func shape() -> VADayShape {
        return .square
    }
    
    func dotBottomVerticalOffset(for state: VADayState) -> CGFloat {
        switch state {
        case .selected:
            return 2
        default:
            return -7
        }
    }
}

extension CatSingerListVC: VAMonthViewAppearanceDelegate {
    
    func leftInset() -> CGFloat {
        return 10.0
    }
    
    func rightInset() -> CGFloat {
        return 10.0
    }
    
    func verticalMonthTitleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    func verticalMonthTitleColor() -> UIColor {
        return .black
    }
    
    func verticalCurrentMonthTitleColor() -> UIColor {
        return .red
    }
}

extension CatSingerListVC: VAMonthHeaderViewDelegate {
    func currentmonthdate(date: Date) {
        print(date)
        self.apiGetBookingLists(curentDate: date)
    }
    
    func didTapNextMonth() {
        calendarView.nextMonth()
    }
    
    func didTapPreviousMonth() {
        calendarView.previousMonth()
    }
}

extension CatSingerListVC : VACalendarMonthDelegate {
    func monthDidChange(_ currentMonth: Date) {
        print(currentMonth)
        self.apiGetBookingLists(curentDate: currentMonth)
    }
}

extension CatSingerListVC: VACalendarViewDelegate {
    
    func selectedMsg(_ msg: String) {
        if msg == "false" {
            selectedBookingDate = nil
            self.view.makeToast(Localized("wrong selection"))
        }
    }
    
    func selectedDates(_ dates: [Date]) {
        if (dates.last ?? Date()) >= Date() {
            
                        //calendarView.startDate = dates.last ?? Date()
            //            calendarView.selectDates([dates.last ?? Date()])
            selectedBookingDate = dates.last ?? Date()
            print("found data")
        }else {
            print("false")
            //            calendarView.startDate =  Date()
            //            selectedBookingDate = Date()
        }
        JSN.log("selected date ===>%@", (dates.last ?? Date()) > Date())
        // self.navigationController?.popViewController(animated: true)
    }
    
    func selectedDate(_ date: Date) {
        JSN.log("selected date ===>%@", date)
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let strdt :String = dateFormatter.string(from: date)
        print(strdt)
        let dt : Date = dateFormatter.date(from: strdt)!
        
        let strcurrent :String = dateFormatter.string(from: Date())
        print(strcurrent)
        let currentdt :Date = dateFormatter.date(from: strcurrent)!
        
        if dt < currentdt {
            self.view.makeToast(Localized("wrong selection"))
            return
        }
        if dt >= currentdt {
            selectedBookingDate = date
            print("if")
        } else {
            print("else")
        }
    }
}


extension UILabel {
    var numberOfVisibleLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let textHeight = sizeThatFits(maxSize).height
        let lineHeight = font.lineHeight
        return Int(ceil(textHeight / lineHeight))
    }
    
    var maxNumberOfLines: Int {
           let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
           let text = (self.text ?? "") as NSString
           let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).height
           let lineHeight = font.lineHeight
           return Int(ceil(textHeight / lineHeight))
       }
}

extension UILabel {

        func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
            let readMoreText: String = trailingText + moreText

            let lengthForVisibleString: Int = self.vissibleTextLength
            let mutableString: String = self.text!
            let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
            let readMoreLength: Int = (readMoreText.count)
            let trimmedForReadMore: String = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
            let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font])
            let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
            
            
            let textRange = NSMakeRange(0, moreText.count)
                  //  let attributedText = NSMutableAttributedString(string: text)
            readMoreAttributed.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
                    // Add other attributes if needed
            
            answerAttributed.append(readMoreAttributed)
            self.attributedText = answerAttributed
        }

        var vissibleTextLength: Int {
            let font: UIFont = self.font
            let mode: NSLineBreakMode = self.lineBreakMode
            let labelWidth: CGFloat = self.frame.size.width
            let labelHeight: CGFloat = self.frame.size.height
            let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)

            let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
            let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedString.Key : Any])
            let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)

            if boundingRect.size.height > labelHeight {
                var index: Int = 0
                var prev: Int = 0
                let characterSet = CharacterSet.whitespacesAndNewlines
                repeat {
                    prev = index
                    if mode == NSLineBreakMode.byCharWrapping {
                        index += 1
                    } else {
                        index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                    }
                } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
                return prev
            }
            return self.text!.count
        }
    }
