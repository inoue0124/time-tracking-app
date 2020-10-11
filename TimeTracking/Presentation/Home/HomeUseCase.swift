import Foundation
import RxSwift

class HomeUseCase {

    let appConst = AppConst()

    private let topSheetRepository: TopSheetRepository
    private let positionSheetRepository: PositionSheetRepository
    private let subtaskSheetRepository: SubtaskSheetRepository
    private let dateRepository: DateRepository

    init(with topSheetRepository: TopSheetRepository, and positionSheetRepository: PositionSheetRepository,
         and subtaskSheetRepository: SubtaskSheetRepository, and dateRepository: DateRepository) {
        self.topSheetRepository = topSheetRepository
        self.positionSheetRepository = positionSheetRepository
        self.subtaskSheetRepository = subtaskSheetRepository
        self.dateRepository = dateRepository
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

    func changeDate(date: Date) -> Observable<Void> {
        return dateRepository.set(date)
    }

    func readDate() -> Observable<Date> {
        return dateRepository.read()
    }
}
