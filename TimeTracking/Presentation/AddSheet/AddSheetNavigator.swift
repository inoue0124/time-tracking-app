import Foundation

class AddSheetNavigator {
    
    private weak var viewController: AddSheetViewController?
    let appConst = AppConst()

    init(with viewController: AddSheetViewController) {
        self.viewController = viewController
    }

    func toCreateSheet(with sheetType: String) {
        switch (sheetType) {
        case appConst.SHEET_TYPE_TOP:
            viewController?.performSegue(withIdentifier: R.segue.addSheetViewController.toCreateTopSheet, sender: nil)
        case appConst.SHEET_TYPE_POSITION:
            viewController?.performSegue(withIdentifier: R.segue.addSheetViewController.toCreatePositionSheet, sender: nil)
        case appConst.SHEET_TYPE_SUBTASK:
            viewController?.performSegue(withIdentifier: R.segue.addSheetViewController.toCreateSubtaskSheet, sender: nil)
        default:
            break
        }
    }
}
