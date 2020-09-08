import UIKit
import BottomHalfModal
import DropDown
import RxSwift
import RxCocoa

class HeaderSettingViewController: UIViewController, SheetContentHeightModifiable {

    let appConst = AppConst()
    let sheetContentHeightToModify: CGFloat = 240
    var delegate: AddCellDelegate?

    let typeDropDown = DropDown()
    let widthDropDown = DropDown()

    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var widthButton: UIButton!

    var columnType: String?
    var columnWidth: Int?

    let disposeBag = DisposeBag()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adjustFrameToSheetContentHeightIfNeeded()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        adjustFrameToSheetContentHeightIfNeeded(with: coordinator)
    }

    func initializeUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNoti(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNoti(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        setupDropDowns()
        typeButton.rx.tap.subscribe { _ in
            self.typeDropDown.show()
        }.disposed(by: disposeBag)
        widthButton.rx.tap.subscribe { _ in
            self.widthDropDown.show()
        }.disposed(by: disposeBag)
    }

    func setupDropDowns() {
        setupTypeDropDown()
        setupWidthDropDown()
    }

    func setupTypeDropDown() {
        typeDropDown.anchorView = typeButton
        typeDropDown.bottomOffset = CGPoint(x: 0, y: typeButton.bounds.height)
        typeDropDown.dataSource = [
            appConst.CELL_TYPE_TIME_DISPLAY,
            appConst.CELL_TYPE_TEXT_DISPLAY,
            appConst.CELL_TYPE_CHECK_DISPLAY,
            appConst.CELL_TYPE_NOTE_DISPLAY
        ]
        typeDropDown.selectionAction = { (index, item) in
            switch (item) {
            case self.appConst.CELL_TYPE_TIME_DISPLAY:
                self.columnType = self.appConst.CELL_TYPE_TIME
                break
            case self.appConst.CELL_TYPE_TEXT_DISPLAY:
                self.columnType = self.appConst.CELL_TYPE_TEXT
                break
            case self.appConst.CELL_TYPE_CHECK_DISPLAY:
                self.columnType = self.appConst.CELL_TYPE_CHECK
                break
            case self.appConst.CELL_TYPE_NOTE_DISPLAY:
                self.columnType = self.appConst.CELL_TYPE_NOTE
                break
            default:
                break
            }
            self.typeButton.setTitle(item, for: .normal)
        }
    }

    func setupWidthDropDown() {
        widthDropDown.anchorView = widthButton
        widthDropDown.bottomOffset = CGPoint(x: 0, y: widthButton.bounds.height)
        widthDropDown.dataSource = [
            appConst.CELL_WIDTH_SMALL_DISPLAY,
            appConst.CELL_WIDTH_MEDIUM_DISPLAY,
            appConst.CELL_WIDTH_LARGE_DISPLAY,
        ]
        widthDropDown.selectionAction = { (index, item) in
            switch (item) {
            case self.appConst.CELL_WIDTH_SMALL_DISPLAY:
                self.columnWidth = self.appConst.CELL_WIDTH_SMALL
                break
            case self.appConst.CELL_WIDTH_MEDIUM_DISPLAY:
                self.columnWidth = self.appConst.CELL_WIDTH_MEDIUM
                break
            case self.appConst.CELL_WIDTH_LARGE_DISPLAY:
                self.columnWidth = self.appConst.CELL_WIDTH_LARGE
                break
            default:
                break
            }
            self.widthButton.setTitle(item, for: .normal)
        }
    }

    @objc private func save() {
        delegate?.setHeaderName(Column(name: nameTextField.text ?? "名称未設定",
                                       type: columnType ?? self.appConst.CELL_TYPE_TIME,
                                       width: columnWidth ?? 1))
        dismiss(animated: true, completion: nil)
    }


    @objc private func cancel() {
        dismiss(animated: true, completion: nil)
    }


    @objc private func keyboardNoti(noti: Notification) {
        if let rootView = UIApplication.shared.keyWindow {
            animate(with: noti, safeAreaInsets: UIEdgeInsets(top: 0, left: 0, bottom: rootView.safeAreaInsets.bottom, right: 0))
        } else {
            animate(with: noti)
        }
    }
}


extension HeaderSettingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

