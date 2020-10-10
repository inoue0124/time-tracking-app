import Foundation
import RxSwift

protocol TemplateRepository {
    func read(with type: String) -> Observable<[Sheet]>
}
