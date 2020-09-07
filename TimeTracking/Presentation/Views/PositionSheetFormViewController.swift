import UIKit
import RxSwift
import RxCocoa
import DropDown
import Eureka

class PositionSheetFormViewController: FormViewController {

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
//        initializeViewModel()
//        bindViewModel()
    }

    func initializeUI() {
        form +++ Section("Section1")

        <<< TimeInlineRow() { row in
            row.title = "時間"
        }

        <<< TextRow() { row in
            row.title = "内容"
            row.placeholder = "内容を入力してください"
        }

        <<< ButtonRow() { row in
            row.title = "追加"
        }.onCellSelection { cell, row in
            print("here")
        }
    }
}

