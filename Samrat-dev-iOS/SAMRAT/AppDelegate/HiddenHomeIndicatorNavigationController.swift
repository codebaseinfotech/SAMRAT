//
//  HiddenHomeIndicatorNavigationController.swift
//  SAMRAT
//

import UIKit

class HiddenHomeIndicatorNavigationController: UINavigationController {

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    override var childForHomeIndicatorAutoHidden: UIViewController? {
        return topViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
}
