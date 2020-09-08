import Foundation
import RxSwift

protocol PositionSheetRepository {
    func create(with name: String, and columnTitles: [String], and columnTypes: [String], and columnWidths: [Int]) -> Observable<String>
    func read() -> Observable<[Sheet]>
    func update(_ positionSheet: Sheet) -> Observable<Void>
    func delete(_ positionSheetId: String) -> Observable<Void>
}
