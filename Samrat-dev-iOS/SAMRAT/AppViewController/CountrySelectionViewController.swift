//
//  CountrySelectionViewController.swift
//  SAMRAT
//
//  Created by Ajay Veer on 08/08/22.
//

import UIKit

class CountrySelectionViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var countryResponseObj:CountriesResObj?
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var pleaseSelectLocationView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var pleaseSelectLocationLabel: UILabel!
    var isComingFromSetting: Bool?
    @IBOutlet var tableView: UITableView!{
        didSet {
            tableView.register(UINib.init(nibName: "CountrySelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CountrySelectionTableViewCell")
        }
    }
    @IBOutlet weak var viewWA: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
        
        if  isComingFromSetting ?? false {
            var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
            imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        } else {
            self.navigationController?.navigationBar.isHidden = true
        }
        setupView()
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
    
    func setupView() {
        noDataView.isHidden = true
        noDataLabel.text = Localized("noDataFound")
        pleaseSelectLocationLabel.text = Localized("pleaseSelectLocation")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        apiGetcountriesList()
    }
    //MARK:- countries API Calling
    func apiGetcountriesList() {
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        
        APIManager.handler.PostRequest(url: ApiUrl.getCountries, params: [:], isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    self.countryResponseObj = nil
                    self.countryResponseObj = try? JSONDecoder().decode(CountriesResObj.self, from: data)
                    
                    if self.countryResponseObj?.status == true {
                        if (self.countryResponseObj?.data?.count ?? 0) <= 0 {
                            self.noDataView.isHidden = false
                            self.tableView.isHidden = true
                            self.pleaseSelectLocationView.isHidden = true
                                                           
                        }else {
                            self.noDataView.isHidden = true
                            self.tableView.isHidden = false
                            self.pleaseSelectLocationView.isHidden = false
                        }
                        self.tableView.reloadData()
                    }else {
                        self.showAlert(title: Localized("alert"), message: self.countryResponseObj?.message ?? Localized("somethingWentWrong"))
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
    
    @IBAction func clickedWA(_ sender: Any) {
        print("Button Tapped")
        
        if let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=\(CategoriesModel.shared.settingResponse?.settings?.whatsapp_number ?? "")&text=") {
            
            if UIApplication.shared.canOpenURL(whatsappURL) {
                UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
            }
        }
    }
    @objc func menuClick(_ sender:UIButton) {
        self.view.endEditing(true)
        fadeFrom()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.countryResponseObj?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CountrySelectionTableViewCell", for: indexPath) as! CountrySelectionTableViewCell
        let countryData = self.countryResponseObj?.data?[indexPath.row]
        cell.lblSelectedCountry?.text = countryData?.country
       
        let selectedCountry = UserDefaults.standard.decode(for: CountriesData.self, using: "selectedCountryObj")
         if self.countryResponseObj?.data?[indexPath.row].id == selectedCountry?.id ?? 0 {
                cell.imgSelection.image = UIImage(named: "select-1")
            } else {
                cell.imgSelection.image = UIImage(named: "unselect-1")
            }
        let url = URL(string: countryData?.flag_url ?? "")
        cell.imgSelectedCountry?.kf.setImage(with: url,
                                             placeholder: nil,
                                             options: [.transition(.fade(0.3)),
                                                       .cacheOriginalImage,
                                                       .forceTransition]) { (_, _) in
                                                           
                                                       } completionHandler: { (_, _, _, _) in
                                                           if let imgPlace = cell.subviews.first(where: { $0.layer.name == "placeholder" }) {
                                                               imgPlace.isHidden = true
                                                           }
                                                       }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCountry = self.countryResponseObj?.data?[indexPath.row]
        UserDefaults.standard.encode(for: selectedCountry, using: "selectedCountryObj")
        if isComingFromSetting ?? false {
            fadeFrom()
        } else {
            self.navigateToWelcomeScreen()
        }
        
    }

}
