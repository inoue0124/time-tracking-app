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

    func saveSheet(with name: String, and columnTitles: [String], and columnTypes: [String], and columnWidths: [Int], and sheetType: String) -> Observable<String> {
        sheetRepository.create(with: name, and: columnTitles, and: columnTypes, and: columnWidths, and: sheetType)
    }

    func saveTasks(with data: [[Any]], and sheetId: String, and sheetType: String) -> Observable<Void> {
        taskRepository.create(with: data, and: sheetId, and: sheetType)
    }

    func uploadImage(_ image: UIImage, name: String) -> Observable<Void> {
        sheetRepository.uploadImage(image, name: name)
    }
}


