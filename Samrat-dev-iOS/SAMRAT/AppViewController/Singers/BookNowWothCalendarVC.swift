//
//  BookNowWothCalendarVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 28/04/21.
//

import UIKit
import VACalendar

class BookNowWothCalendarVC: UIViewController {
    
    
    
//    @IBOutlet var lblChooseCustom: UILabel!
    @IBOutlet weak var musicianImgView: UIImageView!
    @IBOutlet var segmentOutlet: UISegmentedControl!
//    @IBOutlet var lblChooseDefault: UILabel!
//    @IBOutlet var btnSelecMusicians: UIButton!waa
//    @IBOutlet var btnSelectType: UIButton!
    @IBOutlet var calanderContainView: UIView!
    @IBOutlet var backView: UIView!
    @IBOutlet var lblBookingDate: UILabel!
    
//    @IBOutlet var optionContainView: UIView!
    @IBOutlet var btnBookNow: UIButton!
    var isSelectedDefault:Bool = true
    @IBOutlet var segmentControl : HBSegmentedControl!
    @IBOutlet weak var viewWA: UIView!
    
    var selectedSinger:singersData? = nil
    var selectedServicesData:[servicesData] = []
    var categoriesDetails: CategoriesData? = nil
    var parentCatObj:CategoriesData? = nil
    
    var singer_ServicesWithHour:[singer_Services] = []
    
    let defaultCalendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
//        calendar.locale = Locale(identifier: "en_GB")
        calendar.locale = Language.shared.isArabic ? Locale(identifier: "ar_KW") : Locale(identifier: "en_GB")
        return calendar
    }()
    
    
    var calendarView: VACalendarView!
    var selectedBookingDate : Date?
    
    
    @IBOutlet weak var weekDaysView: VAWeekDaysView! {
        didSet {
            let appereance = VAWeekDaysViewAppearance(symbolsType: .short,weekDayTextColor: .black, calendar: defaultCalendar)
            weekDaysView.appearance = appereance
        }
    }
    
    @IBAction func onTapChnageTab(_ sender: UISegmentedControl) {
//        let type = (sender.selectedSegmentIndex + 1)
//        self.apiGetBookingLists()
        isSelectedDefault = !isSelectedDefault
//        self.lblNoDataFound.isHidden = true
//        if (self.upcomingResObj.count <= 0) && self.bookingType == 1 {
//            self.apiGetBookingLists()
//        }else if (self.previousResObj.count <= 0) && self.bookingType == 2 {
//            self.apiGetBookingLists()
//        }
//        self.tableView.reloadData()
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
    
    var dateArray:[Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Aj print:- ", self.categoriesDetails?.id)
        
        backView.layer.cornerRadius = 15
        
        //        self.imgCustom.isHighlighted = false
        //        self.imgDefault.isHighlighted = true
        
        //        let calendar = VACalendar(calendar: defaultCalendar)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyy"
        
        let startDate = Date()
        let futureDate = Calendar.current.date(byAdding: .year, value: 2, to: startDate)
        
        let cal = Calendar.current
        let compo = cal.dateComponents([.year, .month], from: Date())
        let startOfMonth = cal.date(from: compo)! as Date
       
        let calendar = VACalendar(
            startDate: startDate,
            endDate: futureDate,
            calendar: defaultCalendar
        )
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
//        calendarView.selectDates([Date()])
//        selectedDate(Date())
        
        self.calanderContainView.addSubview(calendarView)
        self.monthHeaderView.backgroundColor = #colorLiteral(red: 0.8430671096, green: 0.5282273293, blue: 0.3670781851, alpha: 0.5) //Colors.snomoTransparant
        
        //self.title = Localized("bookNow").uppercased() //"BOOK NOW"
        self.lblBookingDate.text = Localized("bookingDate")
//        self.btnSelecMusicians.setTitle(Localized("selectMusicians"), for: .normal)
//        self.btnSelecMusicians.sendActions(for: .touchUpInside)
//        self.lblChooseDefault.text = Localized("chooseDefault")
//        self.lblChooseDefault.font = UIFont.systemFont(ofSize: 14.0,weight: .bold)
        
//        self.lblChooseCustom.text = Localized("chooseCustom")
        
        self.segmentOutlet.setTitle(Localized("chooseDefault"), forSegmentAt: 0)
        self.segmentOutlet.setTitle(Localized("chooseCustom"), forSegmentAt: 1)
        self.segmentOutlet.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        
        //Custom Segment Class
        segmentControl.items = [Localized("chooseDefault"), Localized("chooseCustom")]
        segmentControl.font = UIFont.systemFont(ofSize: 14)
        segmentControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segmentControl.selectedIndex = 0
        segmentControl.padding = 0
        
        segmentControl.addTarget(self, action: #selector(self.segmentValueChanged(_:)), for: .valueChanged)
        
        
//        self.lblChooseCustom.font = UIFont.systemFont(ofSize: 14.0,weight: .regular)
        self.btnBookNow.setTitle(Localized("next").uppercased(), for: .normal)
        
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        self.apiGetBookingLists()
        
        //MARK:- Bg Image change logic
        if parentCatObj?.id ?? 0 == 7 {
            self.musicianImgView.image = UIImage.init(named: "wedding_booking_page_bg")
        }else {
            
        }
        
        if self.parentCatObj?.id == 21 {
            self.musicianImgView.image = UIImage.init(named: "wedding_booking_page_bg")
        } else if self.parentCatObj?.id == 23{
            
            if self.categoriesDetails?.id == 28{
                self.musicianImgView.image = UIImage(named: "band_yemeni_bands_calendar")
            }else if self.categoriesDetails?.id == 24{
                self.musicianImgView.image = UIImage(named: "band_arabic_takh_calendar")
            }else if self.categoriesDetails?.id == 29{
                self.musicianImgView.image = UIImage(named: "SUB_WESTERN_BAND")
            }else{
                self.musicianImgView.image = UIImage(named: "band_other_calendar")
            }
            
        } else{
            
        }
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
                viewWA.clipsToBounds = true
                
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                viewWA.addGestureRecognizer(panGesture)
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
        calendarView.nextMonth()
        calendarView.previousMonth()
        appDelegate.isFromBackPaymentScreen = false
    }
    
    @objc func segmentValueChanged(_ sender: AnyObject?){
        
        if segmentControl.selectedIndex == 0 {
            print(Localized("chooseDefault"))
        }else{
            print(Localized("chooseCustom"))
        }
        isSelectedDefault = !isSelectedDefault
    }
    
    @objc func menuClick(_ sender:UIButton) {
        self.view.endEditing(true)
        fadeFrom()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if calendarView.frame == .zero {
            
//            calendarView.translatesAutoresizingMaskIntoConstraints = false
//            calendarView.leftAnchor.constraint(equalTo: self.calanderContainView.leftAnchor).isActive = true
//            calendarView.rightAnchor.constraint(equalTo: self.calanderContainView.rightAnchor).isActive = true
//            calendarView.topAnchor.constraint(equalTo: self.calanderContainView.topAnchor).isActive = true
//            calendarView.bottomAnchor.constraint(equalTo: self.calanderContainView.bottomAnchor).isActive = true
            calendarView.frame = CGRect(
                x: self.calanderContainView.bounds.origin.x,
                y: self.calanderContainView.bounds.origin.y,
                width: UIScreen.main.bounds.width - 40,
                height: self.calanderContainView.bounds.height)
            calendarView.setup()
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onTapBookNowAction(_ sender: UIButton) {
    
        if selectedBookingDate == nil {
            //self.view.makeToast(Localized("Please select Date"))
            self.showAlert(title: Localized("alert"), message: Localized("Please select Date")) {
              }
            return
        }
        
        if SamratGlobal.loggedInUser()?.user != nil {
//            if self.isSelectedDefault == true {    --- This was previousc commented condition
            if self.selectedServicesData.count > 0 {
                
//                if getSelectedCountry()?.country == "Kuwait" || getSelectedCountry()?.country == "Kuwait ar"
//                {
//                    if categoriesDetails?.id == 1
//                    {
//                        let musicainVc = SelectBandViewController.object()
//                        musicainVc.selectedSinger = self.selectedSinger
//                        musicainVc.isSelectedDefault = true
//                        musicainVc.categoriesDetails = self.categoriesDetails
//                        musicainVc.singer_ServicesWithHour = self.singer_ServicesWithHour
//                        musicainVc.isSingerServicesWithHour = true
//                        musicainVc.parentCatObj = self.parentCatObj
//                        musicainVc.selectedServicesData = self.selectedServicesData
//                        fadeTo(musicainVc)
//                    }
//                    else
//                    {
//                        let onlilePaymentVc = OnlinePaymentVC()
//                        onlilePaymentVc.isFromCustom = false
//                        onlilePaymentVc.selectedSinger = self.selectedSinger
//                        onlilePaymentVc.geSelectedDate = self.selectedBookingDate
//                        onlilePaymentVc.selectedServicesData = self.selectedServicesData
//                        onlilePaymentVc.singer_ServicesWithHour = self.singer_ServicesWithHour
//                        onlilePaymentVc.categoriesDetails = self.categoriesDetails
//                        onlilePaymentVc.parentCatObj = self.parentCatObj
//                        //self.navigationController?.pushViewController(onlilePaymentVc, animated: true)
//                        fadeTo(onlilePaymentVc)
//                    }
//
//                }
//                else
//                {
                    let onlilePaymentVc = OnlinePaymentVC()
                    onlilePaymentVc.isFromCustom = false
                    onlilePaymentVc.selectedSinger = self.selectedSinger
                    onlilePaymentVc.geSelectedDate = self.selectedBookingDate
                    onlilePaymentVc.selectedServicesData = self.selectedServicesData
                    onlilePaymentVc.singer_ServicesWithHour = self.singer_ServicesWithHour
                    onlilePaymentVc.categoriesDetails = self.categoriesDetails
                    onlilePaymentVc.parentCatObj = self.parentCatObj
                    onlilePaymentVc.alradyServices = true
                        //self.navigationController?.pushViewController(onlilePaymentVc, animated: true)
                    fadeTo(onlilePaymentVc)
//                }
                
            }else {
                let musicainVc = MUSICIANSVC()
                musicainVc.selectedSinger = self.selectedSinger
                musicainVc.isSelectedDefault = true
                musicainVc.getSelectedDate = self.selectedBookingDate
                musicainVc.categoriesDetails = self.categoriesDetails
                musicainVc.parentCatObj = self.parentCatObj
                fadeTo(musicainVc)
            }
        }else {
            let loginVc = LoginViewController.object()
            loginVc.isNeedtobackToScreen = true
            fadeTo(loginVc)
        }
    }
    
//    @IBAction func onTapTypeAction(_ sender: UIButton) {
//        isSelectedDefault = !isSelectedDefault
//        if isSelectedDefault{
//            btnSelectType.isSelected = false
//            lblChooseDefault.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
//            lblChooseCustom.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
//        }else{
//            btnSelectType.isSelected = true
//            lblChooseDefault.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
//            lblChooseCustom.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
//        }
//    }
    
    @IBAction func onTapSelectMusicians(_ sender: UIButton) {
        self.btnBookNow.isHidden = false
//        self.optionContainView.isHidden = false
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
        
       // ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)   // QA raise issue of this transition
        APIManager.handler.PostRequest(url: ApiUrl.getBokkingsDates, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    
                    let getBookingObj = try JSONDecoder().decode(BookingResObj.self, from: data)
                    
                    if getBookingObj.status == true {
                        
                        self.dateArray.removeAll()
                        if (getBookingObj.data) != nil {
                            var supl : [(Date, [VADaySupplementary])] =  []
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

extension BookNowWothCalendarVC: VADayViewAppearanceDelegate {
    
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
            return UIColor.init(hexString: "CC8A65")!//.red //theamColor
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

extension BookNowWothCalendarVC: VAMonthViewAppearanceDelegate {
    
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

extension BookNowWothCalendarVC: VAMonthHeaderViewDelegate {
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


extension BookNowWothCalendarVC : VACalendarMonthDelegate {
    func monthDidChange(_ currentMonth: Date) {
        print(currentMonth)
        self.apiGetBookingLists(curentDate: currentMonth)
    }
}

extension BookNowWothCalendarVC: VACalendarViewDelegate {
    func selectedMsg(_ msg: String) {
        if msg == "false" {
            selectedBookingDate = nil
            self.view.makeToast(Localized("wrong selection"))
        }
    }
    
    
    
    
    func selectedDates(_ dates: [Date]) {
        if (dates.last ?? Date()) >= Date() {
            //            calendarView.startDate = dates.last ?? Date()
            //            calendarView.selectDates([dates.last ?? Date()])
            selectedBookingDate = dates.last ?? Date()
        }else {
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
