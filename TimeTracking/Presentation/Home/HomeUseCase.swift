import Foundation
import RxSwift

class HomeUseCase {

    let appConst = AppConst()

    private let topSheetRepository: TopSheetRepository
    private let positionSheetRepository: PositionSheetRepository
    private let subtaskSheetRepository: SubtaskSheetRepository

    init(with topSheetRepository: TopSheetRepository, and positionSheetRepository: PositionSheetRepository,
         and subtaskSheetRepository: SubtaskSheetRepository) {

        self.topSheetRepository = topSheetRepository
        self.positionSheetRepository = positionSheetRepository
        self.subtaskSheetRepository = subtaskSheetRepository
    }

    func loadTopSheets(with id: String) -> Observable<[PositionSheet]> {
        return topSheetRepository.readPositionSheets(with: id)
    }

    func loadPositionSheets() -> Observable<[PositionSheet]> {
        return positionSheetRepository.read()
    }

    func loadSubtaskSheets() -> Observable<[SubtaskSheet]> {
        return subtaskSheetRepository.read()
    }
}
