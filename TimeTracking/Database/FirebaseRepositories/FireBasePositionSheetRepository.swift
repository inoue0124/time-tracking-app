import Firebase
import RxSwift

class FireBasePositionSheetRepository: PositionSheetRepository {

    let db: Firestore

    var listener: ListenerRegistration?

    init() {
        self.db = Firestore.firestore()
        db.settings.isPersistenceEnabled = true
    }

    func create(with name: String, and columnTitles: [String], and columnTypes: [String]) -> Observable<String> {
        return Observable.create { [unowned self] observer in
            var ref: DocumentReference? = nil
            ref = self.db.collection("position_sheets").addDocument(data: [
                "name": name,
                "is_public": false,
                "column_titles": columnTitles,
                "column_types": columnTypes,
                "create_user": (Auth.auth().currentUser?.uid)!,
                "created_at": Date(),
                "update_user": (Auth.auth().currentUser?.uid)!,
                "updated_at": Date()
            ]) { error in
                if let e = error {
                    observer.onError(e)
                    return
                }
                observer.onNext((ref!.documentID))
            }
            return Disposables.create()
        }
    }

    func read() -> Observable<[Sheet]> {
        let options = QueryListenOptions()
        options.includeQueryMetadataChanges(true)

        return Observable.create { [unowned self] observer in
            self.listener = self.db.collection("position_sheets")
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

                    var positionSheets: [Sheet] = []
                    if !snap.isEmpty {
                        for item in snap.documents {
                            positionSheets.append(Sheet(
                                id: item.documentID,
                                name: item["name"] as? String ?? "",
                                isPublic: item["is_public"] as? Bool ?? false,
                                columnTitles: item["column_titles"] as? [String] ?? [""],
                                columnTypes: item["column_types"] as? [String] ?? [""],
                                createUser: item["create_user"] as? String ?? "",
                                createdAt: item["created_at"] as? Date ?? Date(),
                                updateUser: item["update_user"] as? String ?? "",
                                updatedAt: item["updated_at"] as? Date ?? Date()
                            ))
                        }
                    }
                    observer.onNext(positionSheets)
            }
            return Disposables.create()
        }
    }

    func update(_ positionSheet: Sheet) -> Observable<Void> {
        return Observable.create { [unowned self] observer in
            self.db.collection("position_sheets").document(positionSheet.id).updateData([
                "name": positionSheet.name,
                "is_public": positionSheet.isPublic,
                "columnTit": positionSheet.columnTitles,
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

    func delete(_ positionSheetId: String) -> Observable<Void> {
        return Observable.create { [unowned self] observer in
            self.db.collection("position_sheets").document(positionSheetId).delete() { error in
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
