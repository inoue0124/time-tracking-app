import UIKit
import RxSwift
import RxCocoa
import DropDown
import SpreadsheetView
import RxUIAlert
import BottomHalfModal

class EditSheetViewController: UIViewController {

    @IBOutlet weak var dismissButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var sheetView: SpreadsheetView!

    var editSheetViewModel: EditSheetViewModel!

    let disposeBag = DisposeBag()
    let cellDataConverter = CellDataConverter()


    var columnTitles: [String] = []
    var columnTypes: [String] = []
    var columnWidths: [Int] = []
    var data: [[Any]] = []
    var columnTitlesRelay = BehaviorRelay<[String]>(value: [])
    var columnTypesRelay = BehaviorRelay<[String]>(value: [])
    var columnWidthsRelay = BehaviorRelay<[Int]>(value: [])
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
            with: EditSheetUseCase(with: FireBasePositionSheetRepository(), and: FireBasePositionSheetTaskRepository()),
            and: EditSheetNavigator(with: self)
        )
    }

    func bindViewModel() {
        let input = EditSheetViewModel.Input(saveTrigger: saveButton.rx.tap.asDriver(),
                                             columnTitles: columnTitlesRelay.asDriver(),
                                             columnTypes: columnTypesRelay.asDriver(),
                                             columnWidths: columnWidthsRelay.asDriver(),
                                             data: dataRelay.asDriver(),
                                             sheetName: sheetName)
        let output = editSheetViewModel.transform(input: input)
        output.save.drive().disposed(by: disposeBag)
    }
}


extension EditSheetViewController: SpreadsheetViewDataSource {

    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        // 1 == addColumnCell
        return columnTitles.count + 1
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        // 2 == addRowCell+header
        return data.count + 2
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        // addColumnCellの時は例外
        if (column == columnTitles.count) {
            return 80
        } else {
            return CGFloat(columnWidths[column])
        }
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
      return 40
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {

        switch (indexPath.row, indexPath.column) {

        // 1行目、headerCellの時
        case (0, 0..<columnTitles.count):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.label.text = columnTitles[indexPath.column]
//            cell.button.setTitle(columnTitles[indexPath.column], for: .normal)
            return cell

        // 1行目、addColumnCellの時
        case (0, columnTitles.count):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: AddColumnCell.self), for: indexPath) as! AddColumnCell
            return cell

        // 一番下にaddRowCellを追加
        case (data.count+1, 0):
            // データがまだない時は非表示
            if (columnTitles.count==0) {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DataCell.self), for: indexPath) as! DataCell
                cell.label.text = ""
                cell.gridlines.right = .none
                cell.gridlines.bottom = .none
                cell.gridlines.left = .none
                for subview in cell.contentView.subviews {
                    subview.removeFromSuperview()
                }
                return cell
            }
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: AddRowCell.self), for: indexPath) as! AddRowCell
            return cell

        // 2行目以降、右端は空のセル
        case (1..<data.count+2, columnTitles.count):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DataCell.self), for: indexPath) as! DataCell
            cell.label.text = ""
            cell.gridlines.right = .none
            cell.gridlines.bottom = .none
            cell.gridlines.left = .default
            for subview in cell.contentView.subviews {
                subview.removeFromSuperview()
            }
            return cell

        default:
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DataCell.self), for: indexPath) as! DataCell
            cell.gridlines.right = .default
            cell.gridlines.bottom = .default
            cell.gridlines.left = .default
            cell.delegate = self
            cell.indexPath = indexPath
            for subview in cell.contentView.subviews {
                subview.removeFromSuperview()
            }
            return cellDataConverter.makeEditableDataCell(cell: cell,
                                                          data: data[indexPath.row-1][indexPath.column] as Any,
                                                          type: columnTypes[indexPath.column])
        }
    }

    // addRowCellを結合
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        if (columnTitles.count==0) {
            return [CellRange(from: (0, 0), to: (0, 0))]
        }
        return [CellRange(from: (data.count+1, 0), to: (data.count+1, columnTitles.count-1))]
    }
}


extension EditSheetViewController: SpreadsheetViewDelegate {
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        switch (spreadsheetView.cellForItem(at: indexPath)) {
        case is AddColumnCell:
            addColumn()
        case is AddRowCell:
            addRow()
        case is HeaderCell:
            editColumn(Column(name: columnTitles[indexPath.column],
                              type: columnTypes[indexPath.column],
                              width: columnWidths[indexPath.column]), index: indexPath.column)
        default:
            break
        }
    }

    func addColumn() {
        let headerSettingVC = HeaderSettingViewController()
        headerSettingVC.delegate = self
        let nav = BottomHalfModalNavigationController(rootViewController: headerSettingVC)
        self.presentBottomHalfModal(nav, animated: true, completion: nil)
    }

    func addRow() {
        data.append(Array<String>(repeating: "", count: columnTitles.count))
        dataRelay.accept(data)
        sheetView.reloadData()
    }

    func editColumn(_ column: Column, index: Int) {
        let headerSettingVC = HeaderSettingViewController()
        headerSettingVC.delegate = self
        headerSettingVC.selectedColumn = column
        headerSettingVC.index = index
        let nav = BottomHalfModalNavigationController(rootViewController: headerSettingVC)
        self.presentBottomHalfModal(nav, animated: true, completion: nil)
    }
}


extension EditSheetViewController: HeaderSettingDelegate {
    func createColumn(_ column: Column) {
        columnTitles.append(column.name)
        columnTypes.append(column.type)
        columnWidths.append(column.width)
        for i in 0..<data.count {
            data[i].append("")
        }
        refreshDate()
    }

    func updateColumn(_ column: Column, index: Int) {
        columnTitles[index] = column.name
        // typeが変更されていたらデータを初期化
        if (columnTypes[index] != column.type) {
            for i in 0..<data.count {
                data[i][index] = ""
            }
            columnTypes[index] = column.type
        }
        columnWidths[index] = column.width
        refreshDate()
    }

    func deleteColumn(index: Int) {
        columnTitles.remove(at: index)
        columnTypes.remove(at: index)
        columnWidths.remove(at: index)
        for i in 0..<data.count {
            data[i].remove(at: index)
        }
        refreshDate()
    }

    func updateTimeCell(_ time: Date, indexPath: IndexPath) {
        data[indexPath.row-1][indexPath.column] = time
        refreshDate()
    }

    func updateTextCell(_ text: String, indexPath: IndexPath) {
        data[indexPath.row-1][indexPath.column] = text
    }

    func refreshDate() {
        columnTitlesRelay.accept(columnTitles)
        columnTypesRelay.accept(columnTypes)
        columnWidthsRelay.accept(columnWidths)
        dataRelay.accept(data)
        sheetView.reloadData()
    }
}
