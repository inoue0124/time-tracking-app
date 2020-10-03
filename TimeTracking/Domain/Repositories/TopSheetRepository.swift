import Foundation
import RxSwift

protocol TopSheetRepository {
    func create(with sheet: TopSheet) -> Observable<String>
}
