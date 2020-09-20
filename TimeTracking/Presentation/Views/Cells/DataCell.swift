import SpreadsheetView

class DataCell: Cell {
    var label = UILabel()
    var noteButton = UIButton()
    var checkButton = UIButton()
    var dateField = UITextField()
    var textField = UITextField()
    let datePicker = UIDatePicker()
    var delegate: DataCellDelegate?
    var indexPath: IndexPath?
    var note: Note?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func addLabel() {
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = .center
        label.textColor = .gray
        contentView.addSubview(label)
    }

    func addNote() {
        noteButton.frame = bounds
        noteButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        noteButton.setImage(UIImage(named: "note"), for: .normal)
        noteButton.addTarget(self, action: #selector(tappedNoteButton(_:)), for: UIControl.Event.touchUpInside)
        contentView.addSubview(noteButton)
    }

    @objc func tappedNoteButton(_ sender: UIButton) {
        delegate?.openNoteDialog(note, indexPath: self.indexPath ?? IndexPath())
    }

    func addCheck(isChecked: Bool) {
        checkButton.frame = bounds
        checkButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if (isChecked) {
            checkButton.setImage(UIImage(named: "check"), for: .normal)
        }
        contentView.addSubview(checkButton)
    }

    func addDateField() {
        dateField.frame = bounds
        dateField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dateField.textAlignment = .center
        dateField.font = UIFont.boldSystemFont(ofSize: 10)
        dateField.textColor = .gray

        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        datePicker.datePickerMode = UIDatePicker.Mode.time

        dateField.inputView = datePicker

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: dateField.inputView!.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)

        dateField.inputAccessoryView = toolbar
        contentView.addSubview(dateField)
    }

    @objc func done() {
        delegate?.updateTimeCell(datePicker.date, indexPath: self.indexPath ?? IndexPath())
        dateField.endEditing(true)
    }

    func addTextField() {
        textField.frame = bounds
        textField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textField.textAlignment = .center
        textField.font = UIFont.boldSystemFont(ofSize: 10)
        textField.textColor = .gray
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        contentView.addSubview(textField)
    }
}

extension DataCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.updateTextCell(textField.text ?? "", indexPath: self.indexPath ?? IndexPath())
    }
}

protocol DataCellDelegate {
    func updateTimeCell(_ time: Date, indexPath: IndexPath) -> Void
    func updateTextCell(_ text: String, indexPath: IndexPath) -> Void
    func openNoteDialog(_ note: Note?, indexPath: IndexPath) -> Void
}
