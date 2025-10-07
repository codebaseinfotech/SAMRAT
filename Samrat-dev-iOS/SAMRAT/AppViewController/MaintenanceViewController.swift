//
//  MaintenanceViewController.swift
//  SAMRAT
//
//  Created by Macbook on 18/04/22.
//

import UIKit

class MaintenanceViewController: UIViewController {
    
    
    @IBOutlet weak var lblSorry: UILabel!
    @IBOutlet weak var lblUnderMaintenance: UILabel!
    @IBOutlet weak var viewWA: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
        
        if Language.shared.isArabic == true {
            lblSorry.text = "نأسف"
            lblUnderMaintenance.text = " نعمل حاليا على صيانة التطبيق .  سيتم تشغيل التطبيق في اسرع وقت ممكن."
        } else{
            lblSorry.text = "Sorry"
            lblUnderMaintenance.text = "Our servers now under maintenance. We will be back shortly."
        }
        // Do any additional setup after loading the view.
    }
    @IBAction func clickedWA(_ sender: Any) {
        print("Buttom tapped")
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
