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
        if segue.identifier == R.segue.sheetSettingViewController.toEditTopSheet.identifier {
            if let nvc = segue.destination as? UINavigationController {
                if let vc = nvc.viewControllers.last as? EditTopSheetViewController,
                    let sheet = sender as? TopSheet {
                    vc.initializeViewModel(with: sheet)
                }
            }
        }
        if segue.identifier == R.segue.sheetSettingViewController.toEditPositionSheet.identifier {
            if let nvc = segue.destination as? UINavigationController {
                if let vc = nvc.viewControllers.last as? EditPositionSheetViewController,
                    let sheet = sender as? PositionSheet {
                    vc.initializeViewModel(with: sheet)
                }
            }
        }
        if segue.identifier == R.segue.sheetSettingViewController.toEditSubtaskSheet.identifier {
            if let nvc = segue.destination as? UINavigationController {
                if let vc = nvc.viewControllers.last as? EditSubtaskSheetViewController,
                    let sheet = sender as? SubtaskSheet {
                    vc.initializeViewModel(with: sheet)
                }
            }
        }
    }

    func initializeUI() {
    }

    func initializeViewModel() {
        sheetSettingViewModel = SheetSettingViewModel.init(with: SheetSettingUseCase(with: FBTopSheetRepository(),
                                                                                     and: FBPositionSheetRepository(),
                                                                                     and: FBSubtaskSheetRepository()),
                                                           and: SheetSettingNavigator(with: self))
    }

    func bindViewModel() {
        let input = SheetSettingViewModel.Input(loadTrigger: Driver.just(()),
                                                selectTopSheetTrigger: topSheetTable.rx.itemSelected.asDriver().map { $0.row },
                                                deleteTopSheetTrigger: topSheetTable.rx.itemDeleted.asDriver().map { $0.row },
                                                selectPositionSheetTrigger: positionSheetTable.rx.itemSelected.asDriver().map { $0.row },
                                                deletePositionSheetTrigger: positionSheetTable.rx.itemDeleted.asDriver().map { $0.row },
                                                selectSubtaskSheetTrigger: subtaskSheetTable.rx.itemSelected.asDriver().map { $0.row },
                                                deleteSubtaskSheetTrigger: subtaskSheetTable.rx.itemDeleted.asDriver().map { $0.row })

        let output = sheetSettingViewModel.transform(input: input)

        output.loadTopSheets.drive().disposed(by: disposeBag)
        output.topSheets.drive(topSheetTable.rx.items(cellIdentifier: R.reuseIdentifier.topSheetCell.identifier)) {
            (row, element, cell) in
            cell.textLabel?.text = element.name
        }.disposed(by: disposeBag)
        output.selectTopSheet.drive().disposed(by: disposeBag)
        output.deleteTopSheet.drive().disposed(by: disposeBag)

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
