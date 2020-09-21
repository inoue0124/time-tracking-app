import Foundation
import RxSwift

protocol TaskRepository {
    func create(with tasks: [Task], and sheetId: String, and sheetType: String) -> Observable<Void>
    func read(with sheetId: String, and sheetType: String) -> Observable<[Task]>
    func update(with tasks: [Task], and sheetId: String, and sheetType: String) -> Observable<Void>
    func delete(with documentId: String, and sheetId: String, and sheetType: String) -> Observable<Void>
}
