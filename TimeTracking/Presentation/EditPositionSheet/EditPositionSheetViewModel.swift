import Foundation
import RxSwift
import RxCocoa

class EditPositionSheetViewModel: ViewModelType {

    struct Input {
        let loadTrigger: Driver<Void>
        let saveTrigger: Driver<Void>
        let sheet: Driver<PositionSheet>
        let tasks: Driver<[Task]>
        let uploadImageTrigger: Driver<UIImage>
        let imageName: Driver<String>
    }

    struct Output {
        let load: Driver<Void>
        let tasks: Driver<[Task]>
        let sheet: Driver<PositionSheet>
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

    private let editPositionSheetUseCase: EditPositionSheetUseCase
    private let navigator: EditPositionSheetNavigator
    private let sheetId: String?
    private let sheetName: String?
    let appConst = AppConst()

    init(with editPositionSheetUseCase: EditPositionSheetUseCase, and navigator: EditPositionSheetNavigator,
         and sheetId: String? = nil, and sheetName: String? = nil) {
        self.editPositionSheetUseCase = editPositionSheetUseCase
        self.navigator = navigator
        self.sheetId = sheetId
        self.sheetName = sheetName
    }

    func transform(input: EditPositionSheetViewModel.Input) -> EditPositionSheetViewModel.Output {
        let state = State()
        let load = input.loadTrigger
            .flatMap { [unowned self] _ -> Driver<Void> in
                if (self.sheetId != nil) {
                    return self.editPositionSheetUseCase.loadTasks(with: self.sheetId!, and: self.appConst.SHEET_TYPE_POSITION)
                        .trackArray(state.contentArray)
                        .trackError(state.error)
                        .trackActivity(state.isLoading)
                        .mapToVoid()
                        .asDriverOnErrorJustComplete()
                } else {
                    return Observable.create { [unowned self] observer in return Disposables.create() }.asDriverOnErrorJustComplete()
                }
        }
        let sheet = input.loadTrigger
            .flatMap { [unowned self] _ -> Driver<PositionSheet> in
                if (self.sheetId != nil) {
                    return self.editPositionSheetUseCase.getPositionSheetById(with: self.sheetId!).asDriverOnErrorJustComplete()
                } else {
                    return Observable.create { observer in return Disposables.create() }.asDriverOnErrorJustComplete()
                }
        }
        let requiredInputs = Driver.combineLatest(input.sheet, input.tasks)
        let save = input.saveTrigger
            .withLatestFrom(requiredInputs)
            .flatMapLatest { [unowned self] (sheet: PositionSheet, tasks: [Task]) -> Driver<Void> in
                if (self.sheetId != nil) {
                    return self.editPositionSheetUseCase.updateSheet(with: sheet)
                    .flatMap { [unowned self] _ in
                        self.editPositionSheetUseCase.updateTasks(with: tasks, and: sheet.id, and: self.appConst.SHEET_TYPE_POSITION)
                            .do(onNext: { [unowned self] in
                                self.navigator.toSheetSetting()
                            })
                    }
                    .trackError(state.error)
                    .asDriver(onErrorJustReturn: ())
                } else {
                    sheet.name = self.sheetName!
                    return self.editPositionSheetUseCase.saveSheet(with: sheet)
                    .flatMap { [unowned self] (sheetId: String) in
                        self.editPositionSheetUseCase.saveTasks(with: tasks, and: sheetId, and: self.appConst.SHEET_TYPE_POSITION)
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
                return self.editPositionSheetUseCase.uploadImage(image, name: imageName).asDriver(onErrorJustReturn: ())
        }
        return EditPositionSheetViewModel.Output(load: load,
                                         tasks: state.contentArray.asDriver(),
                                         sheet: sheet,
                                         save: save,
                                         uploadImage: uploadImage,
                                         isLoading: state.isLoading.asDriver(),
                                         error: state.error.asDriver())
    }
}
