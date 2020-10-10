import Foundation
import RxSwift

class TopSheetDetailUseCase {

    private let topSheetRepository: TopSheetRepository
    private let taskRepository: TaskRepository
    
    init(with topSheetRepository: TopSheetRepository, and taskRepository: TaskRepository) {
        self.topSheetRepository = topSheetRepository
        self.taskRepository = taskRepository
    }

    func getTopSheetById(with sheetId: String) -> Observable<TopSheet> {
        return topSheetRepository.readById(with: sheetId)
    }
    
    func loadTasks(with positionSheetIds: [String]) -> Observable<[Task]> {
        return taskRepository.read(with: positionSheetIds)
    }
    
    func delete(with taskId: String, and sheetId: String, and sheetType: String) -> Observable<Void> {
        return taskRepository.delete(with: taskId, and: sheetId, and: sheetType)
    }
}


