import SpreadsheetView

class HeaderCell: Cell {

    let label = UILabel()
    var delegate: HeaderCellDelegate?
    var column: Column?
    var index: Int?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.95, alpha: 1.0)

        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = .center
        label.textColor = .gray
        contentView.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.openHeaderSetting(column!, index: index!)
    }
}

protocol HeaderCellDelegate {
    func openHeaderSetting(_ column: Column, index: Int) -> Void
}
