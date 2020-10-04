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

    func loadPositionSheets() -> Observable<[PositionSheet]> {
        return positionSheetRepository.read(with: appConst.SHEET_TYPE_POSITION)
    }

    func loadSubtaskSheets() -> Observable<[SubtaskSheet]> {
        return subtaskSheetRepository.read(with: appConst.SHEET_TYPE_SUBTASK)
    }
}
