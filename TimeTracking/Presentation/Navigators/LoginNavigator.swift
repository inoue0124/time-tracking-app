import Foundation

class LoginNavigator {
    private weak var viewController: LoginViewController?
    
    init(with viewController: LoginViewController) {
        self.viewController = viewController
    }
    
    func toHome() {
        viewController?.performSegue(withIdentifier: R.segue.loginViewController.toHome, sender: nil)
    }
}
