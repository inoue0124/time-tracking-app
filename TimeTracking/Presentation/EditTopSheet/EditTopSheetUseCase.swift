import Foundation
import RxSwift

class EditTopSheetUseCase {

    let appConst = AppConst()

    private let positionSheetRepository: PositionSheetRepository
    private let topSheetRepository: TopSheetRepository

    init(with topSheetRepository: TopSheetRepository, and positionSheetRepository: PositionSheetRepository) {
        self.topSheetRepository = topSheetRepository
        self.positionSheetRepository = positionSheetRepository
    }

    func loadPositionSheets() -> Observable<[PositionSheet]> {
        return positionSheetRepository.read(with: appConst.SHEET_TYPE_POSITION)
    }

    func loadPositionSheetsByIds(with: [String]) -> Observable<[PositionSheet]> {
        return positionSheetRepository.read(with: appConst.SHEET_TYPE_POSITION)
    }

    func saveSheet(with sheet: TopSheet) -> Observable<String> {
        return topSheetRepository.create(with: sheet)
    }

    func updateSheet(with sheet: TopSheet) -> Observable<String> {
        return topSheetRepository.create(with: sheet)
    }
}


