import Foundation
import RxSwift

class EditPositionSheetUseCase {

    private let positionSheetRepository: PositionSheetRepository
    private let taskRepository: TaskRepository

    let disposeBag = DisposeBag()

    init(with positionSheetRepository: PositionSheetRepository, and taskRepository: TaskRepository) {
        self.positionSheetRepository = positionSheetRepository
        self.taskRepository = taskRepository
    }

    func loadTasks(with sheetId: String, and sheetType: String) -> Observable<[Task]> {
        return taskRepository.read(with: sheetId, and: sheetType)
    }

    func saveSheet(with sheet: Sheet) -> Observable<String> {
        positionSheetRepository.create(with: sheet)
    }

    func saveTasks(with tasks: [Task], and sheetId: String, and sheetType: String) -> Observable<Void> {
        taskRepository.create(with: tasks, and: sheetId, and: sheetType)
    }

    func updateSheet(with sheet: Sheet) -> Observable<Void> {
        positionSheetRepository.update(sheet)
    }

    func updateTasks(with tasks: [Task], and sheetId: String, and sheetType: String) -> Observable<Void> {
        taskRepository.update(with: tasks, and: sheetId, and: sheetType)
    }

    func uploadImage(_ image: UIImage, name: String) -> Observable<Void> {
        positionSheetRepository.uploadImage(image, name: name)
    }
}


