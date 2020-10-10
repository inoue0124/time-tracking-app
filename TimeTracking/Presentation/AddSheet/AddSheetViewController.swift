import UIKit
import RxSwift
import RxCocoa
import DropDown

class AddSheetViewController: UIViewController {

    @IBOutlet weak var sheetButton: UIButton!
    @IBOutlet weak var templateButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var sheetNameTextField: UITextField!

    var addSheetViewModel: AddSheetViewModel!
    let disposeBag = DisposeBag()
    let appConst = AppConst()

    let sheetDropDown = DropDown()
    let templateDropDown = DropDown()

    var sheetType: String?
    var sheetTypeRelay = BehaviorRelay<String>(value: "")
    var sheetId: String?
    var sheetIdRelay = BehaviorRelay<String>(value: "")
    var sheetName: String?
    var sheetNameRelay = BehaviorRelay<String>(value: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        initializeViewModel()
        bindViewModel()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.addSheetViewController.toCreateTopSheet.identifier {
            if let nc = segue.destination as? UINavigationController {
                if let vc = nc.viewControllers[0] as? EditTopSheetViewController {
                    vc.initializeViewModel(with: sheetId, and: sheetName, and: self.navigationController)
                }
            }
        }
        if segue.identifier == R.segue.addSheetViewController.toCreatePositionSheet.identifier {
            if let nc = segue.destination as? UINavigationController {
                if let vc = nc.viewControllers[0] as? EditPositionSheetViewController {
                    vc.initializeViewModel(with: sheetId, and: sheetName, and: self.navigationController)
                }
            }
        }
        if segue.identifier == R.segue.addSheetViewController.toCreateSubtaskSheet.identifier {
            if let nc = segue.destination as? UINavigationController {
                if let vc = nc.viewControllers[0] as? EditSubtaskSheetViewController {
                    vc.initializeViewModel(with: sheetId, and: sheetName, and: self.navigationController)
                }
            }
        }
    }


    func initializeUI() {
        setupSheetDropDown()
        sheetButton.rx.tap.subscribe { [unowned self] _ in
            self.sheetDropDown.show()
        }.disposed(by: disposeBag)
        templateButton.rx.tap.subscribe { [unowned self] _ in
            self.templateDropDown.show()
        }.disposed(by: disposeBag)
        sheetNameTextField.rx.text.subscribe(onNext: { _ in
            self.changeSubmitButtonState()
        }).disposed(by: disposeBag)
    }

    func initializeViewModel() {
        addSheetViewModel = AddSheetViewModel.init(
            with: AddSheetUseCase(with: FBTemplateRepository()), and: AddSheetNavigator(with: self)
        )
    }

    func bindViewModel() {
        let input = AddSheetViewModel.Input(loadTemplateTrigger: sheetTypeRelay.asDriver(),
                                            sheetType: sheetTypeRelay.asDriver(),
                                            createTrigger: submitButton.rx.tap.asDriver())

        let output = addSheetViewModel.transform(input: input)
        output.loadTemplate.drive().disposed(by: disposeBag)
        output.templates.drive(onNext: { templates in
            self.setupTemplateDropDown(templates: templates)
        }).disposed(by: disposeBag)
        output.create.drive().disposed(by: disposeBag)
    }

    func setupSheetDropDown() {
        sheetDropDown.anchorView = sheetButton
        sheetDropDown.bottomOffset = CGPoint(x: 0, y: sheetButton.bounds.height)
        sheetDropDown.dataSource = [
            appConst.SHEET_TYPE_TOP_DISPLAY,
            appConst.SHEET_TYPE_POSITION_DISPLAY,
            appConst.SHEET_TYPE_SUBTASK_DISPLAY,
        ]
        sheetDropDown.selectionAction = { [weak self] (index, item) in
            switch (item) {
            case self?.appConst.SHEET_TYPE_TOP_DISPLAY:
                self?.sheetType = self?.appConst.SHEET_TYPE_TOP
            case self?.appConst.SHEET_TYPE_POSITION_DISPLAY:
                self?.sheetType = self?.appConst.SHEET_TYPE_POSITION
            case self?.appConst.SHEET_TYPE_SUBTASK_DISPLAY:
                self?.sheetType = self?.appConst.SHEET_TYPE_SUBTASK
            default:
                break
            }
            self?.sheetButton.setTitle(item, for: .normal)
            self?.sheetTypeRelay.accept(self?.sheetType! ?? "")
            self?.changeSubmitButtonState()
        }
    }

    func setupTemplateDropDown(templates: [Sheet]) {
        templateDropDown.anchorView = templateButton
        templateDropDown.bottomOffset = CGPoint(x: 0, y: templateButton.bounds.height)
        templateDropDown.dataSource = templates.map{ sheet in
            return sheet.name
        }
        templateDropDown.selectionAction = { [weak self] (index, item) in
            self?.templateButton.setTitle(item, for: .normal)
            self?.sheetId = templates[index].id
            self?.sheetIdRelay.accept(self?.sheetId! ?? "")
        }
    }

    private func changeSubmitButtonState() {
        if (sheetNameTextField.text!.count > 0 && sheetType != nil) {
            sheetName = sheetNameTextField.text!
            sheetNameRelay.accept(sheetName!)
            submitButton.isEnabled = true
            submitButton.backgroundColor = UIColor(named: R.color.theme.name)
        } else {
            submitButton.isEnabled = false
            submitButton.backgroundColor = .lightGray
        }
    }
}

