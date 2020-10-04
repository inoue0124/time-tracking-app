import Foundation

class TopSheetDetailNavigator {
    private weak var viewController: TopSheetDetailViewController?
    
    init(with viewController: TopSheetDetailViewController) {
        self.viewController = viewController
    }

    func toSignUp() {
         viewController?.dismiss(animated: true)
    }
}
