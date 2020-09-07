import SpreadsheetView
import RxCocoa
import RxSwift

class AddColumnCell: Cell {
    let button = UIButton()
    var delegate: AddCellDelegate?

    let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)

        button.frame = bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.setTitle("+", for: .normal)
        button.setTitleColor(UIColor(named: R.color.theme.name), for: .normal)
        button.rx.tap.subscribe { [unowned self] _ in
            self.delegate?.addColumn()
        }.disposed(by: disposeBag)

        contentView.addSubview(button)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
