import SpreadsheetView

class AddButtonCell: Cell {

    let label = UILabel()
    var delegate: AddButtonCellDelegate?
    var type: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.text = "+"
        label.textAlignment = .center
        label.textColor = UIColor(named: R.color.theme.name)
        contentView.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if type == "column" {
            delegate?.addColumn()
        }
        if type == "row" {
            delegate?.addRow()
        }
    }
}

protocol AddButtonCellDelegate {
    func addColumn() -> Void
    func addRow() -> Void
}
