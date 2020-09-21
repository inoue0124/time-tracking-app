import UIKit
import RxSwift
import RxCocoa
import DropDown

class SheetSettingViewController: UIViewController {

    @IBOutlet weak var topSheetTable: UITableView!
    @IBOutlet weak var positionSheetTable: UITableView!
    @IBOutlet weak var subtaskSheetTable: UITableView!

    var sheetSettingViewModel: SheetSettingViewModel!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        initializeViewModel()
        bindViewModel()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.sheetSettingViewController.toEditSheet.identifier {
            if let nvc = segue.destination as? UINavigationController {
                if let vc = nvc.viewControllers.last as? EditSheetViewController,
                    let sheet = sender as? Sheet {
                    vc.initializeViewModel(with: sheet)
                }
            }
        }
    }

    func initializeUI() {
    }

    func initializeViewModel() {
        sheetSettingViewModel = SheetSettingViewModel.init(with: SheetSettingUseCase(with: FireBaseSheetRepository()),
                                                           and: SheetSettingNavigator(with: self))
    }

    func bindViewModel() {
        let input = SheetSettingViewModel.Input(loadTrigger: Driver.just(()),
                                                selectPositionSheetTrigger: positionSheetTable.rx.itemSelected.asDriver().map { $0.row },
                                                deletePositionSheetTrigger: positionSheetTable.rx.itemDeleted.asDriver().map { $0.row },
                                                selectSubtaskSheetTrigger: subtaskSheetTable.rx.itemSelected.asDriver().map { $0.row },
                                                deleteSubtaskSheetTrigger: subtaskSheetTable.rx.itemDeleted.asDriver().map { $0.row })

        let output = sheetSettingViewModel.transform(input: input)
        output.loadPositionSheets.drive().disposed(by: disposeBag)
        output.positionSheets.drive(positionSheetTable.rx.items(cellIdentifier: R.reuseIdentifier.positionSheetCell.identifier)) {
            (row, element, cell) in
            cell.textLabel?.text = element.name
        }.disposed(by: disposeBag)
        output.selectPositionSheet.drive().disposed(by: disposeBag)
        output.deletePositionSheet.drive().disposed(by: disposeBag)

        output.loadSubtaskSheets.drive().disposed(by: disposeBag)
        output.subtaskSheets.drive(subtaskSheetTable.rx.items(cellIdentifier: R.reuseIdentifier.subtaskSheetCell.identifier)) {
            (row, element, cell) in
            cell.textLabel?.text = element.name
        }.disposed(by: disposeBag)
        output.selectSubtaskSheet.drive().disposed(by: disposeBag)
        output.deleteSubtaskSheet.drive().disposed(by: disposeBag)

    }
}
