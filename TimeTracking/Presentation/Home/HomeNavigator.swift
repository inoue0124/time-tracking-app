import Foundation

class HomeNavigator {
    private weak var viewController: HomeViewController?
    let appConst = AppConst()

    init(with viewController: HomeViewController) {
        self.viewController = viewController
    }

    func toSheetDetail(with sheetType: String, and sheetId: String) {
        switch (sheetType) {
        case appConst.SHEET_TYPE_TOP:
            viewController?.performSegue(withIdentifier: R.segue.homeViewController.toTopSheetDetail, sender: sheetId)
        case appConst.SHEET_TYPE_POSITION:
            viewController?.performSegue(withIdentifier: R.segue.homeViewController.toPositionSheetDetail, sender: sheetId)
        case appConst.SHEET_TYPE_SUBTASK:
            viewController?.performSegue(withIdentifier: R.segue.homeViewController.toSubtaskSheetDetail, sender: sheetId)
        default:
            break
        }
    }

    func toSetting() {
        viewController?.performSegue(withIdentifier: R.segue.homeViewController.toSetting, sender: nil)
    }
}
