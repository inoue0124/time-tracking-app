import Foundation

class SheetSettingNavigator {
    private weak var viewController: SheetSettingViewController?

    init(with viewController: SheetSettingViewController) {
        self.viewController = viewController
    }

    func toEditTopSheet(with sheet: TopSheet? = nil) {
        assert(sheet != nil)
        viewController?.performSegue(withIdentifier: R.segue.sheetSettingViewController.toEditTopSheet, sender: sheet)
    }

    func toEditPositionSheet(with sheet: PositionSheet? = nil) {
        assert(sheet != nil)
        viewController?.performSegue(withIdentifier: R.segue.sheetSettingViewController.toEditPositionSheet, sender: sheet)
    }

    func toEditSubtaskSheet(with sheet: SubtaskSheet? = nil) {
        assert(sheet != nil)
        viewController?.performSegue(withIdentifier: R.segue.sheetSettingViewController.toEditSubtaskSheet, sender: sheet)
    }
}
