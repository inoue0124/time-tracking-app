import SpreadsheetView

class AddRowCell: Cell {
    let button = UIButton()
    var delegate: AddCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        button.frame = bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.setTitle("+", for: .normal)
        button.setTitleColor(UIColor(named: R.color.theme.name), for: .normal)
        button.addTarget(self, action: #selector(buttonEvent(_:)), for: UIControlEvents.touchUpInside)

        contentView.addSubview(button)
    }

    @objc func buttonEvent(_ sender: UIButton) {
        delegate?.addRow()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
