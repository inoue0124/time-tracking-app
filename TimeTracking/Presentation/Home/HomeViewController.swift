import UIKit
import RxSwift
import RxCocoa
import DropDown

class HomeViewController: UIViewController {

    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var topSheetTable: UITableView!
    @IBOutlet weak var subtaskSheetTable: UITableView!

    var homeViewModel: HomeViewModel!

    let disposeBag = DisposeBag()
    let dropDown = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        initializeViewModel()
        bindViewModel()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.homeViewController.toPositionSheetDetail.identifier {
            if let vc = segue.destination as? PositionSheetDetailViewController,
                let sheet = sender as? PositionSheet {
                vc.initializeViewModel(with: sheet)
            }
        }
        if segue.identifier == R.segue.homeViewController.toSubtaskSheetDetail.identifier {
            if let vc = segue.destination as? SubtaskSheetDetailViewController,
                let sheet = sender as? SubtaskSheet {
                vc.initializeViewModel(with: sheet)
            }
        }
    }

    func initializeUI() {
        dateButton.layer.borderColor = UIColor(named: R.color.theme.name)?.cgColor
        dateButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        let f = DateFormatter()
        f.timeStyle = .none
        f.dateStyle = .long
        f.locale = Locale(identifier: "ja_JP")
        dateButton.setTitle(f.string(from: Date()), for: .normal)
        dropDown.anchorView = menuBarButton
        dropDown.dataSource = ["設定", "ホーム"]
        dropDown.bottomOffset = CGPoint(x: 0, y: 40)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if (item == "設定") {
                self.homeViewModel.navigator.toSetting()
            }
        }
        menuBarButton.rx.tap.subscribe { [unowned self] _ in
            self.dropDown.show()
        }.disposed(by: disposeBag)
    }

    func initializeViewModel() {
        homeViewModel = HomeViewModel.init(with: HomeUseCase(with: FBTopSheetRepository(),
                                                             and: FBPositionSheetRepository(),
                                                             and: FBSubtaskSheetRepository()),
                                           and: HomeNavigator(with: self))
    }

    func bindViewModel() {
        let input = HomeViewModel.Input(loadTrigger: Driver.just(()),
                                        selectTopSheetTrigger: topSheetTable.rx.itemSelected.asDriver().map { $0.row },
                                        selectSubtaskSheetTrigger: subtaskSheetTable.rx.itemSelected.asDriver().map { $0.row })

        let output = homeViewModel.transform(input: input)
        output.loadTopSheets.drive().disposed(by: disposeBag)
        output.topSheets.drive(topSheetTable.rx.items(cellIdentifier: R.reuseIdentifier.topSheetCell.identifier)) {
            (row, element, cell) in
            cell.textLabel?.text = element.name
        }.disposed(by: disposeBag)
        output.selectTopSheet.drive().disposed(by: disposeBag)

        output.loadSubtaskSheets.drive().disposed(by: disposeBag)
        output.subtaskSheets.drive(subtaskSheetTable.rx.items(cellIdentifier: R.reuseIdentifier.subtaskSheetCell.identifier)) {
            (row, element, cell) in
            cell.textLabel?.text = element.name
        }.disposed(by: disposeBag)
        output.selectSubtaskSheet.drive().disposed(by: disposeBag)

    }
}
