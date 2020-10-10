import Foundation
import RxSwift

class SubtaskSheetDetailUseCase {

    private let subtaskSheetRepository: SubtaskSheetRepository
    private let taskRepository: TaskRepository
    
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
    
    func delete(with taskId: String, and sheetId: String, and sheetType: String) -> Observable<Void> {
        return taskRepository.delete(with: taskId, and: sheetId, and: sheetType)
    }
}


