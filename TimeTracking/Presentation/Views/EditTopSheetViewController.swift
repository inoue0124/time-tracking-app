import UIKit
import RxSwift
import RxCocoa
import DropDown

class EditTopSheetViewController: UIViewController {
    
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    @IBOutlet weak var addSheetButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var daysButton: UIButton!
    @IBOutlet weak var sheetNameTextField: UITextField!

    var editTopSheetViewModel: EditTopSheetViewModel!

    let daysDropdown = DropDown()
    let positionSheetsDropDown = DropDown()
    let disposeBag = DisposeBag()

    var topSheet: TopSheet = TopSheet()
    var sheetRelay = BehaviorRelay<TopSheet>(value: TopSheet())

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        initializeViewModel()
        bindViewModel()
    }

    func initializeUI() {
        setupDaysDropDown()
        dismissButton.rx.tap.subscribe { [unowned self] _ in
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        daysButton.rx.tap.subscribe { [unowned self] _ in
            self.daysDropdown.show()
        }.disposed(by: disposeBag)
        addSheetButton.rx.tap.subscribe { [unowned self] _ in
            self.positionSheetsDropDown.show()
        }.disposed(by: disposeBag)
        sheetNameTextField.rx.text.subscribe(onNext: { _ in
            self.changeSubmitButtonState()
        }).disposed(by: disposeBag)
    }

    func initializeViewModel(with topSheet: TopSheet? = nil, and nvc: UINavigationController? = nil) {
        guard editTopSheetViewModel == nil else { return }
        editTopSheetViewModel = EditTopSheetViewModel(with: EditTopSheetUseCase(with: FireBaseTopSheetRepository(), and: FireBaseSheetRepository()),
                                                and: EditTopSheetNavigator(with: self, and: nvc),
                                                and: topSheet)
    }

    func bindViewModel() {
        let input = EditTopSheetViewModel.Input(loadTrigger: Driver.just(()),
                                                saveTrigger: saveButton.rx.tap.asDriver(),
                                                topSheet: sheetRelay.asDriver())
        let output = editTopSheetViewModel.transform(input: input)
        output.load.drive().disposed(by: disposeBag)
        output.positionSheets.drive(onNext: { pSheets in
            self.setupPositionSheetsDropDown(positionSheets: pSheets)
        }).disposed(by: disposeBag)
        output.save.drive().disposed(by: disposeBag)
    }

    func setupDaysDropDown() {
        daysDropdown.anchorView = daysButton
        daysDropdown.bottomOffset = CGPoint(x: 0, y: daysButton.bounds.height)
        daysDropdown.dataSource = ["月", "火", "水", "木", "金/祝前", "土", "日/祝"]
        daysDropdown.multiSelectionAction = { [weak self] (indices, items) in

            let itemsString = indices.sorted().map{ index in
                (self?.daysDropdown.dataSource[index])!
            }.joined(separator: "/")

            self?.daysButton.setTitle(itemsString, for: .normal)

            if items.isEmpty {
                self?.daysButton.setTitle("選択してください", for: .normal)
            }

        }
    }

    func setupPositionSheetsDropDown(positionSheets: [Sheet]) {
        positionSheetsDropDown.anchorView = addSheetButton
        positionSheetsDropDown.bottomOffset = CGPoint(x: 0, y: addSheetButton.bounds.height)
        positionSheetsDropDown.dataSource = positionSheets.map{ sheet in
            return sheet.name
        }
        positionSheetsDropDown.multiSelectionAction = { [weak self] (indices, items) in
            let itemsString = indices.sorted().map{ index in
                (self?.positionSheetsDropDown.dataSource[index])!
            }.joined(separator: "/")

            self?.addSheetButton.setTitle(itemsString, for: .normal)

            self?.topSheet.positionSheetIds = indices.sorted().map{ index in
                positionSheets[index].id
            }
            self?.changeSubmitButtonState()

            if items.isEmpty {
                self?.addSheetButton.setTitle("+", for: .normal)
            }

        }
    }

    private func changeSubmitButtonState() {
        if (sheetNameTextField.text!.count > 0) {
            topSheet.name = sheetNameTextField.text!
            sheetRelay.accept(topSheet)
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }

}
