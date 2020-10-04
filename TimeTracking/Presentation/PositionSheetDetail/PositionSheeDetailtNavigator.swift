import Foundation

class PositionSheetDetailNavigator {
    private weak var viewController: PositionSheetDetailViewController?
    
    init(with viewController: PositionSheetDetailViewController) {
        self.viewController = viewController
    }

    func toSignUp() {
         viewController?.dismiss(animated: true)
    }
}
