import UIKit
import RxSwift
import RxCocoa
import SpreadsheetView

class SheetViewController: UIViewController {

    @IBOutlet weak var sheetView: SpreadsheetView!

    var sheetViewModel: SheetViewModel!
    let disposeBag = DisposeBag()
    var sheet: Sheet?
    let cellDataConverter = CellDataConverter()
    var noteDialogView = NoteDialogView()
    var tasks: [Task] = []
    
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
    
    func initializeViewModel(with sheet: Sheet? = nil) {
        guard sheetViewModel == nil else { return }
        sheetViewModel = SheetViewModel(with: SheetUseCase(withTask: FireBaseTaskRepository()),
                                        and: SheetNavigator(with: self),
                                        and: sheet
        )
    }
    
    func bindViewModel() {
        let input = SheetViewModel.Input(loadTrigger: Driver.just(()))
        let output = sheetViewModel.transform(input: input)
        output.load.drive().disposed(by: disposeBag)
        output.tasks.drive(onNext: { tasks in
            self.tasks = tasks
            self.sheetView.reloadData()
        }).disposed(by: disposeBag)
        output.sheet.drive(onNext: { sheet in
            self.sheet = sheet
        }).disposed(by: disposeBag)
    }
}


extension SheetViewController: SpreadsheetViewDataSource {
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return sheet?.columnTitles.count ?? 0
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return tasks.count + 1
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return CGFloat(sheet?.columnWidths[column] ?? 50)
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 40
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        // headerのとき
        if (indexPath.row == 0) {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.label.text = sheet?.columnTitles[indexPath.column]
            return cell
        } else {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DataCell.self), for: indexPath) as! DataCell
            for subview in cell.contentView.subviews {
                subview.removeFromSuperview()
            }
            cell.delegate = self
            return cellDataConverter.makeDataCell(cell: cell,
                                                  indexPath: indexPath,
                                                  data: tasks[indexPath.row-1].data[indexPath.column] as Any,
                                                  type: sheet?.columnTypes[indexPath.column] ?? "text")
        }
    }
}

extension SheetViewController: DataCellDelegate {
    func tappedCheckButton(_ isChecked: Bool, indexPath: IndexPath) {
        tasks[indexPath.row-1].data[indexPath.column] = isChecked
        sheetView.reloadData()
    }

    func updateTimeCell(_ time: Date, indexPath: IndexPath) {}

    func updateTextCell(_ text: String, indexPath: IndexPath) {}

    func openNoteDialog(_ note: Note?, indexPath: IndexPath) {
        let size: CGSize = UIScreen.main.bounds.size
        noteDialogView = NoteDialogView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        noteDialogView.delegate = self
        noteDialogView.indexPath = indexPath
        if (note != nil) {
            noteDialogView.setNote(note: note!)
        }
        noteDialogView.alpha = 0
        noteDialogView.confirmButton.setTitle("閉じる", for: .normal)
        navigationController?.view.addSubview(self.noteDialogView)
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.noteDialogView.alpha = 1
        }, completion: nil)
    }

}

extension SheetViewController: NoteDialogViewCellDelegate {
    func openCamera() {}

    func openGallary() {}

    func onCloseDialog(_ image: UIImage, note: Note, indexPath: IndexPath) {}
}
