//
//  MyBookingVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 06/05/21.
//

import UIKit
import KRPullLoader

class MyBookingVC: UIViewController, UITableViewDelegate, UITableViewDataSource, KRPullLoadViewDelegate {
    
    @IBOutlet var tableView: UITableView!{
        didSet {
            tableView.register(UINib.init(nibName: "MyUpcomingTVCell", bundle: nil), forCellReuseIdentifier: "MyUpcomingTVCell")
        }
    }
    
    @IBOutlet var segmentOutlet: UISegmentedControl!
    @IBOutlet var lblNoDataFound: UILabel!
    
    @IBOutlet var segmentControl : HBSegmentedControl!
    @IBOutlet weak var viewWA: UIView!
    
    var bookingType = 1
    var upcomingCurrentPage = 1
    var previousBookingPage = 1
    var upcomingTotalPage = 0
    var previousTotalPage = 0
    var upcomingResObj:[Bookings] = [Bookings]()
    var previousResObj:[Bookings] = [Bookings]()
    var currentIndex: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
        // Do any additional setup after loading the view.
        self.title = Localized("myBookings").uppercased() //"My Booking"
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let refreshView = KRPullLoadView()
        refreshView.delegate = self
        tableView.addPullLoadableView(refreshView, type: .refresh)
        let loadeMoreView = KRPullLoadView()
        loadeMoreView.delegate = self
        tableView.addPullLoadableView(loadeMoreView, type: .loadMore)
        self.apiGetBookingLists()
        
        self.segmentOutlet.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        
        self.segmentOutlet.setTitle(Localized("upcoming"), forSegmentAt: 0)
        self.segmentOutlet.setTitle(Localized("previous"), forSegmentAt: 1)
        
        //Custom Segment Class
        segmentControl.items = [Localized("upcoming"), Localized("previous")]
        segmentControl.font = UIFont.systemFont(ofSize: 14)
        segmentControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segmentControl.selectedIndex = 0
        segmentControl.padding = 0
        
        lblNoDataFound.textColor = .white
        
        segmentControl.addTarget(self, action: #selector(self.segmentValueChanged(_:)), for: .valueChanged)
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
    @objc func segmentValueChanged(_ sender: AnyObject?){
        
        if segmentControl.selectedIndex == 0 {
            print(Localized("upcoming"))
        }else{
            print(Localized("previous"))
        }
        self.bookingType = (segmentControl.selectedIndex + 1)
        //        self.apiGetBookingLists()
        self.lblNoDataFound.isHidden = true
        if (self.upcomingResObj.count <= 0) && self.bookingType == 1 {
            self.apiGetBookingLists()
        }else if (self.previousResObj.count <= 0) && self.bookingType == 2 {
            self.apiGetBookingLists()
        }
        currentIndex = nil
        self.tableView.reloadData()
    }
    
    @IBAction func onTapChnageTab(_ sender: UISegmentedControl) {
        self.bookingType = (sender.selectedSegmentIndex + 1)
        //        self.apiGetBookingLists()
        self.lblNoDataFound.isHidden = true
        if (self.upcomingResObj.count <= 0) && self.bookingType == 1 {
            self.apiGetBookingLists()
        }else if (self.previousResObj.count <= 0) && self.bookingType == 2 {
            self.apiGetBookingLists()
        }
        self.tableView.reloadData()
    }
    
    @objc func menuClick(_ sender:UIButton) {
        self.view.endEditing(true)
        
        if appDelegate.isNavigateHome == true
        {
            appDelegate.isNavigateHome = false
            
            self.navigateToWelcomeScreen()
        }
        else
        {
            fadeFrom()
        }
        
        
    }
    
    //MARK:- Tableview Delegate and Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.bookingType == 1) ? (self.upcomingResObj.count) : (self.previousResObj.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MyUpcomingTVCell", for: indexPath) as! MyUpcomingTVCell
        cell.tag = indexPath.row
        if self.bookingType == 1 && indexPath.row <= upcomingResObj.count {
            cell.setData(booking: self.upcomingResObj[indexPath.row], vc: self)
            return cell
        } else if self.bookingType == 2 && indexPath.row <= previousResObj.count {
            cell.setData(booking: self.previousResObj[indexPath.row], vc: self)
            return cell
        }
        let emptyCell = UITableViewCell()
        emptyCell.contentView.backgroundColor = .clear
        return emptyCell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func reloadCell(tag: Int) {
        var indexes = [IndexPath(row: tag, section: 0)]
        if let currentIndex = currentIndex {
            indexes.append(IndexPath(row: currentIndex, section: 0))
        }
        currentIndex = currentIndex == tag ? nil : tag
        tableView.reloadRows(at: indexes, with: .automatic)
    }
    
    //MARK:- Pull Down refresh
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        if type == .loadMore {
            switch state {
            case let .loading(completionHandler):
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                    completionHandler()
                    if self.bookingType == 1 {
                        if self.upcomingCurrentPage < self.upcomingTotalPage {
                            self.upcomingCurrentPage = self.upcomingCurrentPage + 1
                            self.apiGetBookingLists()
                        }else {
                            self.tableView.reloadData()
                        }
                    }else {
                        if self.previousBookingPage < self.previousTotalPage {
                            self.previousBookingPage = self.previousBookingPage + 1
                            self.apiGetBookingLists()
                        }else {
                            self.tableView.reloadData()
                        }
                    }
                }
            default: break
            }
            return
        }
        
        switch state {
        case .none:
            pullLoadView.messageLabel.text = ""
            
        case let .pulling(offset, threshould):
            if offset.y > threshould {
                pullLoadView.messageLabel.text = ""//"Pull more. offset: \(Int(offset.y)), threshould: \(Int(threshould)))"
            } else {
                pullLoadView.messageLabel.text = ""//"Release to refresh. offset: \(Int(offset.y)), threshould: \(Int(threshould)))"
            }
            
        case let .loading(completionHandler):
            pullLoadView.messageLabel.text = "Updating..."
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                completionHandler()
                if self.bookingType == 1 {
                    self.upcomingResObj = []
                    self.upcomingCurrentPage = 1
                }else if self.bookingType == 2 {
                    self.previousResObj = []
                    self.previousBookingPage = 1
                }
                self.apiGetBookingLists()
            }
        }
        
    }
    
    //MARK:- API getting Singer
    fileprivate func apiGetBookingLists() {
        var parameter = [
            "page" : (self.bookingType == 1) ? "\(self.upcomingCurrentPage)" : "\(self.previousBookingPage)",
            "type":"\(self.bookingType)",
            "device_type": deviceType
        ] as [String : Any]
        
        let selectedCountry = getSelectedCountry()
        if selectedCountry != nil {
            parameter["country_id"] = selectedCountry?.id
        }
        
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.getBokkings, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    
                    let getBookingObj = try JSONDecoder().decode(BookingResObj.self, from: data)
                    
                    if getBookingObj.status == true {
                        if self.bookingType == 1 {
                            self.upcomingCurrentPage = getBookingObj.cur_page ?? 0
                            self.upcomingTotalPage = getBookingObj.total_page ?? 0
                            if let getBookigs = getBookingObj.bookings {
                                self.upcomingResObj.append(contentsOf: getBookigs)
                                if self.upcomingResObj.count == 0 {
                                    self.lblNoDataFound.isHidden = false
                                }else {
                                    self.lblNoDataFound.isHidden = true
                                }
                            }
                        }else {
                            self.previousBookingPage = getBookingObj.cur_page ?? 0
                            self.previousTotalPage = getBookingObj.total_page ?? 0
                            if let getBookigs = getBookingObj.bookings {
                                self.previousResObj.append(contentsOf: getBookigs)
                                if self.previousResObj.count == 0 {
                                    self.lblNoDataFound.isHidden = false
                                }else {
                                    self.lblNoDataFound.isHidden = true
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }else {
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
