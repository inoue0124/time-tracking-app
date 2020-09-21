import Foundation
import RxSwift

class HomeUseCase {

    private let sheetRepository: SheetRepository

    init(with sheetRepository: SheetRepository) {
        self.sheetRepository = sheetRepository
    }

    func loadPositionSheets() -> Observable<[Sheet]> {
        return sheetRepository.read()
    }

    func loadSubtaskSheets() -> Observable<[Sheet]> {
        return sheetRepository.read()
    }
}
