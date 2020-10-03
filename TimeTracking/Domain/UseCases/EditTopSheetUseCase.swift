import Foundation
import RxSwift

class EditTopSheetUseCase {

    let appConst = AppConst()

    private let sheetRepository: SheetRepository
    private let topSheetRepository: TopSheetRepository

    init(with topSheetRepository: TopSheetRepository, and sheetRepository: SheetRepository) {
        self.topSheetRepository = topSheetRepository
        self.sheetRepository = sheetRepository
    }

    func loadPositionSheets() -> Observable<[Sheet]> {
        return sheetRepository.read(with: appConst.SHEET_TYPE_POSITION)
    }

    func loadPositionSheetsByIds(with: [String]) -> Observable<[Sheet]> {
        return sheetRepository.read(with: appConst.SHEET_TYPE_POSITION)
    }

    func saveSheet(with sheet: TopSheet) -> Observable<String> {
        return topSheetRepository.create(with: sheet)
    }

    func updateSheet(with sheet: TopSheet) -> Observable<String> {
        return topSheetRepository.create(with: sheet)
    }
}


