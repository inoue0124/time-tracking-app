import UIKit
import RxSwift
import RxCocoa

class SignUpViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    var signUpViewModel: SignUpViewModel!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        initializeViewModel()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func initializeUI() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true

    }

    func initializeViewModel() {
        signUpViewModel = SignUpViewModel.init(with: SignUpUseCase(with: FBAuthRepository()),
                                               and: SignUpNavigator(with: self))
    }
    
    func bindViewModel() {
        let input = SignUpViewModel.Input(checkLoginTrigger: rx.sentMessage(#selector(viewWillAppear(_:)))
                                            .map { _ in () }
                                            .asDriver(onErrorJustReturn: ()),
                                          loginTrigger: loginButton.rx.tap.asDriver(),
                                          signUpTrigger: signUpButton.rx.tap.asDriver(),
                                          email: emailTextField.rx.text
                                            .map { if let t = $0 { return t } else { return "" } }
                                            .asDriver(onErrorJustReturn: ""),
                                          password: passwordTextField.rx.text
                                            .map { if let t = $0 { return t } else { return "" } }
                                            .asDriver(onErrorJustReturn: "").asDriver())
        let output = signUpViewModel.transform(input: input)
        output.checkLogin.drive().disposed(by: disposeBag)
        output.login.drive().disposed(by: disposeBag)
        output.signUp.drive().disposed(by: disposeBag)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
