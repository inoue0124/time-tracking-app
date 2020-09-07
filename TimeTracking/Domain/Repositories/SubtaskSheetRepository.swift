import Foundation
import RxSwift

protocol SubtaskSheetRepository {
    func create(with name: String) -> Observable<Void>
    func read() -> Observable<[Sheet]>
    func update(_ positionSheet: Sheet) -> Observable<Void>
    func delete(_ positionSheetId: String) -> Observable<Void>
}
