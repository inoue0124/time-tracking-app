import Foundation
import RxSwift

class EditSheetUseCase {

    private let sheetRepository: SheetRepository
    private let taskRepository: TaskRepository

    let disposeBag = DisposeBag()

    init(with sheetRepository: SheetRepository, and taskRepository: TaskRepository) {
        self.sheetRepository = sheetRepository
        self.taskRepository = taskRepository
    }

    func loadTasks(with sheetId: String, and sheetType: String) -> Observable<[Task]> {
        return taskRepository.read(with: sheetId, and: sheetType)
    }

    func saveSheet(with sheet: Sheet) -> Observable<String> {
        sheetRepository.create(with: sheet)
    }

    func saveTasks(with tasks: [Task], and sheetId: String, and sheetType: String) -> Observable<Void> {
        taskRepository.create(with: tasks, and: sheetId, and: sheetType)
    }

    func updateSheet(with sheet: Sheet) -> Observable<Void> {
        sheetRepository.update(sheet)
    }

    func updateTasks(with tasks: [Task], and sheetId: String, and sheetType: String) -> Observable<Void> {
        taskRepository.update(with: tasks, and: sheetId, and: sheetType)
    }

    func uploadImage(_ image: UIImage, name: String) -> Observable<Void> {
        sheetRepository.uploadImage(image, name: name)
    }
}


