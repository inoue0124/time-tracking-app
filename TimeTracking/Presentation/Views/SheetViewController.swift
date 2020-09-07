import UIKit
import RxSwift
import RxCocoa
import SpreadsheetView

class SheetViewController: UIViewController {

    @IBOutlet weak var sheetView: SpreadsheetView!

    var listViewModel: SheetViewModel!
    let disposeBag = DisposeBag()
    var tasks: [Task]?
    var positionSheet: Sheet?
    let cellDataConverter = CellDataConverter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        initializeViewModel()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func initializeUI() {
        sheetView.dataSource = self
        sheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        sheetView.register(DataCell.self, forCellWithReuseIdentifier: String(describing: DataCell.self))
    }
    
    func initializeViewModel(with positionSheet: Sheet? = nil) {
        guard listViewModel == nil else { return }
        listViewModel = SheetViewModel(
            with: SheetUseCase(withTask: FireBasePositionSheetTaskRepository()),
            and: SheetNavigator(with: self),
            and: positionSheet
        )
    }
    
    func bindViewModel() {
        let input = SheetViewModel.Input(trigger: Driver.just(()))
        let output = listViewModel.transform(input: input)
        output.load.drive().disposed(by: disposeBag)
        output.tasks.drive(onNext: { tasks in
            self.tasks = tasks
            self.sheetView.reloadData()
        }).disposed(by: disposeBag)
        output.positionSheet.drive(onNext: { positionSheet in
            self.positionSheet = positionSheet
        }).disposed(by: disposeBag)
    }
}


extension SheetViewController: SpreadsheetViewDataSource {
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return positionSheet?.columnTitles.count ?? 0
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        if let count = tasks?.count {
            return count + 1
        } else {
            return 0
        }
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
      return 80
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
      return 40
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        // headerのとき
        if (indexPath.row == 0) {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.label.text = positionSheet?.columnTitles[indexPath.column]
            return cell
        } else {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DataCell.self), for: indexPath) as! DataCell
            return cellDataConverter.makeDataCell(cell: cell,
                                                  data: tasks?[indexPath.row-1].data[indexPath.column] as Any,
                                                  type: positionSheet?.columnTypes[indexPath.column] ?? "text")
        }

    }
}
