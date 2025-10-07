import UIKit
import ScalingCarousel
import FSPagerView
import Kingfisher

//class CodeCell: ScalingCarouselCell {
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        mainView = UIView(frame: contentView.bounds)
//        contentView.addSubview(mainView)
//        mainView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//            ])
//
//        imageContentView = UIImageView(frame: mainView.bounds)
//        contentView.addSubview(imageContentView)
////        imageContentView.translatesAutoresizingMaskIntoConstraints = false
////        NSLayoutConstraint.activate([
////            imageContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
////            imageContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
////            imageContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
////            imageContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
////            ])
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}


class GalleryViewController: UIViewController,FSPagerViewDelegate, FSPagerViewDataSource {
    @IBOutlet var containView: UIView!
    
    // MARK: - Properties (Private)
    //fileprivate var scalingCarousel: ScalingCarouselView!
    
    var gallryResponse:GalleryResponse? = nil

    @IBOutlet var pagerView: FSPagerView!{
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    @IBOutlet weak var viewWA: UIView!
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
        
//        addCarousel()
        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        AppConstant.shared.firstTimeGallery = false
        self.pagerView.transformer = FSPagerViewTransformer(type: .overlap)
        pagerView.interitemSpacing = 5
        pagerView.backgroundColor = .clear
//        pagerView.layer.masksToBounds = true
//        pagerView.layer.cornerRadius = 10
        
        self.pagerView.delegate = self
        self.pagerView.dataSource = self
        self.pagerView.isInfinite = true
        
        DispatchQueue.asyncAfter(deadline: 0.1) {
            self.pagerView.itemSize = CGSize(width: self.pagerView.frame.width - 50, height: self.pagerView.frame.height - 50)
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
        super.viewWillAppear(animated)
        
        
        self.tabBarController?.navigationItem.title = ""
        
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isHidden = false
        self.apiGetGallyList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
//         if scalingCarousel != nil {
//            scalingCarousel.deviceRotated()
//         }
    }
    
    @IBAction func clickedWA(_ sender: Any) {
        print("Button Tapped")
        
        if let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=\(CategoriesModel.shared.settingResponse?.settings?.whatsapp_number ?? "")&text=") {
            
            if UIApplication.shared.canOpenURL(whatsappURL) {
                UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
            }
        }
    }
    // MARK: - Configuration
    
//    private func addCarousel() {
//
//        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
//        scalingCarousel = ScalingCarouselView(withFrame: frame, andInset: 65)
//        scalingCarousel.scrollDirection = .horizontal
//        scalingCarousel.dataSource = self
//        scalingCarousel.delegate = self
//        scalingCarousel.translatesAutoresizingMaskIntoConstraints = false
//        scalingCarousel.backgroundColor = .clear
//
//        scalingCarousel.register(CodeCell.self, forCellWithReuseIdentifier: "cell")
//
//        view.addSubview(scalingCarousel)
//
//        // Constraints
//        scalingCarousel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
//        scalingCarousel.heightAnchor.constraint(equalToConstant: self.view.frame.size.height-200).isActive = true
//        scalingCarousel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        scalingCarousel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        scalingCarousel.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
//    }
    
    //MARK:- FSPageView
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.gallryResponse?.data?.count ?? 0
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        let galleryDetails = self.gallryResponse?.data?[index]
        if let imgPlace = cell.subviews.first(where: { $0.layer.name == "placeholder" }) {
            imgPlace.isHidden = false
        } else {
            let img = UIImageView(image: Images.appLogo2)
            img.contentMode = .center
            img.layer.name = "placeholder"
            cell.addSubview(img)
            img.translatesAutoresizingMaskIntoConstraints = false
            img.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            img.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        }
        //cell.imageView?.downloadImage(str: galleryDetails?.image, placeholder: nil)
        
        let url = URL(string: galleryDetails?.image ?? "")
        cell.imageView?.kf.setImage(with: url,
                         placeholder: nil,
                         options: [.transition(.fade(0.3)),
                                   .cacheOriginalImage,
                                   .forceTransition]) { (_, _) in
            
        } completionHandler: { (_, _, _, _) in
            if let imgPlace = cell.subviews.first(where: { $0.layer.name == "placeholder" }) {
                imgPlace.isHidden = true
            }
        }
        
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.layer.masksToBounds = false
        cell.imageView?.clipsToBounds = true
        cell.imageView?.layer.cornerRadius = 20
        cell.backgroundColor = .black
        cell.contentView.backgroundColor = .black
        cell.contentView.layer.cornerRadius = 20
        cell.layer.cornerRadius = 20
        return cell
    }

    //MARK:- Gallery API Calling
    func apiGetGallyList() {
        if AppConstant.shared.firstTimeGallery{
            ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        }
        APIManager.handler.PostRequest(url: ApiUrl.get_gallery, params: ["device_type": deviceType], isLoader: true, header: nil, controller: self) { (result) in
//            SVProgressHUD.dismiss()
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    self.gallryResponse = try JSONDecoder().decode(GalleryResponse.self, from: data)
                    
                    
                    if self.gallryResponse?.status == true {
                        self.pagerView.reloadData()
                        if Language.shared.isArabic == true {
                            let indxPath = IndexPath.init(row: (self.gallryResponse?.data?.count ?? 0) - 1, section: 0)
                            JSN.log("scalingCarousel ===>%@", indxPath)
//                            self.scalingCarousel.scrollToItem(at: indxPath, at: .top, animated: false)
                        }
                    }else {
                        self.showAlert(title: Localized("alert"), message: self.gallryResponse?.message ?? Localized("somethingWentWrong"))
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

//extension GalleryViewController: UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.gallryResponse?.data?.count ?? 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//
//        if let scalingCell = cell as? ScalingCarouselCell {
//            let galleryDetails = self.gallryResponse?.data?[indexPath.row]
//            var imgView = UIImageView()
//            imgView.frame = scalingCell.mainView.bounds
//            let url = URL(string: galleryDetails?.image ?? "")
//            imgView.kf.setImage(with: url, placeholder: Images.singersSplashImg, options: [.transition(.fade(0.1))], progressBlock: nil, completionHandler: nil)
////            imgView.image = UIImage(named: "13813Image1")
//            scalingCell.mainView.addSubview(imgView)
//            imgView.backgroundColor = .clear//Colors.snomo
//            imgView.contentMode = .scaleAspectFill
//            imgView.clipsToBounds = true
//            imgView.layer.cornerRadius = 20
//            scalingCell.mainView.backgroundColor = .clear//Colors.snomo
////            scalingCell.mainView.backgroundColor = .lightGray
////            scalingCell.imageContentView.frame = scalingCell.mainView.frame
////            scalingCell.imageContentView.backgroundColor = .yellow
////            scalingCell.imageContentView.image = UIImage(named: "13813Image1")
////            scalingCell.imageContentView.contentMode = .scaleAspectFit
////            scalingCell.imageContentView.clipsToBounds = true
//        }
//        DispatchQueue.main.async {
//            cell.setNeedsLayout()
//            cell.layoutIfNeeded()
//        }
//
//        return cell
//    }
//}

//extension GalleryViewController: UICollectionViewDelegate {
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        scalingCarousel.didScroll()
//    }
//}
