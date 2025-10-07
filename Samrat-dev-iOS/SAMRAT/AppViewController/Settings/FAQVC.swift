//
//  FAQVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 27/04/21.
//

import UIKit

class FAQVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.register(UINib.init(nibName: "FaqTVHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "FaqTVHeader")
            tableView.register(UINib.init(nibName: "FaqTVCell", bundle: nil), forCellReuseIdentifier: "FaqTVCell")
        }
    }
    var faqsResponseObj:FaqsResponseObj? = nil
    
    var selectedIndex: [IndexPath] = [IndexPath]()
    @IBOutlet weak var viewWA: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
                viewWA.clipsToBounds = true
                
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                viewWA.addGestureRecognizer(panGesture)
        // Do any additional setup after loading the view.
        self.title = "FAQ"
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.apiGetFaq()
    }
    
    @objc func menuClick(_ sender:UIButton)
    {
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
    //MARK:- Tableview delegate and datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.faqsResponseObj?.data?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedIndex.filter({$0.section == section}).count > 0 {
            return 1
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "FaqTVCell", for: indexPath) as! FaqTVCell
        cell.lblDescription.text = self.faqsResponseObj?.data?[indexPath.row].description ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "FaqTVHeader") as! FaqTVHeader
        header.imgStatus.isHighlighted = (self.selectedIndex.filter({$0.section == section}).count > 0)
        header.onTapHeaderAct = {
            if self.selectedIndex.filter({$0.section == section}).count > 0 {
                self.selectedIndex.removeAll(where: {$0.section == section})
            }else {
                self.selectedIndex.append(IndexPath.init(row: 0, section: section))
            }
            self.tableView.reloadSections(IndexSet.init(integer: section), with: UITableView.RowAnimation
                                            .fade)
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    //MARK:- API FAQ Details getting
    func apiGetFaq() {
        APIManager.handler.GetRequest(url: ApiUrl.faq, isLoader: true, header: nil, controller: self) { (result) in
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    
                    
                    self.faqsResponseObj = try? JSONDecoder().decode(FaqsResponseObj.self, from: data)
                    
                    if self.faqsResponseObj?.status == true {
                        self.tableView.reloadData()
                    }else {
                        self.showAlert(title: Localized("alert"), message: self.faqsResponseObj?.message ?? Localized("somethingWentWrong"))
                        //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
