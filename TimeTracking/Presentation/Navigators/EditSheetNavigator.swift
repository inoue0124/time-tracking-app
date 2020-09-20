import Foundation

class EditSheetNavigator {
    private weak var viewController: EditSheetViewController?

    init(with viewController: EditSheetViewController) {
        self.viewController = viewController
    }

    func toAddSheet() {
         viewController!.dismiss(animated: true)
    }
}
