//
//  ActivityIndicatorWithLabel.swift
//  SAMRAT
//
//  Created by Mohsin Baloch on 16/06/21.
//

import Foundation

import UIKit
import ImageIO

public class ActivityIndicatorWithLabel {
    
    var containerView: UIView?
    var progressView: UIView?
    var activityIndicator = UIActivityIndicatorView()

    
    public class var shared: ActivityIndicatorWithLabel {
        struct Static {
            static let instance: ActivityIndicatorWithLabel = ActivityIndicatorWithLabel()
        }
        return Static.instance
    }
    
    var pinchImageView = UIImageView()
    
    public func showProgressView(uiView: UIView) {
        uiView.subviews.forEach { view in
            if view.layer.name == "containerView" {
                view.removeFromSuperview()
            }
        }
        
        containerView?.removeFromSuperview()
        progressView?.removeFromSuperview()
        
        containerView = UIView()
        progressView = UIView()
        //containerView.frame = CGRect(x: 0, y: 0, width: uiView.frame.width, height: uiView.frame.height)
        containerView?.backgroundColor = .clear//UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
        let imageData = NSData(contentsOf: Bundle.main.url(forResource: "loading-icon_2", withExtension: "gif")!)
        let animatedImage = UIImage.gifImageWithData(imageData as! Data)
         pinchImageView = UIImageView(image: animatedImage)
        //pinchImageView.frame = CGRect(x: 0.0, y: 0.0, width: 150.0, height: 150.0)
        progressView?.addSubview(pinchImageView)
        containerView?.addSubview(progressView!)
        uiView.addSubview(containerView!)
        containerView?.translatesAutoresizingMaskIntoConstraints = false
        containerView?.topAnchor.constraint(equalTo: uiView.topAnchor).isActive = true
        containerView?.bottomAnchor.constraint(equalTo: uiView.bottomAnchor).isActive = true
        containerView?.leftAnchor.constraint(equalTo: uiView.leftAnchor).isActive = true
        containerView?.rightAnchor.constraint(equalTo: uiView.rightAnchor).isActive = true
        
        pinchImageView.translatesAutoresizingMaskIntoConstraints = false
        pinchImageView.centerYAnchor.constraint(equalTo: containerView!.centerYAnchor).isActive = true
        pinchImageView.centerXAnchor.constraint(equalTo: containerView!.centerXAnchor).isActive = true
        pinchImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        pinchImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
//        pinchImageView.center = CGPointMake(30.0, 30.0);
        //progressView.frame = CGRect(x: 0, y: 0, width: (pinchImageView.frame.size.width), height: (pinchImageView.frame.size.height))
        progressView?.translatesAutoresizingMaskIntoConstraints = false
        progressView?.topAnchor.constraint(equalTo: uiView.topAnchor).isActive = true
        progressView?.bottomAnchor.constraint(equalTo: uiView.bottomAnchor).isActive = true
        progressView?.heightAnchor.constraint(equalToConstant: 150).isActive = true
        progressView?.widthAnchor.constraint(equalToConstant: 150).isActive = true

        containerView?.layer.name = "containerView"
    }
    
    public func hideProgressView() {
        activityIndicator.stopAnimating()
        pinchImageView.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        progressView?.removeFromSuperview()
        containerView?.removeFromSuperview()
    }
    
    public func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}


// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}



extension UIImage {
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL? = URL(string: gifUrl)
            else {
                print("image named \(gifUrl) doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL!) else {
            print("image named \(gifUrl) into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \(name) does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \(name) into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)
        
        return animation
    }
}
