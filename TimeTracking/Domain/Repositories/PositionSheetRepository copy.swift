import Foundation
import RxSwift

protocol PositionSheetRepository {
    func create(with sheet: PositionSheet) -> Observable<String>
    func read() -> Observable<[PositionSheet]>
    func readById(with id: String) -> Observable<PositionSheet>
    func update(_ positionSheet: PositionSheet) -> Observable<Void>
    func delete(_ positionSheetId: String, and sheetType: String) -> Observable<Void>
    func uploadImage(_ image: UIImage, name: String) -> Observable<Void>
}
