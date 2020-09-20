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
    var imageRelay = BehaviorRelay<UIImage>(value: UIImage())
    var imageNameRelay = BehaviorRelay<String>(value: "")

    var imagePicker = UIImagePickerController()
    var noteDialogView = NoteDialogView()

    var sheetName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        initializeViewModel()
        bindViewModel()
        
    }

    func initializeUI() {
        sheetView.dataSource = self
        dismissButton.rx.tap.subscribe { [unowned self] _ in
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        sheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        sheetView.register(DataCell.self, forCellWithReuseIdentifier: String(describing: DataCell.self))
        sheetView.register(AddButtonCell.self, forCellWithReuseIdentifier: String(describing: AddButtonCell.self))
    }

    func initializeViewModel() {
        let parentNVC = self.presentingViewController as? UINavigationController
        editSheetViewModel = EditSheetViewModel(
            with: EditSheetUseCase(with: FireBasePositionSheetRepository(), and: FireBasePositionSheetTaskRepository()),
            and: EditSheetNavigator(with: self, and: parentNVC)
        )
    }

    func bindViewModel() {
        let input = EditSheetViewModel.Input(saveTrigger: saveButton.rx.tap.asDriver(),
                                             columnTitles: columnTitlesRelay.asDriver(),
                                             columnTypes: columnTypesRelay.asDriver(),
                                             columnWidths: columnWidthsRelay.asDriver(),
                                             data: dataRelay.asDriver(),
                                             uploadImageTrigger: imageRelay.asDriver(),
                                             imageName: imageNameRelay.asDriver(),
                                             sheetName: sheetName)
        let output = editSheetViewModel.transform(input: input)
        output.save.drive().disposed(by: disposeBag)
        output.uploadImage.drive().disposed(by: disposeBag)
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
            cell.delegate = self
            cell.column = Column(name: columnTitles[indexPath.column],
                                 type: columnTypes[indexPath.column],
                                 width: columnWidths[indexPath.column])
            cell.index = indexPath.column
            return cell

        // 1行目、addColumnCellの時
        case (0, columnTitles.count):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: AddButtonCell.self), for: indexPath) as! AddButtonCell
            cell.delegate = self
            cell.type = "column"
            return cell

        // 一番下にaddRowCellを追加
        case (data.count+1, 0):
            // データがまだない時は非表示
            if (columnTitles.count==0) {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DataCell.self), for: indexPath) as! DataCell
                clearCell(cell)
                return cell
            }
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: AddButtonCell.self), for: indexPath) as! AddButtonCell
            cell.delegate = self
            cell.type = "row"
            return cell

        // 2行目以降、右端は空のセル
        case (1..<data.count+2, columnTitles.count):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DataCell.self), for: indexPath) as! DataCell
            clearCell(cell)
            cell.gridlines.left = .default
            return cell

        default:
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DataCell.self), for: indexPath) as! DataCell
            clearCell(cell)
            cell.delegate = self
            return cellDataConverter.makeEditableDataCell(cell: cell,
                                                          indexPath: indexPath,
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

    func clearCell(_ cell: DataCell) {
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        cell.gridlines.right = .none
        cell.gridlines.bottom = .none
        cell.gridlines.left = .none
    }

    func refreshData() {
        columnTitlesRelay.accept(columnTitles)
        columnTypesRelay.accept(columnTypes)
        columnWidthsRelay.accept(columnWidths)
        dataRelay.accept(data)
        sheetView.reloadData()
    }
}

extension EditSheetViewController: AddButtonCellDelegate {
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
}

extension EditSheetViewController: HeaderCellDelegate {
    func openHeaderSetting(_ column: Column, index: Int) {
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
        refreshData()
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
        refreshData()
    }
    func deleteColumn(index: Int) {
        columnTitles.remove(at: index)
        columnTypes.remove(at: index)
        columnWidths.remove(at: index)
        for i in 0..<data.count {
            data[i].remove(at: index)
        }
        refreshData()
    }
}

extension EditSheetViewController: DataCellDelegate {
    func tappedCheckButton(_ isChecked: Bool, indexPath: IndexPath) {
        data[indexPath.row-1][indexPath.column] = isChecked
        refreshData()
    }

    func updateTimeCell(_ time: Date, indexPath: IndexPath) {
        data[indexPath.row-1][indexPath.column] = time
        refreshData()
    }

    func updateTextCell(_ text: String, indexPath: IndexPath) {
        data[indexPath.row-1][indexPath.column] = text
    }
    func openNoteDialog(_ note: Note?, indexPath: IndexPath) {
        let size: CGSize = UIScreen.main.bounds.size
        noteDialogView = NoteDialogView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        noteDialogView.delegate = self
        noteDialogView.indexPath = indexPath
        if (note != nil) {
            noteDialogView.setNote(note: note!)
        }
        noteDialogView.alpha = 0
        navigationController?.view.addSubview(self.noteDialogView)
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.noteDialogView.alpha = 1
        }, completion: nil)
    }
}

extension EditSheetViewController: NoteDialogViewCellDelegate {

    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        } else{
            let alert  = UIAlertController(title: "エラー", message: "端末にカメラがありません。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }

    func onCloseDialog(_ image: UIImage, note: Note, indexPath: IndexPath) {
        imageNameRelay.accept(note.imageName)
        imageRelay.accept(image)
        data[indexPath.row-1][indexPath.column] = makeNoteJson(note)
        refreshData()
    }

    func makeNoteJson(_ note: Note) -> String {
        return "{\"imageName\":\"" + note.imageName + "\", \"text\": \"" + note.text + "\"}"
    }
}

extension EditSheetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            noteDialogView.imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
}
