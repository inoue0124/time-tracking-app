import Foundation
import RxSwift

class SheetSettingUseCase {

    let appConst = AppConst()

    private let sheetRepository: SheetRepository

    init(with sheetRepository: SheetRepository) {
        self.sheetRepository = sheetRepository
    }

    func loadPositionSheets() -> Observable<[Sheet]> {
        return sheetRepository.read(with: appConst.SHEET_TYPE_POSITION)
    }

    func loadSubtaskSheets() -> Observable<[Sheet]> {
        return sheetRepository.read(with: appConst.SHEET_TYPE_SUBTASK)
    }

    func deletePositionSheets(with sheetId: String) -> Observable<Void> {
        return sheetRepository.delete(sheetId, and: appConst.SHEET_TYPE_POSITION)
    }

    func deleteSubtaskSheets(with sheetId: String) -> Observable<Void> {
        return sheetRepository.delete(sheetId, and: appConst.SHEET_TYPE_SUBTASK)
    }
}
