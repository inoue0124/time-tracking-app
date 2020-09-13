import SpreadsheetView

class AddRowCell: Cell {
    
    let label = UILabel()

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
}
