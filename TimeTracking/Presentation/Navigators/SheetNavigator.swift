import Foundation

class SheetNavigator {
    private weak var viewController: SheetViewController?
    
    init(with viewController: SheetViewController) {
        self.viewController = viewController
    }

    func toSignUp() {
         viewController?.dismiss(animated: true)
    }
}
