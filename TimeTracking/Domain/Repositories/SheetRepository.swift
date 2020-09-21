import Foundation
import RxSwift

protocol SheetRepository {
    func create(with name: String, and columnTitles: [String], and columnTypes: [String], and columnWidths: [Int], and sheetType: String) -> Observable<String>
    func read(with sheetType: String) -> Observable<[Sheet]>
    func update(_ positionSheet: Sheet, and sheetType: String) -> Observable<Void>
    func delete(_ positionSheetId: String, and sheetType: String) -> Observable<Void>
    func uploadImage(_ image: UIImage, name: String) -> Observable<Void>
}
