import Foundation
import RxSwift

class EditSubtaskSheetUseCase {

    private let subtaskSheetRepository: SubtaskSheetRepository
    private let taskRepository: TaskRepository

    let disposeBag = DisposeBag()

    init(with subtaskSheetRepository: SubtaskSheetRepository, and taskRepository: TaskRepository) {
        self.subtaskSheetRepository = subtaskSheetRepository
        self.taskRepository = taskRepository
    }

    func getSubtaskSheetById(with sheetId: String) -> Observable<SubtaskSheet> {
        return subtaskSheetRepository.readById(with: sheetId)
    }

    func loadTasks(with sheetId: String, and sheetType: String) -> Observable<[Task]> {
        return taskRepository.read(with: sheetId, and: sheetType)
    }

    func saveSheet(with sheet: SubtaskSheet) -> Observable<String> {
        subtaskSheetRepository.create(with: sheet)
    }

    func saveTasks(with tasks: [Task], and sheetId: String, and sheetType: String) -> Observable<Void> {
        taskRepository.create(with: tasks, and: sheetId, and: sheetType)
    }

    func updateSheet(with sheet: SubtaskSheet) -> Observable<Void> {
        subtaskSheetRepository.update(sheet)
    }

    func updateTasks(with tasks: [Task], and sheetId: String, and sheetType: String) -> Observable<Void> {
        taskRepository.update(with: tasks, and: sheetId, and: sheetType)
    }

    func uploadImage(_ image: UIImage, name: String) -> Observable<Void> {
        subtaskSheetRepository.uploadImage(image, name: name)
    }
}


