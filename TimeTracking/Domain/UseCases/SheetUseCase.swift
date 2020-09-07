import Foundation
import RxSwift

class SheetUseCase {
    
    private let taskRepository: PositionSheetTaskRepository
    
    init(withTask taskRepository: PositionSheetTaskRepository) {
        self.taskRepository = taskRepository
    }
    
    func loadTasks(with sheetId: String) -> Observable<[Task]> {
        return taskRepository.read(with: sheetId)
    }
    
    func delete(with taskId: String, and sheetId: String) -> Observable<Void> {
        return taskRepository.delete(with: taskId, and: sheetId)
    }
}


