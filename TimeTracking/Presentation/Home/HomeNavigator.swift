import Foundation

class HomeNavigator {
    private weak var viewController: HomeViewController?

    init(with viewController: HomeViewController) {
        self.viewController = viewController
    }

    func toTopSheetDetail(with sheet: TopSheet? = nil) {
        viewController?.performSegue(withIdentifier: R.segue.homeViewController.toTopSheetDetail, sender: sheet)
    }

    func toPositionSheetDetail(with sheet: PositionSheet? = nil) {
        viewController?.performSegue(withIdentifier: R.segue.homeViewController.toPositionSheetDetail, sender: sheet)
    }

    func toSubtaskSheetDetail(with sheet: SubtaskSheet? = nil) {
        viewController?.performSegue(withIdentifier: R.segue.homeViewController.toSubtaskSheetDetail, sender: sheet)
    }

    func toSetting() {
        viewController?.performSegue(withIdentifier: R.segue.homeViewController.toSetting, sender: nil)
    }
}
