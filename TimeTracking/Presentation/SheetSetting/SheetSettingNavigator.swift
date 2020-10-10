import Foundation

class SheetSettingNavigator {

    private weak var viewController: SheetSettingViewController?
    let appConst = AppConst()

    init(with viewController: SheetSettingViewController) {
        self.viewController = viewController
    }

    func toEditSheet(with sheetType: String, and sheetId: String) {
        switch (sheetType) {
        case appConst.SHEET_TYPE_TOP:
            viewController?.performSegue(withIdentifier: R.segue.sheetSettingViewController.toEditTopSheet, sender: sheetId)
        case appConst.SHEET_TYPE_POSITION:
            viewController?.performSegue(withIdentifier: R.segue.sheetSettingViewController.toEditPositionSheet, sender: sheetId)
        case appConst.SHEET_TYPE_SUBTASK:
            viewController?.performSegue(withIdentifier: R.segue.sheetSettingViewController.toEditSubtaskSheet, sender: sheetId)
        default:
            break
        }
    }
}
