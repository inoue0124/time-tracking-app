import Foundation
import RxSwift

protocol UserRepository {
    func setWeekSheetIds(_ weekSheetIds: [String:String]) -> Observable<Void>
}
