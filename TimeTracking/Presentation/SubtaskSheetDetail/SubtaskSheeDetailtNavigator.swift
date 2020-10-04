import Foundation

class SubtaskSheetDetailNavigator {
    private weak var viewController: SubtaskSheetDetailViewController?
    
    init(with viewController: SubtaskSheetDetailViewController) {
        self.viewController = viewController
    }

    func toSignUp() {
         viewController?.dismiss(animated: true)
    }
}
