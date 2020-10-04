import Foundation
import RxSwift

class SubtaskSheetDetailUseCase {
    
    private let taskRepository: TaskRepository
    
    init(withTask taskRepository: TaskRepository) {
        self.taskRepository = taskRepository
    }
    
    func loadTasks(with sheetId: String, and sheetType: String) -> Observable<[Task]> {
        return taskRepository.read(with: sheetId, and: sheetType)
    }
    
    func delete(with taskId: String, and sheetId: String, and sheetType: String) -> Observable<Void> {
        return taskRepository.delete(with: taskId, and: sheetId, and: sheetType)
    }
}


