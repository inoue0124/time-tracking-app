import Foundation
import RxSwift

class AddSheetUseCase {

    let appConst = AppConst()

    private let sheetRepository: SheetRepository

    init(with sheetRepository: SheetRepository) {
        self.sheetRepository = sheetRepository
    }

    func loadPositionSheets() -> Observable<[Sheet]> {
        return sheetRepository.read(with: appConst.SHEET_TYPE_POSITION)
    }

    func loadSubtaskSheets() -> Observable<[Sheet]> {
        return sheetRepository.read(with: appConst.SHEET_TYPE_SUBTASK)
    }
}
