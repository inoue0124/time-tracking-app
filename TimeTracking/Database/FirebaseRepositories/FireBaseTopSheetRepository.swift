import Firebase
import FirebaseStorage
import RxSwift

class FireBaseTopSheetRepository: TopSheetRepository {

    let db: Firestore
    let storage = Storage.storage()
    let imageResizer = ImageResizer()

    var listener: ListenerRegistration?

    init() {
        self.db = Firestore.firestore()
        db.settings.isPersistenceEnabled = true
    }

    func create(with sheet: TopSheet) -> Observable<String> {
        return Observable.create { [unowned self] observer in
            let ref = self.db.collection("top_sheets").document()
            ref.setData([
                "id": ref.documentID,
                "name": sheet.name,
                "is_public": false,
                "position_sheet_ids": sheet.positionSheetIds,
                "create_user": (Auth.auth().currentUser?.uid)!,
                "created_at": Date(),
                "update_user": (Auth.auth().currentUser?.uid)!,
                "updated_at": Date()
            ]) { error in
                if let e = error {
                    observer.onError(e)
                    return
                }
                observer.onNext((ref.documentID))
            }
            return Disposables.create()
        }
    }
}
