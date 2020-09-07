import Foundation

class SignUpNavigator {
    private weak var viewController: SignUpViewController?
    
    init(with viewController: SignUpViewController) {
        self.viewController = viewController
    }
    
    func toLogin() {
        viewController?.performSegue(withIdentifier: R.segue.signUpViewController.toLogin, sender: nil)
    }
    
    func toHome() {
        viewController?.performSegue(withIdentifier: R.segue.signUpViewController.toHome, sender: nil)
    }
}
