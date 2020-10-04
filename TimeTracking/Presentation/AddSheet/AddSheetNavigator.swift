import Foundation

class AddSheetNavigator {
    private weak var viewController: AddSheetViewController?

    init(with viewController: AddSheetViewController) {
        self.viewController = viewController
    }

    func toCreateTopSheet() {
        viewController?.performSegue(withIdentifier: R.segue.addSheetViewController.toCreateTopSheet, sender: nil)
    }

    func toCreatePositionSheet(with sheet: Sheet? = nil) {
        viewController?.performSegue(withIdentifier: R.segue.addSheetViewController.toCreatePositionSheet, sender: sheet)
    }

    func toCreateSubtaskSheet(with sheet: Sheet? = nil) {
        viewController?.performSegue(withIdentifier: R.segue.addSheetViewController.toCreateSubtaskSheet, sender: sheet)
    }
}
