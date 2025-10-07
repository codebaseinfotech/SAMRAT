//
//  MusicBarTableViewCell.swift
//  SAMRAT
//
//  Created by Macbook on 16/02/22.
//

import UIKit
import MiniPlayer
import AVFoundation

class MusicBarTableViewCell: UITableViewCell {

    var onCheckboxTapAction:(([servicesData])->())? = nil
    var onDDSelectionTapAction:(([singer_Services])->())? = nil
    
    @IBOutlet weak var lblSingerName: UILabel!
    @IBOutlet weak var lblSingerDesc: UILabel!
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewPlayer: UIView!
    
    @IBOutlet weak var btnBookNoe: UIButton!{
        didSet{
            btnBookNoe.layer.cornerRadius = 22.5
        }
    }
    
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var selectedSingerDetails:singersData? = nil
    var singer_ServicesWithHour:[singer_Services] = []
    var selectedServicesData:[servicesData] = []
    
    @IBOutlet weak var tblServices: UITableView!{
        didSet {
            self.tblServices.register(UINib(nibName: "MusiciansServiceTVCell", bundle: nil), forCellReuseIdentifier: "MusiciansServiceTVCell")
        }
    }
    
    var audioPlayer: AVAudioPlayer?     // holds an audio player instance. This is an optional!
    var audioTimer: Timer?            // holds a timer instance
    
    var urlString: String = ""{
        didSet{
            self.callDownloadMethod()
           
        }
    }
    
    var isPlaying = false {             // keep track of when the player is playing
        didSet {                        // This is a computed property. Changing the value
            playBtn.isSelected = isPlaying
            setButtonState()            // invokes the didSet block
            playPauseAudio()
        }
    }
    
    @IBOutlet var viewGradient: UIView!{
        didSet{
            //viewGradient.layer.cornerRadius = 30.0
            //self.viewGradient.roundCorners(corners: [.topRight, .topLeft], radius: 8.0)
            viewGradient.clipsToBounds = true
            
            viewGradient.layer.cornerRadius = 10
            viewGradient.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.tableViewHeight.constant = 0
        //self.view.backgroundColor = hexStringToUIColor(hex: "#20382E")
        
        if Language.shared.isArabic {
            viewPlayer.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            playBtn.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        
     
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        playBtn.isHidden = true
        timeSlider.isEnabled = false
        
        self.tblServices.delegate = self
        self.tblServices.dataSource = self
        
        self.tblServices.reloadData()
        self.tblServices.backgroundColor = .clear
        
        self.btnBookNoe.setTitle(Localized("bookNow").uppercased(), for: .normal)
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
    
    func callDownloadMethod(){
        
        // Download mp3 file logic
        DispatchQueue.main.async {
            do {
                if let getMp3Url = URL.init(string: self.urlString ) {
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
    }
    
    @IBAction func onTapPlayAction(_ sender: Any) {
        isPlaying = !isPlaying
    }
    
    @IBAction func timeSliderChange(_ sender: UISlider) {
        // Working on this
        // TODO: Implement Time Slider
        guard let audioPlayer = self.audioPlayer else {
            return
        }
        
        audioPlayer.currentTime = audioPlayer.duration * Double(sender.value)
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
                    if let getMp3Url = URL.init(string: self.urlString) {
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
                            if let getMp3Url = URL.init(string: self.urlString) {
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
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension MusicBarTableViewCell: MiniPlayerDelegate {
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


extension MusicBarTableViewCell: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return selectedSingerDetails?.services?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
  
        return UITableView.automaticDimension
     
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       
        return .leastNormalMagnitude
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        self.tableViewHeight.constant = self.tblServices.contentSize.height
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tblServices.dequeueReusableCell(withIdentifier: "MusiciansServiceTVCell", for: indexPath) as! MusiciansServiceTVCell
        cell.lblMusicianName.text = self.selectedSingerDetails?.services?[indexPath.row].title
        cell.lblMusicanDesc.text = self.selectedSingerDetails?.services?[indexPath.row].description
        let x : Int = self.selectedSingerDetails?.services?[indexPath.row].price ?? 0
        let stringValue = "\(x) \(SelectedCurrency.shared.currentAppCurrency)"
        cell.lblPrice.text = stringValue
        cell.btnBook.tag = indexPath.row
        cell.btnBook.addTarget(self, action: #selector(btnBookTapped(_:)), for: .touchUpInside)
        
        var dictionary:[String] = []
        if let item = self.selectedSingerDetails?.services?[indexPath.row].max_hr_array {
            dictionary.removeAll()
            for service in item {
                dictionary.append(service.title ?? "")
            }
        }
        
        cell.txtDropDown.optionArray = dictionary//["Option 1", "Option 2", "Option 3"]
        cell.txtDropDown.borderWidth = 2
        cell.txtDropDown.borderColor = Colors.snomoTransparant
        cell.txtDropDown.cornerRadius = 8
        cell.txtDropDown.backgroundColor = .clear
        cell.txtDropDown.textColor = .white
        cell.txtDropDown.arrowColor = Colors.snomoTransparant
        cell.txtDropDown.isSearchEnable = false
        cell.txtDropDown.text = dictionary[0]
        cell.txtDropDown.checkMarkEnabled = false
        cell.txtDropDown.selectedRowColor = Colors.snomoTransparant
        
        
        
        // After selection
        // The the Closure returns Selected Index and String
        cell.txtDropDown.didSelect{(selectedText , index ,id) in
            self.singer_ServicesWithHour.removeAll()
            let filterdSection = self.selectedSingerDetails?.services?[indexPath.row].max_hr_array?.filter({$0.title == selectedText})
            
            print("Selected String: \(selectedText) \n index: \(index) \n indexPath: \(indexPath.row)")
            var obj = singer_Services()
            let x : Int = self.selectedSingerDetails?.services?[indexPath.row].id ?? 0
            let stringValue = "\(x)"
            obj.service_id = stringValue
            obj.hrs = filterdSection?[0].value//selectedText
            self.singer_ServicesWithHour.append(obj)
            
            self.onDDSelectionTapAction?(self.singer_ServicesWithHour)
        }
        
        
        return cell
        
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        tableViewHeight.constant = self.tblServices.contentSize.height
//    }

    
    @IBAction func btnBookTapped(_ sender: UIButton){
        if let cell : MusiciansServiceTVCell = sender.superview?.superview?.superview?.superview as? MusiciansServiceTVCell {
            let indexPath = tblServices.indexPath(for: cell)! as IndexPath
            
            let singerDetails = self.selectedSingerDetails?.services?[indexPath.row]
            
         
            let rowsCount = self.tblServices.numberOfRows(inSection: indexPath.section)
            for i in 0..<rowsCount  {
                let cell = self.tblServices.cellForRow(at: IndexPath(row: i, section: indexPath.section)) as! MusiciansServiceTVCell
                // your custom code (deselecting)
                
                let serviceDetails = self.selectedSingerDetails?.services?[indexPath.row]
                
                if i == indexPath.row {
                    if let service = serviceDetails {
                        self.selectedServicesData.removeAll()
                        cell.imgSelectedStatus.isHighlighted = !cell.imgSelectedStatus.isHighlighted
                        
                        if cell.imgSelectedStatus.isHighlighted{
                            self.selectedServicesData.append(service)
                        } else{
                            self.selectedServicesData.removeAll()
                        }
                    }
                } else{
                    cell.imgSelectedStatus.isHighlighted = false//!cell.imgSelectedStatus.isHighlighted
                }
                
            }
            
            // Before selection data should be set
            
            self.singer_ServicesWithHour.removeAll()
            
            let filterdSection = self.selectedSingerDetails?.services?[indexPath.row].max_hr_array?.filter({$0.title == cell.txtDropDown.text})
            
            let value : Int = self.selectedSingerDetails?.services?[indexPath.row].id ?? 0
  
            self.singer_ServicesWithHour.append(singer_Services(service_id: "\(value)", hrs: filterdSection?[0].value))
            
            
            self.onCheckboxTapAction?(self.selectedServicesData)
            self.onDDSelectionTapAction?(self.singer_ServicesWithHour)
           
        } else {
            print("not click")
        }
    }
    
    
    
}
