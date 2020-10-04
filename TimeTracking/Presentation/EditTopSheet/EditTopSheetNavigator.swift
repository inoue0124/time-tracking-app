import Foundation
import UIKit

class EditTopSheetNavigator {
    private weak var viewController: EditTopSheetViewController?
    private weak var parentNVC: UINavigationController?

    init(with viewController: EditTopSheetViewController, and parentNVC: UINavigationController?) {
        self.viewController = viewController
        self.parentNVC = parentNVC
    }

    func toSheetSetting() {
        parentNVC?.popViewController(animated: false)
        viewController?.dismiss(animated: true)
    }
}
