import UIKit
import Kingfisher
import SVProgressHUD
import AVFoundation

class MusiciansViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewBG : UIImageView!
    var musicanResponseObj:musicianRespoObj?
    var previousSelectedIndexPath : IndexPath?
    var audioPlayer: AVAudioPlayer?     // holds an audio player instance. This is an optional!
    @IBOutlet var lblNoDataFound: UILabel!
    @IBOutlet weak var viewWA: UIView!
    var audioTimer: Timer?            // holds a timer instance
//    var isPlaying = false {             // keep track of when the player is playing
//        didSet {                        // This is a computed property. Changing the value
//            //            setButtonState()            // invokes the didSet block
//            playPauseAudio()
//        }
//    }
    func playPauseAudio(isPlaying : Bool) {
        // audioPlayer is optional use guard to check it before using it.
        guard let audioPlayer = audioPlayer else {
            return
        }
//        var musicianData = MusicianModel.shared.musicanResponseObj?.data?[indexPath.section]
//        var singerDetails = musicianData?.musicians![indexPath.row]
        // Check is playing then play or pause
        if isPlaying {
//            singerDetails?.isPlaying = true
            audioPlayer.play()
            //            self.playBtn.isHighlighted = false
        } else {
            //            self.playBtn.isHighlighted = true
//            singerDetails?.isPlaying = true
            audioPlayer.pause()
        }
//        musicianData?.musicians![indexPath.row] = singerDetails!
//        MusicianModel.shared.musicanResponseObj?.data?[indexPath.section] = musicianData!
//        self.tblView.reloadData()
    }
    
    func updateTableContentInset() {
//        let numRows = self.tblView.numberOfRows(inSection: 0)
//        var contentInsetTop = self.tblView.bounds.size.height
//        for i in 0..<numRows {
//            let rowRect = self.tblView.rectForRow(at: IndexPath(item: i, section: 0))
//            contentInsetTop -= rowRect.size.height
//            if contentInsetTop <= 0 {
//                contentInsetTop = 0
//                break
//            }
//        }
//        self.tblView.contentInset = UIEdgeInsets(top: contentInsetTop,left: 0,bottom: 0,right: 0)
        
    }
    
    func changePlayingParameter(indexPath : IndexPath, isPlay : Bool){
        var musicianData = self.musicanResponseObj?.data?[indexPath.section]
        var singerDetails = musicianData?.musicians![indexPath.row]
        singerDetails?.isPlay = isPlay
        musicianData?.musicians![indexPath.row] = singerDetails!
        self.musicanResponseObj?.data?[indexPath.section] = musicianData!
        
        guard let cell = self.tblView.cellForRow(at: indexPath) as? MusicianListCell else {
            return
        }
        
        if singerDetails?.isPlay == true {
            cell.imgControl.isHighlighted = true
            cell.progressCircle.isHidden = false
            cell.roundView.isHidden = true
            cell.progressCircle.setProgress(to: 1, duration: 25, withAnimation: true)
        } else {
            cell.imgControl.isHighlighted = false
            cell.progressCircle.isHidden = true
            cell.roundView.isHidden = false
            cell.btnPlay.isSelected = false
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
    
    
    @IBAction func onTapPlayAction(_ sender: UIButton) {
        let section = sender.tag / 100
        let row = sender.tag % 100
        let indexPath = IndexPath(row: row, section: section)
        
        if previousSelectedIndexPath == indexPath {
            changePlayingParameter(indexPath: indexPath, isPlay: false)
            playPauseAudio(isPlaying: false)
            previousSelectedIndexPath = nil
        } else {
            if previousSelectedIndexPath != nil {
                self.changePlayingParameter(indexPath: previousSelectedIndexPath!, isPlay: false)
            }
            self.changePlayingParameter(indexPath: indexPath, isPlay: true)
            previousSelectedIndexPath = indexPath
            
            let musicianData = self.musicanResponseObj?.data?[indexPath.section]
            let singerDetails = musicianData?.musicians![indexPath.row]
            let combine = "\(singerDetails?.audio ?? "")"
            DispatchQueue.main.async {
                do {
                    if let getMp3Url = URL.init(string: combine) {
                        self.downloadMp3File(getMp3Url)
                    }
                } catch let error {
                    JSN.log("url erroer ===>%@", error.localizedDescription)
                }
            }
        }
        
//        if previousSelectedIndexPath == indexPath {
////            audioPlayer?.stop()
//            changePlayingParameter(indexPath: indexPath, isPlay: false)
////            self.tblView.reloadRows(at: [previousSelectedIndexPath!], with: .none)
//            playPauseAudio(isPlaying: false)
//        } else {
//            if previousSelectedIndexPath == nil {
//                previousSelectedIndexPath = indexPath
//                self.changePlayingParameter(indexPath: previousSelectedIndexPath!, isPlay: true)
////                self.tblView.reloadRows(at: [previousSelectedIndexPath!], with: .none)
//            } else {
//                self.changePlayingParameter(indexPath: previousSelectedIndexPath!, isPlay: false)
//                self.changePlayingParameter(indexPath: indexPath, isPlay: true)
////                self.tblView.reloadRows(at: [indexPath, previousSelectedIndexPath!], with: .none)
//                previousSelectedIndexPath = indexPath
//            }
//
//            let musicianData = self.musicanResponseObj?.data?[indexPath.section]
//            let singerDetails = musicianData?.musicians![indexPath.row]
//            let combine = "\(singerDetails?.audio ?? "")"
//            DispatchQueue.main.async {
//                do {
//                    if let getMp3Url = URL.init(string: combine ) {
//                        self.downloadMp3File(getMp3Url)
//                    }
//                } catch let error {
//                    JSN.log("url erroer ===>%@", error.localizedDescription)
//                    // couldn't load file :(
//                }
//            }
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
        
        // Do any additional setup after loading the view.
        AppConstant.shared.firstTimeMusician = false
        self.tblView.backgroundColor = UIColor.clear
        tblView.register(UINib(nibName: "MusicianListHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "MusicianListHeaderCell")
        tblView.register(UINib(nibName: "MusicianListCell", bundle: nil), forCellReuseIdentifier: "MusicianListCell")
        
        
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
    func scrollToBottom(){
//        let viewHeight: CGFloat = view.frame.size.height
//            let tableViewContentHeight: CGFloat = tblView.contentSize.height
//            let marginHeight: CGFloat = (viewHeight - tableViewContentHeight) / 2.0
//
//            self.tblView.contentInset = UIEdgeInsets(top: marginHeight, left: 0, bottom:  -marginHeight, right: 0)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        if self.tblView == scrollView{
//            let viewHeight: CGFloat = view.frame.size.height
//            let tableViewContentHeight: CGFloat = tblView.contentSize.height
//            let marginHeight: CGFloat = (viewHeight - tableViewContentHeight) / 2.0
//            if self.tblView.contentInset.bottom < marginHeight{
//                self.tblView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            }
//        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0.0{
            self.viewBG.removeBlurToView()
        } else {
            let blur = (scrollView.contentOffset.y / 100);
            self.viewBG.addBlurToView(val: blur)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.navigationItem.title = Localized("musiciansList").uppercased() //"Singers"//"MUSICIANS"
        
        self.tabBarController?.navigationItem.hidesBackButton = true
        //        self.apiGetSingerList()
        self.updateTableContentInset()
        self.apiGetMusiciansList()
    }
    
    //MARK: Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        let data = self.musicanResponseObj?.data
        if data != nil{
            return data![section].musicians?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.musicanResponseObj?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return tableView.frame.height * 0.5
        } else {
            return 60.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MusicianListHeaderCell") as! MusicianListHeaderCell
        let rect = CGRect(x: headerView.bounds.origin.x, y: headerView.bounds.origin.y + 220, width: headerView.bounds.width, height: headerView.bounds.height + 220)
        
        headerView.segmentControl.isHidden = true
        headerView.lblDefaultSelected.isHidden = true
        headerView.alrandiImageView.isHidden = true
        headerView.backView.layer.cornerRadius = 20
        if Language.shared.isArabic {
            headerView.backView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        
        if section == 0 {
            headerView.backgroundView = UIView(frame: rect)
        } else {
            headerView.backgroundView = UIView(frame: headerView.bounds)
        }
        
        headerView.backgroundView?.backgroundColor = UIColor.clear
        let musicianData = self.musicanResponseObj?.data?[section]
        headerView.lblTitle.text = musicianData?.name
        headerView.lblChoose.isHidden = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicianListCell", for: indexPath) as! MusicianListCell
        let musicianData = self.musicanResponseObj?.data?[indexPath.section]
        let singerDetails = musicianData?.musicians![indexPath.row]
        cell.lblTitle.text = singerDetails?.name
        cell.lblDecription.text = singerDetails?.description
        cell.setImage(str: singerDetails?.image)
        cell.progressCircle.labelSize = 0
        cell.progressCircle.safePercent = 100
        
        if singerDetails?.isPlay == true {
            cell.imgControl.isHighlighted = true
            cell.progressCircle.isHidden = false
            cell.roundView.isHidden = true
            cell.progressCircle.setProgress(to: 1, duration: 25, withAnimation: true)
        } else {
            cell.imgControl.isHighlighted = false
            cell.progressCircle.isHidden = true
            cell.roundView.isHidden = false
            cell.btnPlay.isSelected = false
        }
        
        cell.btnPlay.addTarget(self, action: #selector(onTapPlayAction(_:)), for: .touchUpInside)
        cell.btnPlay.tag = (indexPath.section*100)+indexPath.row
        return cell
    }
    
    func downloadMp3File(_ url:URL?) {
        
        if let audioUrl = url {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            //            print(destinationUrl)
            JSN.log("destinationUrl ===>%@", destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                do {
                    if let getMp3Url = url {
                        //                    let playerItem:AVPlayerItem = AVPlayerItem(url: getMp3Url)
                        //                    self.miniPlayer.soundTrack = playerItem
                        //                    self.player = AVPlayer(playerItem: playerItem)
                        self.audioPlayer = try AVAudioPlayer.init(contentsOf: destinationUrl)
                        self.audioPlayer?.prepareToPlay()
                        //                        self.makeTimer()
                        self.playPauseAudio(isPlaying: true)
                    }
                } catch let error {
                    JSN.log("ger error ===>%@", error.localizedDescription)
                }
                
                //                self.loadAudio(fromiTunes: destinationUrl)
                // if the file doesn't exist
            } else {
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                        do {
                            if let getMp3Url = url,
                               self.previousSelectedIndexPath != nil {
                                //                    let playerItem:AVPlayerItem = AVPlayerItem(url: getMp3Url)
                                //                    self.miniPlayer.soundTrack = playerItem
                                //                    self.player = AVPlayer(playerItem: playerItem)
                                self.audioPlayer = try AVAudioPlayer.init(contentsOf: destinationUrl)
                                self.audioPlayer?.prepareToPlay()
                                self.playPauseAudio(isPlaying: true)
                                //                                self.makeTimer()
                            }
                        } catch let error {
                            JSN.log("ger error ===>%@", error.localizedDescription)
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let vc = self.storyboard?.instantiateViewController(identifier: "MusiciansDetailsViewController") as! MusiciansDetailsViewController
        //        vc.selectedSingerDetails = SingerModel.shared.singersObj?.data?[indexPath.row]
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- API getting Musicians
    func apiGetMusiciansList() {
            ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        let selectedCountry = getSelectedCountry()
        APIManager.handler.PostRequest(url: ApiUrl.getMusicians, params: ["device_type": deviceType, "country_id": selectedCountry?.id ?? 0], isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    
                    self.musicanResponseObj = nil
                    self.musicanResponseObj = try? JSONDecoder().decode(musicianRespoObj.self, from: data)
                    
                    if self.musicanResponseObj?.status == true {
                        if (self.musicanResponseObj?.data?.count ?? 0) <= 0 {
                            self.lblNoDataFound.text = Localized("noDataFound")
                            self.lblNoDataFound.isHidden = false
                            self.tblView.separatorColor = UIColor.clear
                        }else {
                            self.lblNoDataFound.isHidden = true
                        }
                        self.tblView.reloadData()
                        self.updateTableContentInset()
                        self.scrollToBottom()
                    }else {
                        self.showAlert(title: Localized("alert"), message: self.musicanResponseObj?.message ?? Localized("somethingWentWrong"))
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
    
    //MARK:- API getting Singer
    func apiGetSingerList() {
        //        SVProgressHUD.show()
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.singer, params: ["device_type": deviceType], isLoader: true, header: nil, controller: self) { (result) in
            //            SVProgressHUD.dismiss()
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else { return }
                    SingerModel.shared.singersObj = nil
                    SingerModel.shared.singersObj = try? JSONDecoder().decode(singersObj.self, from: data)
                    
                    if SingerModel.shared.singersObj?.status == true {
                        if (SingerModel.shared.singersObj?.data?.count ?? 0) <= 0 {
                            self.lblNoDataFound.text = Localized("noDataFound")
                            self.lblNoDataFound.isHidden = false
                            self.tblView.separatorColor = UIColor.clear
                        } else {
                            self.lblNoDataFound.isHidden = true
                        }
                        self.tblView.reloadData()
                    } else {
                        self.showAlert(title: Localized("alert"), message: SingerModel.shared.singersObj?.message ?? Localized("somethingWentWrong"))
                    }
                } catch (let error) {
                    JSN.log("login uer ====>%@", error)
                }
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
            }
        }
    }
}
