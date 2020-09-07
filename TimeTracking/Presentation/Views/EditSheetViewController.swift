import UIKit
import RxSwift
import RxCocoa
import DropDown
import SpreadsheetView
import RxUIAlert

class EditSheetViewController: UIViewController {

    @IBOutlet weak var dismissButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var sheetView: SpreadsheetView!

    var editSheetViewModel: EditSheetViewModel!

    let disposeBag = DisposeBag()
    let cellDataConverter = CellDataConverter()


    var columnTitles: [String] = []
    var columnTypes: [String] = []
    var data: [[Any]] = []
    var columnTitlesRelay = BehaviorRelay<[String]>(value: [])
    var columnTypesRelay = BehaviorRelay<[String]>(value: [])
    var dataRelay = BehaviorRelay<[[Any]]>(value: [])

    var sheetName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        initializeViewModel()
        bindViewModel()
        
    }

    func initializeUI() {
        sheetView.dataSource = self
        sheetView.delegate = self
        dismissButton.rx.tap.subscribe { [unowned self] _ in
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        sheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        sheetView.register(DataCell.self, forCellWithReuseIdentifier: String(describing: DataCell.self))
        sheetView.register(AddColumnCell.self, forCellWithReuseIdentifier: String(describing: AddColumnCell.self))
        sheetView.register(AddRowCell.self, forCellWithReuseIdentifier: String(describing: AddRowCell.self))
    }

    func initializeViewModel() {
        editSheetViewModel = EditSheetViewModel(
            with: EditSheetUseCase(with: FireBasePositionSheetRepository(),
                                   and: FireBasePositionSheetTaskRepository()),
            and: EditSheetNavigator(with: self)
        )
    }

    func bindViewModel() {
        let input = EditSheetViewModel.Input(saveTrigger: saveButton.rx.tap.asDriver(),
                                             columnTitles: columnTitlesRelay.asDriver(),
                                             columnTypes: columnTypesRelay.asDriver(),
                                             data: dataRelay.asDriver(),
                                             sheetName: sheetName)
        let output = editSheetViewModel.transform(input: input)
        output.save.drive().disposed(by: disposeBag)
    }

}


extension EditSheetViewController: SpreadsheetViewDataSource {

    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return columnTitles.count + 1
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return data.count + 2
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
      return 80
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
      return 40
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {

        switch (indexPath.row, indexPath.column) {

        case (0, 0..<columnTitles.count):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.label.text = columnTitles[indexPath.column]
            return cell

        case (0, columnTitles.count):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: AddColumnCell.self), for: indexPath) as! AddColumnCell
            cell.delegate = self
            return cell

        case (data.count+1, 0):
            if (columnTitles.count==0) {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DataCell.self), for: indexPath) as! DataCell
                cell.label.text = ""
                cell.gridlines.right = .none
                cell.gridlines.bottom = .none
                cell.gridlines.left = .none
                return cell
            }
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: AddRowCell.self), for: indexPath) as! AddRowCell
            cell.delegate = self
            return cell

        case (1..<data.count+2, columnTitles.count):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DataCell.self), for: indexPath) as! DataCell
            cell.label.text = ""
            cell.gridlines.right = .none
            cell.gridlines.bottom = .none
            cell.gridlines.left = .default
            return cell

        default:
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DataCell.self), for: indexPath) as! DataCell
            cell.gridlines.right = .default
            cell.gridlines.bottom = .default
            cell.gridlines.left = .default
            return cellDataConverter.makeDataCell(cell: cell,
                                                  data: data[indexPath.row-1][indexPath.column] as Any,
                                                  type: columnTypes[indexPath.column])
        }
    }

    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        if (columnTitles.count==0) {
            return [CellRange(from: (0, 0), to: (0, 0))]
        }
        return [CellRange(from: (data.count+1, 0), to: (data.count+1, columnTitles.count-1))]
    }
}


extension EditSheetViewController: SpreadsheetViewDelegate {
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: (row: \(indexPath.row), column: \(indexPath.column))")
    }
}


extension EditSheetViewController: AddCellDelegate {
    func addColumn() {
//        numOfColumns += 1
//        sheetView.reloadData()
        columnTitles.append("内容")
        columnTypes.append("text")
        for i in 0..<data.count {
            data[i].append(String(i))
        }
        columnTitlesRelay.accept(columnTitles)
        columnTypesRelay.accept(columnTypes)
        dataRelay.accept(data)
        sheetView.reloadData()
    }

    func addRow() {
        data.append(Array<String>(repeating: "テキスト", count: columnTitles.count))
        dataRelay.accept(data)
        sheetView.reloadData()
    }


}
