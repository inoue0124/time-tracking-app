import Firebase
import FirebaseStorage
import RxSwift

class FBTopSheetRepository: TopSheetRepository {

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

    func read() -> Observable<[TopSheet]> {
        let options = QueryListenOptions()
        options.includeQueryMetadataChanges(true)

        return Observable.create { [unowned self] observer in
            self.listener = self.db.collection("top_sheets")
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

                    var topSheets: [TopSheet] = []
                    if !snap.isEmpty {
                        for item in snap.documents {
                            topSheets.append(TopSheet(
                                id: item.documentID,
                                name: item["name"] as? String ?? "",
                                isPublic: item["is_public"] as? Bool ?? false,
                                positionSheetIds: item["position_sheet_ids"] as? [String] ?? [],
                                createUser: item["create_user"] as? String ?? "",
                                createdAt: item["created_at"] as? Date ?? Date(),
                                updateUser: item["update_user"] as? String ?? "",
                                updatedAt: item["updated_at"] as? Date ?? Date()
                            ))
                        }
                    }
                    observer.onNext(topSheets)
            }
            return Disposables.create()
        }
    }

    func readPositionSheets(with id: String) -> Observable<[PositionSheet]> {
        let options = QueryListenOptions()
        options.includeQueryMetadataChanges(true)

        return Observable.create { [unowned self] observer in
            self.listener = self.db.collection("top_sheets")
                .whereField("id", isEqualTo: id)
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

                    var positionSheets: [PositionSheet] = []

                    if !snap.isEmpty {
                        for item in snap.documents {

                            positionSheets.append(PositionSheet(
                                id: item.documentID,
                                name: item["name"] as? String ?? "",
                                type: "",
                                isPublic: item["is_public"] as? Bool ?? false,
                                columnTitles: [],
                                columnTypes: [],
                                columnWidths: [],
                                createUser: item["create_user"] as? String ?? "",
                                createdAt: item["created_at"] as? Date ?? Date(),
                                updateUser: item["update_user"] as? String ?? "",
                                updatedAt: item["updated_at"] as? Date ?? Date()
                            ))

                            for id in item["position_sheet_ids"] as! [String] {
                                self.db.collection("position_sheets")
                                    .whereField("id", isEqualTo: id)
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

                                        if !snap.isEmpty {
                                            for item in snap.documents {
                                                positionSheets.append(PositionSheet(
                                                    id: item.documentID,
                                                    name: item["name"] as? String ?? "",
                                                    type: item["type"] as? String ?? "",
                                                    isPublic: item["is_public"] as? Bool ?? false,
                                                    columnTitles: item["column_titles"] as? [String] ?? [],
                                                    columnTypes: item["column_types"] as? [String] ?? [],
                                                    columnWidths: item["column_widths"] as? [Int] ?? [],
                                                    createUser: item["create_user"] as? String ?? "",
                                                    createdAt: item["created_at"] as? Date ?? Date(),
                                                    updateUser: item["update_user"] as? String ?? "",
                                                    updatedAt: item["updated_at"] as? Date ?? Date()
                                                ))
                                            }
                                        }
                                        observer.onNext(positionSheets)
                                    }
                            }
                        }
                    }
            }
            return Disposables.create()
        }
    }

    func delete(_ id: String) -> Observable<Void> {
        return Observable.create { [unowned self] observer in Disposables.create() }
    }
}
