import Foundation
import UIKit

class EditSheetNavigator {
    private weak var viewController: EditSheetViewController?
    private weak var parentNVC: UINavigationController?

    init(with viewController: EditSheetViewController, and parentNVC: UINavigationController?) {
        self.viewController = viewController
        self.parentNVC = parentNVC
    }

    func toAddSheet() {
        parentNVC?.popViewController(animated: false)
        viewController?.dismiss(animated: true)
    }
}
