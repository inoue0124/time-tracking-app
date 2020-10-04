import Foundation
import RxSwift

class HomeUseCase {

    let appConst = AppConst()

    private let sheetRepository: SheetRepository
    private let topSheetRepository: TopSheetRepository

    init(with topSheetRepository: TopSheetRepository, and sheetRepository: SheetRepository) {
        self.topSheetRepository = topSheetRepository
        self.sheetRepository = sheetRepository
    }

    func loadTopSheets(with id: String) -> Observable<[Sheet]> {
        return topSheetRepository.read(with: id)
    }

    func loadSubtaskSheets() -> Observable<[Sheet]> {
        return sheetRepository.read(with: appConst.SHEET_TYPE_SUBTASK)
    }
}
