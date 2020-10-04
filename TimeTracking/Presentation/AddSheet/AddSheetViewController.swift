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

    let sheetDropDown = DropDown()
    let templateDropDown = DropDown()
    let disposeBag = DisposeBag()
    let appConst = AppConst()

    var sheetType: String?
    var sheetTypeRelay = BehaviorRelay<String>(value: "")
    var sheet = Sheet()
    var topSheet = TopSheet()
    var sheetRelay = BehaviorRelay<Sheet>(value: Sheet())

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        initializeViewModel()
        bindViewModel()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.addSheetViewController.toCreateSheet.identifier {
            if let nc = segue.destination as? UINavigationController {
                if let vc = nc.viewControllers[0] as? EditSheetViewController {
                    vc.initializeViewModel(with: self.sheet, and: self.navigationController)
                }
            }
        }
        if segue.identifier == R.segue.addSheetViewController.toCreateTopSheet.identifier {
            if let nc = segue.destination as? UINavigationController {
                if let vc = nc.viewControllers[0] as? EditTopSheetViewController {
                    vc.initializeViewModel(with: self.topSheet, and: self.navigationController)
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
        addSheetViewModel = AddSheetViewModel.init(with: AddSheetUseCase(with: FireBaseSheetRepository()),
                                                           and: AddSheetNavigator(with: self))
    }

    func bindViewModel() {
        let input = AddSheetViewModel.Input(loadTemplateTrigger: sheetTypeRelay.asDriver(),
                                            createTrigger: submitButton.rx.tap.asDriver(),
                                            sheet: sheetRelay.asDriver())

        let output = addSheetViewModel.transform(input: input)
        output.create.drive().disposed(by: disposeBag)
        output.loadTemplate.drive().disposed(by: disposeBag)
        output.templates.drive(onNext: { sheet in
            self.setupTemplateDropDown(templates: sheet)
        }).disposed(by: disposeBag)
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
            self?.sheetTypeRelay.accept(self?.sheetType as! String)
            self?.sheetButton.setTitle(item, for: .normal)
            self?.changeSubmitButtonState()
        }
    }

    func setupTemplateDropDown(templates: [Sheet]) {
        templateDropDown.anchorView = templateButton
        templateDropDown.bottomOffset = CGPoint(x: 0, y: templateButton.bounds.height)
        templateDropDown.dataSource = templates.map{ template in
            return template.name
        }
        templateDropDown.selectionAction = { [weak self] (index, item) in
            self?.sheet = templates[index]
            self?.templateButton.setTitle(item, for: .normal)
        }
    }

    private func changeSubmitButtonState() {
        if (sheetNameTextField.text!.count > 0 && sheetType != nil) {
            sheet.name = sheetNameTextField.text!
            sheet.type = sheetType!
            sheetRelay.accept(sheet)
            submitButton.isEnabled = true
            submitButton.backgroundColor = UIColor(named: R.color.theme.name)
        } else {
            submitButton.isEnabled = false
            submitButton.backgroundColor = .lightGray
        }
    }
}

