import Foundation
import RxSwift

protocol SubtaskSheetRepository {
    func create(with sheet: SubtaskSheet) -> Observable<String>
    func read(with sheetType: String) -> Observable<[SubtaskSheet]>
    func update(_ positionSheet: SubtaskSheet) -> Observable<Void>
    func delete(_ positionSheetId: String, and sheetType: String) -> Observable<Void>
    func uploadImage(_ image: UIImage, name: String) -> Observable<Void>
}
