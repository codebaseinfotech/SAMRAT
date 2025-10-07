import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tabBar.items?.first?.title = Localized("singers")
        self.tabBar.items?[1].title = Localized("musicians")
        self.tabBar.items?[2].title = Localized("gallery")
        self.tabBar.items?[3].title = Localized("settings")   
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let vcc = viewControllers?.first(where: { $0 is MusiciansViewController }) as? MusiciansViewController else { return }
        vcc.playPauseAudio(isPlaying: false)
        if let index = vcc.previousSelectedIndexPath {
            vcc.changePlayingParameter(indexPath: index, isPlay: false)
            vcc.previousSelectedIndexPath = nil
        }
    }
}
