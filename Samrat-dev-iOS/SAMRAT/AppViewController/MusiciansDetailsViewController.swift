import UIKit
import MiniPlayer
import AVFoundation
import Kingfisher

class MusiciansDetailsViewController: UIViewController {
    
    @IBOutlet var musicianImgView: UIImageView!
    @IBOutlet var imgPlaceholder: UIImageView!
    @IBOutlet var lblSingerName: UILabel!
    @IBOutlet var lblSingerDesc: UILabel!
    @IBOutlet var playBtn: UIButton!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var viewPlayer: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    //MARK:- @IBOutlets
    @IBOutlet var btnBookNow: UIButton!{
        didSet{
            btnBookNow.layer.cornerRadius = 22.5
        }
    }
    @IBOutlet var viewGradient: UIView!{
        didSet{
            viewGradient.layer.cornerRadius = 30.0
            viewGradient.clipsToBounds = true
            //            viewGradient.applyGradient(colours: [UIColor.black,UIColor.clear])
        }
    }
    
    @IBOutlet weak var viewWA: UIView!
    
    
    var selectedSingerDetails:singersData? = nil
    var categoriesDetails: CategoriesData? = nil
    var parentCatObj: CategoriesData? = nil
    
    fileprivate var startRendering = Date()
    fileprivate var endRendering = Date()
    fileprivate var startLoading = Date()
    fileprivate var endLoading = Date()
    fileprivate var profileResult = ""
    
    //var player = AVPlayer()
    // Formatting time for display
    let timeFormatter = NumberFormatter()
    
    var audioPlayer: AVAudioPlayer?     // holds an audio player instance. This is an optional!
    var audioTimer: Timer?            // holds a timer instance
    var settingsResponse:SettingResponse? = nil
    
    var isPlaying = false {             // keep track of when the player is playing
        didSet {                        // This is a computed property. Changing the value
            playBtn.isSelected = isPlaying
            setButtonState()            // invokes the didSet block
            playPauseAudio()
        }
    }
    
    var objMultipleSinger : MultipleSingerVC? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
        
        print("Aj print:- ", self.categoriesDetails?.id)
        
//        self.title = Localized("SINGER").uppercased() //"SINGER"
        if objMultipleSinger != nil {
            self.btnBookNow.setTitle(Localized("Select Singer").uppercased(), for: .normal)
        }
        else {
            self.btnBookNow.setTitle(Localized("bookNow").uppercased(), for: .normal)
        }
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        self.lblSingerName.text = self.selectedSingerDetails?.name ?? ""
        self.lblSingerDesc.text = self.selectedSingerDetails?.description ?? ""
        self.view.backgroundColor = hexStringToUIColor(hex: "#20382E")
        
        //        https://samrat.app/public/singer_audio/60828e39158121619168825.mp3
        //        self.miniPlayer.durationTimeInSec = 0
        //        self.miniPlayer.delegate = self
        
        
        if Language.shared.isArabic {
            viewPlayer.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            playBtn.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        playBtn.isHidden = true
        timeSlider.isEnabled = false
        
        DispatchQueue.main.async {
            do {
                if let getMp3Url = URL.init(string: self.selectedSingerDetails?.audio ?? "") {
                    //                    let playerItem:AVPlayerItem = AVPlayerItem(url: getMp3Url)
                    //                    self.miniPlayer.soundTrack = playerItem
                    //                    self.player = AVPlayer(playerItem: playerItem)
                    
                    
                    //                    self.audioPlayer = try AVAudioPlayer.init(contentsOf: getMp3Url)
                    //                    self.audioPlayer?.prepareToPlay()
                    //                    self.makeTimer()
                    
                    
                    self.downloadMp3File(getMp3Url)
                    
                }
            } catch let error {
                JSN.log("url erroer ===>%@", error.localizedDescription)
                // couldn't load file :(
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.playBtn.isHidden = false
                self.timeSlider.isEnabled = true
            }
        }
        let url = URL(string: self.selectedSingerDetails?.detail_image ?? "")
        self.musicianImgView.kf.setImage(with: url,
                         placeholder: nil,
                         options: [.transition(.fade(0.3)),
                                   .cacheOriginalImage,
                                   .forceTransition]) { (_, _) in
            
        } completionHandler: { (_, _, _, _) in
            self.imgPlaceholder.isHidden = true
        }
        
//        self.musicianImgView.downloadImage(str: self.selectedSingerDetails?.detail_image,
//                                           placeholder: Images.appLogo2)
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
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                playBtn.isHidden = false
                timeSlider.isEnabled = true
                print("The file already exists at path")
                do {
                    if let getMp3Url = URL.init(string: self.selectedSingerDetails?.audio ?? "") {
                        //                    let playerItem:AVPlayerItem = AVPlayerItem(url: getMp3Url)
                        //                    self.miniPlayer.soundTrack = playerItem
                        //                    self.player = AVPlayer(playerItem: playerItem)
                        self.audioPlayer = try AVAudioPlayer.init(contentsOf: destinationUrl)
                        self.audioPlayer?.prepareToPlay()
//                        self.makeTimer()
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
                        
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.isHidden = true
                            self.playBtn.isHidden = false
                            self.timeSlider.isEnabled = true
                        }
                        do {
                            if let getMp3Url = URL.init(string: self.selectedSingerDetails?.audio ?? "") {
                                //                    let playerItem:AVPlayerItem = AVPlayerItem(url: getMp3Url)
                                //                    self.miniPlayer.soundTrack = playerItem
                                //                    self.player = AVPlayer(playerItem: playerItem)
                                self.audioPlayer = try AVAudioPlayer.init(contentsOf: destinationUrl)
                                self.audioPlayer?.prepareToPlay()
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
        } else {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.playBtn.isHidden = false
            self.timeSlider.isEnabled = true
        }
    }
    
    func setButtonState() {
        // When the play button is tapped the text changes
        // TODO: Use the enum below for button and player states
        if isPlaying {
//            self.playBtn.isHighlighted = true
//            self.playBtn.setTitle("Pause", for: .normal)
        } else {
//            self.playBtn.isHighlighted = false
//            self.playBtn.setTitle("Play", for: .normal)
        }
    }
    
    func playPauseAudio() {
        // audioPlayer is optional use guard to check it before using it.
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        // Check is playing then play or pause
        if isPlaying {
            audioPlayer.play()
            self.makeTimer()
//            self.playBtn.isHighlighted = false
        } else {
//            self.playBtn.isHighlighted = true
            audioPlayer.pause()
            if audioTimer?.isValid ?? false {
                audioTimer?.invalidate()
            }
        }
    }
    
    @IBAction func onTapBookingAction(_ sender: UIButton) {
        isPlaying = false
        if SamratGlobal.loggedInUser()?.user == nil {
            let loginVc = LoginViewController.object()
            loginVc.isNeedtobackToScreen = true
            fadeTo(loginVc)
        }else {
            if objMultipleSinger != nil {
                if let maxSinger = self.settingsResponse?.settings?.max_singer_selection,
                   self.objMultipleSinger?.selectedSinger.count ?? 0 >= Int(maxSinger) ?? 2 {
                    self.view.makeToast(Localized("Maximum singers selected"))
                    return
                }
                self.objMultipleSinger?.selectedSinger.append((selectedSingerDetails)!)
                self.view.endEditing(true)
                self.navigationController?.popViewController(animated: true)
            }
            else {
                
                if self.categoriesDetails?.id == 28 || self.categoriesDetails?.id == 24 || self.categoriesDetails?.id == 29 {
                    let bookNowVc = BookNowWothCalendarVCBottom()
                    bookNowVc.selectedSinger = self.selectedSingerDetails
                    bookNowVc.categoriesDetails = self.categoriesDetails
                    bookNowVc.parentCatObj = self.parentCatObj
                    fadeTo(bookNowVc)
                } else{
                    let bookNowVc = BookNowWothCalendarVC()
                    bookNowVc.selectedSinger = self.selectedSingerDetails
                    bookNowVc.categoriesDetails = self.categoriesDetails
                    bookNowVc.parentCatObj = self.parentCatObj
                    fadeTo(bookNowVc)
                }

                
//                let bookNowVc = BookNowWothCalendarVC()
//                bookNowVc.selectedSinger = self.selectedSingerDetails
//                bookNowVc.categoriesDetails = self.categoriesDetails
//                bookNowVc.parentCatObj = self.parentCatObj
//                fadeTo(bookNowVc)
                
//                let arrayString = [
//                    Localized("singerSelectAlert1"),
//                    Localized("singerSelectAlert2"),
//                    Localized("singerSelectAlert3")
//                ]
////                let attStr = add(stringList: arrayString, font: UIFont.systemFont(ofSize: 15))
////                AlertView.instance.showAlert(title: Localized("termsAndConditions"), message: attStr, alertType: .twoButton)
//                AlertView.instance.showAlert(title: Localized("termsAndConditions"), arrMessages: arrayString, alertType: .twoButton)
//                AlertView.instance.alertViewDelegate = self
            }
        }
    }
    
    @IBAction func onTapPlayAction(_ sender: UIButton) {
        isPlaying = !isPlaying
//        self.playPauseAudio()
    }
    
    // Update time when dragging the slider
    @IBAction func timeSliderChanged(sender: UISlider) {
        // Working on this
        // TODO: Implement Time Slider
        guard let audioPlayer = self.audioPlayer else {
            return
        }
        
        audioPlayer.currentTime = audioPlayer.duration * Double(sender.value)
    }
    
    @objc func menuClick(_ sender:UIButton) {
        isPlaying = false
        self.view.endEditing(true)
        fadeFrom()
    }
    
    func makeTimer() {
        // This function sets up the timer.
        if audioTimer != nil {
            audioTimer!.invalidate()
        }
        
        // audioTimer = Timer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.onTimer(_:)), userInfo: nil, repeats: true)
        
        audioTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimer(timer:)), userInfo: nil, repeats: true)
    }
    
    @objc func onTimer(timer: Timer) {
        // Check the audioPlayer, it's optinal remember. Get the current time and duration
        
        if !(audioPlayer?.isPlaying ?? false) {
            isPlaying = false
        }
        
        guard let currentTime = audioPlayer?.currentTime, let duration = audioPlayer?.duration else {
            return
        }
        
        // Calculate minutes, seconds, and percent completed
//        let mins = currentTime / 60
//        // let secs = currentTime % 60
//        let secs = currentTime.truncatingRemainder(dividingBy: 60)
        let percentCompleted = currentTime / duration
        
        // Use the number formatter, it might return nil so guard
        //    guard let minsStr = timeFormatter.stringFromNumber(NSNumber(mins)), let secsStr = timeFormatter.stringFromNumber(NSNumber(secs)) else {
        //      return
        //    }
        
//        guard let minsStr = timeFormatter.string(from: NSNumber(value: mins)), let secsStr = timeFormatter.string(from: NSNumber(value: secs)) else {
//            return
//        }
        
        
        // Everything is cool so update the timeLabel and progress bar
        //        timeLabel.text = "\(minsStr):\(secsStr)"
        //        progressBar.progress = Float(percentCompleted)
        // Check that we aren't dragging the time slider before updating it
        timeSlider.value = Float(percentCompleted)
    }
    
}

extension MusiciansDetailsViewController : AlertViewDelegate {
    func okayButtonTapped() {
       
        if self.categoriesDetails?.id == 28 || self.categoriesDetails?.id == 24 || self.categoriesDetails?.id == 29 {
            let bookNowVc = BookNowWothCalendarVCBottom()
            bookNowVc.selectedSinger = self.selectedSingerDetails
            bookNowVc.categoriesDetails = self.categoriesDetails
            bookNowVc.parentCatObj = self.parentCatObj
            fadeTo(bookNowVc)
        } else{
            let bookNowVc = BookNowWothCalendarVC()
            bookNowVc.selectedSinger = self.selectedSingerDetails
            bookNowVc.categoriesDetails = self.categoriesDetails
            bookNowVc.parentCatObj = self.parentCatObj
            fadeTo(bookNowVc)
        }
        
//        let bookNowVc = BookNowWothCalendarVC()
//        bookNowVc.selectedSinger = self.selectedSingerDetails
//        bookNowVc.categoriesDetails = self.categoriesDetails
//        bookNowVc.parentCatObj = self.parentCatObj
//        fadeTo(bookNowVc)
    }
    
    func cancleButtonTapped() {
        
    }
}

extension MusiciansDetailsViewController: MiniPlayerDelegate {
    func didPlay(player: MiniPlayer) {
        print("Playing...")
    }
    
    func didStop(player: MiniPlayer) {
        print("Stopped")
    }
    
    func didPause(player: MiniPlayer) {
        print("Pause")
    }
}

