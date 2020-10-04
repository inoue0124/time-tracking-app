import Foundation

class SheetSettingNavigator {
    private weak var viewController: SheetSettingViewController?

    init(with viewController: SheetSettingViewController) {
        self.viewController = viewController
    }

    func toEditSheet(with sheet: Sheet? = nil) {
        assert(sheet != nil)
        viewController?.performSegue(withIdentifier: R.segue.sheetSettingViewController.toEditSubtaskSheet, sender: sheet)
    }
}
