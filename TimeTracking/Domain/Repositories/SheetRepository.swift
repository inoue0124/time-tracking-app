import Foundation
import RxSwift

protocol SheetRepository {
    func create(with sheet: Sheet) -> Observable<String>
    func read(with sheetType: String) -> Observable<[Sheet]>
    func update(_ positionSheet: Sheet) -> Observable<Void>
    func delete(_ positionSheetId: String, and sheetType: String) -> Observable<Void>
    func uploadImage(_ image: UIImage, name: String) -> Observable<Void>
}
