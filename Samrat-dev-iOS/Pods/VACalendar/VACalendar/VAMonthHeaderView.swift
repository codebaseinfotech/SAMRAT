import UIKit

public protocol VAMonthHeaderViewDelegate: class {
    func didTapNextMonth()
    func didTapPreviousMonth()
    func currentmonthdate(date: Date)
}

public struct VAMonthHeaderViewAppearance {
    
    let monthFont: UIFont
    let monthTextColor: UIColor
    let monthTextWidth: CGFloat
    let previousButtonImage: UIImage
    let nextButtonImage: UIImage
    let dateFormatter: DateFormatter
    
    static public let defaultFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    
    public init(
        monthFont: UIFont = UIFont.systemFont(ofSize: 21),
        monthTextColor: UIColor = UIColor.white,
        monthTextWidth: CGFloat = 150,
        previousButtonImage: UIImage = UIImage(),
        nextButtonImage: UIImage = UIImage(),
        dateFormatter: DateFormatter = VAMonthHeaderViewAppearance.defaultFormatter) {
        self.monthFont = monthFont
        self.monthTextColor = monthTextColor
        self.monthTextWidth = monthTextWidth
        self.previousButtonImage = previousButtonImage
        self.nextButtonImage = nextButtonImage
        self.dateFormatter = dateFormatter
    }
    
}

public class VAMonthHeaderView: UIView {
    
    public var appearance = VAMonthHeaderViewAppearance() {
        didSet {
            dateFormatter = appearance.dateFormatter
            setupView()
        }
    }
    
    public weak var delegate: VAMonthHeaderViewDelegate?
    
    private var dateFormatter = DateFormatter()
    private let monthLabel = UILabel()
    private let previousButton = UIButton()
    private let nextButton = UIButton()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonWidth: CGFloat = 30.0
        monthLabel.frame = CGRect(x: 0, y: 0, width: appearance.monthTextWidth, height: frame.height)
        monthLabel.center.x = center.x
        previousButton.frame = CGRect(x: frame.minX + 10, y: 10, width: buttonWidth, height: buttonWidth)
        nextButton.frame = CGRect(x: frame.maxX - 10 - buttonWidth, y: 10, width: buttonWidth, height: buttonWidth)
    }
    
    private func setupView() {
        subviews.forEach{ $0.removeFromSuperview() }
        
        backgroundColor = .white
        monthLabel.font = appearance.monthFont
        monthLabel.textAlignment = .center
        monthLabel.textColor = appearance.monthTextColor
        
        previousButton.setImage(appearance.previousButtonImage, for: .normal)
        previousButton.addTarget(self, action: #selector(didTapPrevious(_:)), for: .touchUpInside)
        
        nextButton.setImage(appearance.nextButtonImage, for: .normal)
        nextButton.addTarget(self, action: #selector(didTapNext(_:)), for: .touchUpInside)
        
        let dF = DateFormatter()
        dF.dateFormat = "MMMM"

        // Gregorian to Hijri
//        dF.locale = NSLocale(localeIdentifier: "ar") as Locale
//        let islamic = NSCalendar(identifier: NSCalendar.Identifier.islamicUmmAlQura)
        
        let currentMonth = Date()
//        let components = islamic?.components(NSCalendar.Unit(rawValue: UInt.max), from: currentMonth)
        if UserDefaults.standard.bool(forKey: "ar") == true {
            dateFormatter.dateFormat = "MMMM"
//            monthLabel.text = dateFormatter.string(from: currentMonth) + "\n" + dF.string(from: currentMonth) + " " + "\(components?.year ?? 0)"
            monthLabel.text = dF.string(from: currentMonth)// + " " + "\(components?.year ?? 0)".uppercased()
            monthLabel.numberOfLines = 0
        }else {
            dateFormatter.dateFormat = "MMMM"
            monthLabel.text = dateFormatter.string(from: currentMonth).uppercased() //+ "\n" + dF.string(from: currentMonth) + " " + "\(components?.year ?? 0)"
            monthLabel.numberOfLines = 0
        }
    
        
        addSubview(monthLabel)
        addSubview(previousButton)
        addSubview(nextButton)
        
        layoutSubviews()
    }
    
    @objc
    private func didTapNext(_ sender: UIButton) {
        delegate?.didTapNextMonth()
    }
    
    @objc
    private func didTapPrevious(_ sender: UIButton) {
        delegate?.didTapPreviousMonth()
    }
    
}

extension VAMonthHeaderView: VACalendarMonthDelegate {
    
    public func monthDidChange(_ currentMonth: Date) {
//        monthLabel.text = dateFormatter.string(from: currentMonth)
        let dF = DateFormatter()
        dF.dateFormat = "MMMM"

        // Gregorian to Hijri
//        dF.locale = NSLocale(localeIdentifier: "ar") as Locale
//        formatter.locale = NSLocale(localeIdentifier: "ar_SA")
//        let islamic = NSCalendar(identifier: NSCalendar.Identifier.islamicUmmAlQura)
//        let components = islamic?.components(NSCalendar.Unit(rawValue: UInt.max), from: currentMonth)
        
//        let sWesternArabic = "\(components?.month ?? 0) \(components?.year ?? 0)"
//        let substituteEasternArabic = ["0":"٠", "1":"١", "2":"٢", "3":"٣", "4":"٤", "5":"٥", "6":"٦", "7":"٧", "8":"٨", "9":"٩"]
//        var sEasternArabic =  ""
//        for i in sWesternArabic {
//            if let subs = substituteEasternArabic[String(i)] { // String(i) needed as i is a character
//                sEasternArabic += subs
//            } else {
//                sEasternArabic += String(i)
//            }
//        }
        
        if UserDefaults.standard.bool(forKey: "ar") == true {
            dateFormatter.dateFormat = "MMMM"
//            monthLabel.text = dateFormatter.string(from: currentMonth) + "\n" + dF.string(from: currentMonth) + " " + "\(components?.year ?? 0)"
            monthLabel.text = dF.string(from: currentMonth)// + " " + "\(components?.year ?? 0)".uppercased()
            monthLabel.numberOfLines = 0
            delegate?.currentmonthdate(date: currentMonth)
        }else {
            dateFormatter.dateFormat = "MMMM"
            monthLabel.text = dateFormatter.string(from: currentMonth).uppercased() //+ "\n" + dF.string(from: currentMonth) + " " + "\(components?.year ?? 0)"
            monthLabel.numberOfLines = 0
            delegate?.currentmonthdate(date: currentMonth)
        }
    }
}
