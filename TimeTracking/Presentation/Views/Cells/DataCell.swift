import SpreadsheetView

class DataCell: Cell {
    let label = UILabel()
    let noteButton = UIButton()
    let checkButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = .center
        label.textColor = .gray

        noteButton.frame = bounds
        noteButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        noteButton.setImage(UIImage(named: "note"), for: .normal)

        checkButton.frame = bounds
        checkButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    func addLabel() {
        contentView.addSubview(label)
    }

    func addNote() {
        contentView.addSubview(noteButton)
    }

    func addCheck(isChecked: Bool) {
        if (isChecked) {
            checkButton.setImage(UIImage(named: "check"), for: .normal)
        }
        contentView.addSubview(checkButton)
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
