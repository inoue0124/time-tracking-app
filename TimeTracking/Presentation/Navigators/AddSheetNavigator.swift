import Foundation

class AddSheetNavigator {
    private weak var viewController: AddSheetViewController?

    init(with viewController: AddSheetViewController) {
        self.viewController = viewController
    }

    func toCreateSheet(with sheet: Sheet? = nil) {
        viewController?.performSegue(withIdentifier: R.segue.addSheetViewController.toCreateSheet, sender: sheet)
    }

    func toCreateTopSheet() {
        viewController?.performSegue(withIdentifier: R.segue.addSheetViewController.toCreateTopSheet, sender: nil)
    }
}
