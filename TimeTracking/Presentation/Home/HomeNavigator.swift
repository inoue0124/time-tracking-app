import Foundation

class HomeNavigator {
    private weak var viewController: HomeViewController?

    init(with viewController: HomeViewController) {
        self.viewController = viewController
    }

    func toSheetDetail(with sheet: Sheet? = nil) {
        viewController?.performSegue(withIdentifier: R.segue.homeViewController.toSheetDetail, sender: sheet)
    }

    func toSetting() {
        viewController?.performSegue(withIdentifier: R.segue.homeViewController.toSetting, sender: nil)
    }
}
