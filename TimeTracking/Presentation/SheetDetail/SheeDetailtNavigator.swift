import Foundation

class SheetDetailNavigator {
    private weak var viewController: SheetDetailViewController?
    
    init(with viewController: SheetDetailViewController) {
        self.viewController = viewController
    }

    func toSignUp() {
         viewController?.dismiss(animated: true)
    }
}
