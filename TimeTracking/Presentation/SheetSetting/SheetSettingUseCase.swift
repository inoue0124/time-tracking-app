import Foundation
import RxSwift

class SheetSettingUseCase {

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

    func loadTopSheets() -> Observable<[TopSheet]> {
        return topSheetRepository.read()
    }
    func deleteTopSheets(with sheetId: String) -> Observable<Void> {
        return topSheetRepository.delete(sheetId)
    }

    func loadPositionSheets() -> Observable<[PositionSheet]> {
        return positionSheetRepository.read()
    }
    func deletePositionSheets(with sheetId: String) -> Observable<Void> {
        return positionSheetRepository.delete(sheetId, and: appConst.SHEET_TYPE_POSITION)
    }

    func loadSubtaskSheets() -> Observable<[SubtaskSheet]> {
        return subtaskSheetRepository.read()
    }
    func deleteSubtaskSheets(with sheetId: String) -> Observable<Void> {
        return subtaskSheetRepository.delete(sheetId, and: appConst.SHEET_TYPE_SUBTASK)
    }
}
