import Foundation
import RxSwift

protocol TopSheetRepository {
    func create(with sheet: TopSheet) -> Observable<String>
    func read() -> Observable<[TopSheet]>
    func readPositionSheets(with id: String) -> Observable<[PositionSheet]>
    func delete(_ id: String) -> Observable<Void>
}
