import Firebase
import FirebaseStorage
import RxSwift

class FBTemplateRepository: TemplateRepository {

    let db: Firestore
    let storage = Storage.storage()

    var listener: ListenerRegistration?

    init() {
        self.db = Firestore.firestore()
        db.settings.isPersistenceEnabled = true
    }

    func read(with type: String) -> Observable<[Sheet]> {
        let options = QueryListenOptions()
        options.includeQueryMetadataChanges(true)

        return Observable.create { [unowned self] observer in
            self.listener = self.db.collection(type)
                .whereField("create_user", isEqualTo: (Auth.auth().currentUser?.uid)!)
                .order(by: "updated_at", descending: true)
                .addSnapshotListener(options: options) { snapshot, error in
                    guard let snap = snapshot else {
                        print("Error fetching document: \(error!)")
                        observer.onError(error!)
                        return
                    }
                    for diff in snap.documentChanges {
                        if diff.type == .added {
                            print("New data: \(diff.document.data())")
                        }
                    }
                    print("Current data: \(snap)")

                    var templates: [Sheet] = []
                    if !snap.isEmpty {
                        for item in snap.documents {
                            templates.append(Sheet(
                                id: item.documentID,
                                name: item["name"] as? String ?? "",
                                isPublic: item["is_public"] as? Bool ?? false,
                                createUser: item["create_user"] as? String ?? "",
                                createdAt: item["created_at"] as? Date ?? Date(),
                                updateUser: item["update_user"] as? String ?? "",
                                updatedAt: item["updated_at"] as? Date ?? Date()
                            ))
                        }
                    }
                    observer.onNext(templates)
            }
            return Disposables.create()
        }
    }
}
