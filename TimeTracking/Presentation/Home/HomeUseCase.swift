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

    func loadTopSheets(with id: String) -> Observable<[Sheet]> {
        return topSheetRepository.read(with: id)
    }

    func loadPositionSheets() -> Observable<[Sheet]> {
        return positionSheetRepository.read(with: appConst.SHEET_TYPE_SUBTASK)
    }

    func loadSubtaskSheets() -> Observable<[Sheet]> {
        return subtaskSheetRepository.read(with: appConst.SHEET_TYPE_SUBTASK)
    }
}
