import Foundation
import RxSwift

class EditSheetUseCase {

    private let sheetRepository: PositionSheetRepository
    private let taskRepository: PositionSheetTaskRepository

    let disposeBag = DisposeBag()

    init(with sheetRepository: PositionSheetRepository, and taskRepository: PositionSheetTaskRepository) {
        self.sheetRepository = sheetRepository
        self.taskRepository = taskRepository
    }

    func save(with name: String, and columnTitles: [String], and columnTypes: [String], and columnWidths: [Int], and data: [[Any]]) -> Observable<Void> {
        sheetRepository.create(with: name, and: columnTitles, and: columnTypes, and: columnWidths)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { sheetId in
                for da in data {
                    self.taskRepository.create(with: da, and: sheetId).asDriver(onErrorJustReturn: ()).drive().disposed(by: self.disposeBag)
                }
            }).disposed(by: disposeBag)
        return Observable.create { _ in return Disposables.create() }
    }
}


