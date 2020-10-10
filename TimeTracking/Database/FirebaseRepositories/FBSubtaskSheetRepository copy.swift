import Firebase
import FirebaseStorage
import RxSwift

class FBSubtaskSheetRepository: SubtaskSheetRepository {

    let db: Firestore
    let storage = Storage.storage()
    let imageResizer = ImageResizer()

    var listener: ListenerRegistration?

    init() {
        self.db = Firestore.firestore()
        db.settings.isPersistenceEnabled = true
    }

    func create(with sheet: SubtaskSheet) -> Observable<String> {
        print(sheet)
        return Observable.create { [unowned self] observer in
            let ref = self.db.collection("subtask_sheets").document()
            ref.setData([
                "id": ref.documentID,
                "name": sheet.name,
                "is_public": false,
                "column_titles": sheet.columnTitles,
                "column_types": sheet.columnTypes,
                "column_widths": sheet.columnWidths,
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

    func read() -> Observable<[SubtaskSheet]> {
        let options = QueryListenOptions()
        options.includeQueryMetadataChanges(true)

        return Observable.create { [unowned self] observer in
            self.listener = self.db.collection("subtask_sheets")
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

                    var positionSheets: [SubtaskSheet] = []
                    if !snap.isEmpty {
                        for item in snap.documents {
                            positionSheets.append(SubtaskSheet(
                                id: item.documentID,
                                name: item["name"] as? String ?? "",
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
            return Disposables.create()
        }
    }

    func readById(with id: String) -> Observable<SubtaskSheet> {
        let options = QueryListenOptions()
        options.includeQueryMetadataChanges(true)

        return Observable.create { [unowned self] observer in
            self.listener = self.db.collection("subtask_sheets")
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

                    var subtaskSheet = SubtaskSheet()
                    if !snap.isEmpty {
                        for item in snap.documents {
                            subtaskSheet = SubtaskSheet(
                                id: item.documentID,
                                name: item["name"] as? String ?? "",
                                isPublic: item["is_public"] as? Bool ?? false,
                                columnTitles: item["column_titles"] as? [String] ?? [],
                                columnTypes: item["column_types"] as? [String] ?? [],
                                columnWidths: item["column_widths"] as? [Int] ?? [],
                                createUser: item["create_user"] as? String ?? "",
                                createdAt: item["created_at"] as? Date ?? Date(),
                                updateUser: item["update_user"] as? String ?? "",
                                updatedAt: item["updated_at"] as? Date ?? Date()
                            )
                        }
                    }
                    observer.onNext(subtaskSheet)
            }
            return Disposables.create()
        }
    }

    func update(_ sheet: SubtaskSheet) -> Observable<Void> {
        return Observable.create { [unowned self] observer in
            self.db.collection("subtask_sheets").document(sheet.id).updateData([
                "name": sheet.name,
                "is_public": false,
                "column_titles": sheet.columnTitles,
                "column_types": sheet.columnTypes,
                "column_widths": sheet.columnWidths,
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

    func delete(_ sheetId: String, and sheetType: String) -> Observable<Void> {
        return Observable.create { [unowned self] observer in
            self.db.collection(sheetType).document(sheetId).delete() { error in
                if let e = error {
                    observer.onError(e)
                    return
                }
                observer.onNext(())
            }
            return Disposables.create()
        }
    }

    func uploadImage(_ image: UIImage, name: String) -> Observable<Void> {
        guard image != UIImage() else { return Observable.create { observer in Disposables.create() } }
        let storageRef = storage.reference().child("noteImages/" + name + ".jpg")
        let resizedImage = imageResizer.resizeImage(image: image, targetSize: CGSize(width: 500.0, height: 500.0))
        let jpgData = UIImageJPEGRepresentation(resizedImage, 0.7)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        return Observable.create { observer in
            storageRef.putData(jpgData!, metadata: metadata) { (metadata, error) in
                if let e = error {
                    observer.onError(e)
                    return
                }
            }
            return Disposables.create()
        }
    }
}
