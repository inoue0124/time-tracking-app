import Firebase
import RxSwift

class FireBaseTaskRepository: TaskRepository {

    let appConst = AppConst()
    let db: Firestore

    var listener: ListenerRegistration?

    init() {
        self.db = Firestore.firestore()
        db.settings.isPersistenceEnabled = true
    }

    func create(with tasks: [Task], and sheetId: String, and sheetType: String) -> Observable<Void> {
        let batch = db.batch()
        for task in tasks {
        let dbRef = db.collection(sheetType).document(sheetId).collection("tasks").document()
            batch.setData([
                "id": dbRef.documentID,
                "data": task.data,
                "create_user": (Auth.auth().currentUser?.uid)!,
                "created_at": Date(),
                "update_user": (Auth.auth().currentUser?.uid)!,
                "updated_at": Date()
            ], forDocument: dbRef)
        }
        return Observable.create { observer in
            batch.commit() { error in
                if let e = error {
                    observer.onError(e)
                    return
                }
                observer.onNext(())
            }
            return Disposables.create()
        }
    }

    func read(with sheetId: String, and sheetType: String) -> Observable<[Task]> {
        let options = QueryListenOptions()
        options.includeQueryMetadataChanges(true)

        return Observable.create { [unowned self] observer in
            self.listener = self.db.collection(sheetType).document(sheetId).collection("tasks")
                .order(by: "created_at")
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

                    var tasks: [Task] = []
                    if !snap.isEmpty {
                        for item in snap.documents {
                            print(item)
                            tasks.append(Task(id: item.documentID,
                                              data: item["data"] as? [Any] ?? [],
                                              createUser: item["create_user"] as? String ?? "",
                                              createdAt: item["created_at"] as? Date ?? Date(),
                                              updateUser: item["update_user"] as? String ?? "",
                                              updatedAt: item["updated_at"] as? Date ?? Date()
                            ))
                        }
                    }
                    observer.onNext(tasks)
            }
            return Disposables.create()
        }
    }

    func update(with tasks: [Task], and sheetId: String, and sheetType: String) -> Observable<Void> {
        let batch = db.batch()
        for task in tasks {
            var dbRef: DocumentReference?
            if (task.id == "") {
                dbRef = db.collection(sheetType).document(sheetId).collection("tasks").document()
                batch.setData([
                    "id": dbRef!.documentID,
                    "data": task.data,
                    "create_user": (Auth.auth().currentUser?.uid)!,
                    "created_at": Date(),
                    "update_user": (Auth.auth().currentUser?.uid)!,
                    "updated_at": Date()
                ], forDocument: dbRef!)
            } else {
                dbRef = db.collection(sheetType).document(sheetId).collection("tasks").document(task.id)
                batch.updateData([
                    "id": dbRef!.documentID,
                    "data": task.data,
                    "update_user": (Auth.auth().currentUser?.uid)!,
                    "updated_at": Date()
                ], forDocument: dbRef!)
            }
        }
        return Observable.create { observer in
            batch.commit() { error in
                if let e = error {
                    observer.onError(e)
                    return
                }
                observer.onNext(())
            }
            return Disposables.create()
        }
    }

    func delete(with documentId: String, and sheetId: String, and sheetType: String) -> Observable<Void> {
        return Observable.create { [unowned self] observer in
            self.db.collection(sheetType).document(sheetId).collection("tasks").document(documentId).delete() { error in
                if let e = error {
                    observer.onError(e)
                    return
                }
                observer.onNext(())
            }
            return Disposables.create()
        }
    }
}
