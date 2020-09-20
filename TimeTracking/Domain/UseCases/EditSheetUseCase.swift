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

    func save(with name: String, and columnTitles: [String], and columnTypes: [String], and columnWidths: [Int]) -> Observable<String> {
        sheetRepository.create(with: name, and: columnTitles, and: columnTypes, and: columnWidths)
    }

    func saveTasks(with data: [[Any]], and sheetId: String) -> Observable<Void> {
        taskRepository.create(with: data, and: sheetId)
    }

    func uploadImage(_ image: UIImage, name: String) -> Observable<Void> {
        sheetRepository.uploadImage(image, name: name)
    }
}


