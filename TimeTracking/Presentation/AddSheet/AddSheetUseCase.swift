import Foundation
import RxSwift

class AddSheetUseCase {

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

    func loadTopSheets() -> Observable<[Sheet]> {
        return topSheetRepository.read(with: appConst.SHEET_TYPE_POSITION)
    }

    func loadPositionSheets() -> Observable<[Sheet]> {
        return positionSheetRepository.read(with: appConst.SHEET_TYPE_POSITION)
    }

    func loadSubtaskSheets() -> Observable<[Sheet]> {
        return subtaskSheetRepository.read(with: appConst.SHEET_TYPE_SUBTASK)
    }
}
