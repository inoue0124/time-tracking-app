import Foundation
import RxSwift

class HomeUseCase {

    private let positionSheetRepository: PositionSheetRepository
    private let subtaskSheetRepository: SubtaskSheetRepository

    init(with positionSheetRepository: PositionSheetRepository, and subtaskSheetRepository: SubtaskSheetRepository) {
        self.positionSheetRepository = positionSheetRepository
        self.subtaskSheetRepository = subtaskSheetRepository
    }

//    func executeTest(with name: String) -> Observable<Void> {
//        return positionSheetRepository.create(with: name)
//    }

    func loadPositionSheets() -> Observable<[Sheet]> {
        return positionSheetRepository.read()
    }

    func loadSubtaskSheets() -> Observable<[Sheet]> {
        return subtaskSheetRepository.read()
    }
}
