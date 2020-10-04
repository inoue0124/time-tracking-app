import Foundation
import UIKit

class EditPositionSheetNavigator {
    private weak var viewController: EditPositionSheetViewController?
    private weak var parentNVC: UINavigationController?

    init(with viewController: EditPositionSheetViewController, and parentNVC: UINavigationController?) {
        self.viewController = viewController
        self.parentNVC = parentNVC
    }

    func toSheetSetting() {
        parentNVC?.popViewController(animated: false)
        viewController?.dismiss(animated: true)
    }
}
