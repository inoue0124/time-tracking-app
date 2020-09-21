import UIKit
import RxSwift
import RxCocoa
import DropDown

class AddSheetViewController: UIViewController {

    @IBOutlet weak var sheetButton: UIButton!
    @IBOutlet weak var templateButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var sheetNameTextField: UITextField!

    let sheetDropDown = DropDown()
    let disposeBag = DisposeBag()

    var sheetName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
//        initializeViewModel()
//        bindViewModel()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.addSheetViewController.toCreateSheet.identifier {
            sheetName = sheetNameTextField.text
            if let nc = segue.destination as? UINavigationController {
                if let vc = nc.viewControllers[0] as? EditSheetViewController {
                    vc.sheetName = sheetName
                }
            }
        }
    }


    func initializeUI() {
        setupSheetDropDown()
        sheetButton.rx.tap.subscribe { [unowned self] _ in
            self.sheetDropDown.show()
        }.disposed(by: disposeBag)
        submitButton.rx.tap.subscribe { [unowned self] _ in
            self.performSegue(withIdentifier: R.segue.addSheetViewController.toCreateSheet.identifier, sender: nil)
        }.disposed(by: disposeBag)
        sheetNameTextField.rx.text.subscribe(onNext: { _ in
            self.changeSubmitButtonState()
        }).disposed(by: disposeBag)
    }


    func setupDropDowns() {
        setupSheetDropDown()
    }

    func setupSheetDropDown() {
        sheetDropDown.anchorView = sheetButton
        sheetDropDown.bottomOffset = CGPoint(x: 0, y: sheetButton.bounds.height)
        sheetDropDown.dataSource = [
            "TOPシート",
            "ポジションシート",
            "サブタスクシート"
        ]
        sheetDropDown.selectionAction = { [weak self] (index, item) in
            self?.sheetButton.setTitle(item, for: .normal)
        }
    }

    private func changeSubmitButtonState() {
        if sheetNameTextField.text!.count > 0 {
            submitButton.isEnabled = true
            submitButton.backgroundColor = UIColor(named: R.color.theme.name)
        } else {
            submitButton.isEnabled = false
            submitButton.backgroundColor = .lightGray
        }
    }
}

