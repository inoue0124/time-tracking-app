import Foundation
import RxSwift

class TopSheetDetailUseCase {
    
    private let taskRepository: TaskRepository
    
    init(withTask taskRepository: TaskRepository) {
        self.taskRepository = taskRepository
    }
    
    func loadTasks(with positionSheetIds: [String]) -> Observable<[Task]> {
        return taskRepository.read(with: positionSheetIds)
    }
    
    func delete(with taskId: String, and sheetId: String, and sheetType: String) -> Observable<Void> {
        return taskRepository.delete(with: taskId, and: sheetId, and: sheetType)
    }
}


