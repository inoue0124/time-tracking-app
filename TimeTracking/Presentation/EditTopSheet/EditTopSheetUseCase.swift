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
    
    func getTopSheetById(with sheetId: String) -> Observable<TopSheet> {
        return topSheetRepository.readById(with: sheetId)
    }

    func loadPositionSheets() -> Observable<[PositionSheet]> {
        return positionSheetRepository.read()
    }

    func loadPositionSheetsByIds(with: [String]) -> Observable<[PositionSheet]> {
        return positionSheetRepository.read()
    }

    func saveSheet(with sheet: TopSheet) -> Observable<String> {
        return topSheetRepository.create(with: sheet)
    }

    func updateSheet(with sheet: TopSheet) -> Observable<String> {
        return topSheetRepository.create(with: sheet)
    }
}


