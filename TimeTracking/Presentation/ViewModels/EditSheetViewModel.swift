import Foundation
import RxSwift
import RxCocoa

class EditSheetViewModel: ViewModelType {

    struct Input {
        let loadTrigger: Driver<Void>
        let saveTrigger: Driver<Void>
        let sheet: Driver<Sheet>
        let tasks: Driver<[Task]>
        let uploadImageTrigger: Driver<UIImage>
        let imageName: Driver<String>
    }

    struct Output {
        let load: Driver<Void>
        let tasks: Driver<[Task]>
        let sheet: Driver<Sheet>
        let save: Driver<Void>
        let uploadImage: Driver<Void>
        let isLoading: Driver<Bool>
        let error: Driver<Error>
    }

    struct State {
        let contentArray = ArrayTracker<Task>()
        let isLoading = ActivityIndicator()
        let error = ErrorTracker()
    }

    private let editSheetUseCase: EditSheetUseCase
    private let navigator: EditSheetNavigator
    private let sheet: Sheet?

    init(with editSheetUseCase: EditSheetUseCase, and navigator: EditSheetNavigator, and sheet: Sheet? = nil) {
        self.editSheetUseCase = editSheetUseCase
        self.navigator = navigator
        self.sheet = sheet
    }

    func transform(input: EditSheetViewModel.Input) -> EditSheetViewModel.Output {
        let state = State()
        let load = input.loadTrigger
            .flatMap { [unowned self] _ -> Driver<Void> in
                if (self.sheet!.id != "" && self.sheet!.type != "") {
                    return self.editSheetUseCase.loadTasks(with: self.sheet!.id, and: self.sheet!.type)
                        .trackArray(state.contentArray)
                        .trackError(state.error)
                        .trackActivity(state.isLoading)
                        .mapToVoid()
                        .asDriverOnErrorJustComplete()
                } else {
                    return Observable.create { [unowned self] observer in return Disposables.create() }.asDriverOnErrorJustComplete()
                }
        }
        let requiredInputs = Driver.combineLatest(input.sheet, input.tasks)
        let save = input.saveTrigger
            .withLatestFrom(requiredInputs)
            .flatMapLatest { [unowned self] (sheet: Sheet, tasks: [Task]) -> Driver<Void> in
                if (self.sheet!.id != "" && self.sheet!.type != "") {
                    return self.editSheetUseCase.updateSheet(with: sheet)
                    .flatMap { [unowned self] _ in
                        self.editSheetUseCase.updateTasks(with: tasks, and: sheet.id, and: sheet.type)
                            .do(onNext: { [unowned self] in
                                self.navigator.toSheetSetting()
                            })
                    }
                    .trackError(state.error)
                    .asDriver(onErrorJustReturn: ())
                } else {
                    return self.editSheetUseCase.saveSheet(with: sheet)
                    .flatMap { [unowned self] (sheetId: String) in
                        self.editSheetUseCase.saveTasks(with: tasks, and: sheetId, and: sheet.type)
                            .do(onNext: { [unowned self] in
                                self.navigator.toSheetSetting()
                            })
                    }
                    .trackError(state.error)
                    .asDriver(onErrorJustReturn: ())
                }
        }
        let uploadImage = input.uploadImageTrigger
            .withLatestFrom(Driver.combineLatest(input.uploadImageTrigger, input.imageName))
            .flatMapLatest { [unowned self] (image: UIImage, imageName: String) -> Driver<Void> in
                return self.editSheetUseCase.uploadImage(image, name: imageName).asDriver(onErrorJustReturn: ())
        }
        return EditSheetViewModel.Output(load: load,
                                         tasks: state.contentArray.asDriver(),
                                         sheet: Observable.create { [unowned self] observer in
                                            if (self.sheet == nil) {
                                                observer.onError(Exception.unknown)
                                                return Disposables.create()
                                            } else {
                                                observer.onNext(self.sheet!)
                                                return Disposables.create()
                                            }
                                         }.asDriverOnErrorJustComplete(),
                                         save: save,
                                         uploadImage: uploadImage,
                                         isLoading: state.isLoading.asDriver(),
                                         error: state.error.asDriver())
    }
}
