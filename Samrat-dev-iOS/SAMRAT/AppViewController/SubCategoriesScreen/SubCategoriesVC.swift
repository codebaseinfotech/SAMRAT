//
//  SubCategoriesVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 28/03/22.
//

import UIKit

class SubCategoriesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var tableView: UITableView!{
        didSet {
            tableView.register(UINib.init(nibName: "HomeTCell", bundle: nil), forCellReuseIdentifier: "HomeTCell")
        }
    }
    
    var categoriesDetails: CategoriesData? = nil
    var parentCatObj: CategoriesData? = nil

    @IBOutlet weak var viewWA: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
        
        // Do any additional setup after loading the view.
        print("Aj print:- ", self.categoriesDetails?.id)
        
        self.title = self.categoriesDetails?.name?.uppercased() ?? ""
        if self.categoriesDetails?.id == 21 {
            self.imageView.image = UIImage(named: "wedding_sub_cat_bg")
        } else if self.categoriesDetails?.id == 23{
            self.imageView.image = UIImage(named: "band_other_singers")
        } else{
            
        }
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        self.updateTableContentInset()
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
    
    @objc func menuClick(_ sender:UIButton) {
        self.view.endEditing(true)
        fadeFrom()
    }

    
    func updateTableContentInset() {
        let numRows = self.tableView.numberOfRows(inSection: 0)
        var contentInsetTop = self.tableView.bounds.size.height/1.5
        for i in 0..<numRows {
            let rowRect = self.tableView.rectForRow(at: IndexPath(item: i, section: 0))
            contentInsetTop -= rowRect.size.height
            if contentInsetTop <= 0 {
                contentInsetTop = 0
                break
            }
        }
        self.tableView.contentInset = UIEdgeInsets(top: contentInsetTop,left: 0,bottom: 0,right: 0)

    }
    
    //MARK:- Table View delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoriesDetails?.sub_categories_recursive?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "HomeTCell", for: indexPath) as! HomeTCell
        let categoriesDetails = self.categoriesDetails?.sub_categories_recursive?[indexPath.row]
        cell.lblTitle.text = categoriesDetails?.name?.uppercased() ?? ""
        //        cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let catSingerListVC = CatSingerListVC()
//        catSingerListVC.categoriesDetails = self.categoriesDetails?.sub_categories_recursive?[indexPath.row]
//        fadeTo(catSingerListVC)
        
        if (self.categoriesDetails?.sub_categories_recursive?[indexPath.row].sub_categories_recursive?.count ?? 0) > 0 {
            let subObj = SubCategoriesVC()
            subObj.categoriesDetails = self.categoriesDetails?.sub_categories_recursive?[indexPath.row]
            subObj.parentCatObj = self.parentCatObj
            fadeTo(subObj)
        }else {
            let catSingerListVC = CatSingerListVC()
            catSingerListVC.categoriesDetails = self.categoriesDetails?.sub_categories_recursive?[indexPath.row]
            catSingerListVC.parentCatObj = self.parentCatObj
            fadeTo(catSingerListVC)
        }

        
        
//        let subObj = SubCategoriesVC()
//        fadeTo(subObj)
        
//        var homeObj = HomeViewController.object()
        
//        self.navigationController?.pushViewController(homeObj, animated: true)
//        fadeTo(homeObj)
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
