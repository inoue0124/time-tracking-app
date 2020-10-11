import Foundation
import RxSwift

protocol DateRepository {
    func set(_ date: Date) -> Observable<Void>
    func read() -> Observable<Date>
}
