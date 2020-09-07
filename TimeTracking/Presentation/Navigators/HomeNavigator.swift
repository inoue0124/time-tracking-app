import Foundation

class HomeNavigator {
    private weak var viewController: HomeViewController?

    init(with viewController: HomeViewController) {
        self.viewController = viewController
    }

    func toTaskList(with positionSheet: Sheet? = nil) {
        viewController?.performSegue(withIdentifier: R.segue.homeViewController.toTaskList, sender: positionSheet)
    }

    func toSetting() {
        viewController?.performSegue(withIdentifier: R.segue.homeViewController.toSetting, sender: nil)
    }
}
