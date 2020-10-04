import Foundation
import UIKit

class EditSubtaskSheetNavigator {
    private weak var viewController: EditSubtaskSheetViewController?
    private weak var parentNVC: UINavigationController?

    init(with viewController: EditSubtaskSheetViewController, and parentNVC: UINavigationController?) {
        self.viewController = viewController
        self.parentNVC = parentNVC
    }

    func toSheetSetting() {
        parentNVC?.popViewController(animated: false)
        viewController?.dismiss(animated: true)
    }
}
