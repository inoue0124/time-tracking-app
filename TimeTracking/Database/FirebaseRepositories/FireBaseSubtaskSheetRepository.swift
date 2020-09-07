import Firebase
import RxSwift

class FireBaseSubtaskSheetRepository: SubtaskSheetRepository {

    let db: Firestore

    var listener: ListenerRegistration?

    init() {
        self.db = Firestore.firestore()
        db.settings.isPersistenceEnabled = true
    }

    func create(with name: String) -> Observable<Void> {
        return Observable.create { [unowned self] observer in
            self.db.collection("subtask_sheets").addDocument(data: [
                "name": name,
                "is_public": false,
                "columns": ["Time", "内容", "Q&A", "確認", "担当者"],
                "create_user": (Auth.auth().currentUser?.uid)!,
                "created_at": Date(),
                "update_user": (Auth.auth().currentUser?.uid)!,
                "updated_at": Date()
            ]) { error in
                if let e = error {
                    observer.onError(e)
                    return
                }
                observer.onNext(())
            }
            return Disposables.create()
        }
    }

    func read() -> Observable<[Sheet]> {
        let options = QueryListenOptions()
        options.includeQueryMetadataChanges(true)

        return Observable.create { [unowned self] observer in
            self.listener = self.db.collection("subtask_sheets")
                .order(by: "updated_at")
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

                    var subtaskSheets: [Sheet] = []
                    if !snap.isEmpty {
                        for item in snap.documents {
                            subtaskSheets.append(Sheet(
                                id: item.documentID,
                                name: item["name"] as? String ?? "",
                                isPublic: item["is_public"] as? Bool ?? false,
                                columnTitles: item["columnTitles"] as? [String] ?? [""],
                                columnTypes: item["columnTypes"] as? [String] ?? [""],
                                createUser: item["create_user"] as? String ?? "",
                                createdAt: item["created_at"] as? Date ?? Date(),
                                updateUser: item["update_user"] as? String ?? "",
                                updatedAt: item["updated_at"] as? Date ?? Date()
                            ))
                        }
                    }
                    observer.onNext(subtaskSheets)
            }
            return Disposables.create()
        }
    }

    func update(_ subtaskSheet: Sheet) -> Observable<Void> {
        return Observable.create { [unowned self] observer in
            self.db.collection("subtask_sheets").document(subtaskSheet.id).updateData([
                "name": subtaskSheet.name,
                "is_public": subtaskSheet.isPublic,
                "column_titles": subtaskSheet.columnTitles,
                "update_user": (Auth.auth().currentUser?.uid)!,
                "updated_at": Date()
                ]) { error in
                if let e = error {
                    observer.onError(e)
                    return
                }
                observer.onNext(())
            }
            return Disposables.create()
        }
    }

    func delete(_ subtaskSheetId: String) -> Observable<Void> {
        return Observable.create { [unowned self] observer in
            self.db.collection("subtask_sheets").document(subtaskSheetId).delete() { error in
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
