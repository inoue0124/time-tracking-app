import Foundation
import RxSwift
import RxCocoa

class SubtaskSheetDetailViewModel: ViewModelType {
    
    struct Input {
        let loadTrigger: Driver<Void>
    }
    
    struct Output {
        let load: Driver<Void>
        let tasks: Driver<[Task]>
        let sheet: Driver<SubtaskSheet>
        let isLoading: Driver<Bool>
        let error: Driver<Error>
    }
    
    struct State {
        let contentArray = ArrayTracker<Task>()
        let isLoading = ActivityIndicator()
        let error = ErrorTracker()
    }
    
    private let useCase: SubtaskSheetDetailUseCase
    private let navigator: SubtaskSheetDetailNavigator
    private let sheetId: String?
    let appConst = AppConst()
    
    init(with useCase: SubtaskSheetDetailUseCase, and navigator: SubtaskSheetDetailNavigator, and sheetId: String? = nil) {
        self.useCase = useCase
        self.navigator = navigator
        self.sheetId = sheetId
    }
    
    func transform(input: SubtaskSheetDetailViewModel.Input) -> SubtaskSheetDetailViewModel.Output {
        let state = State()
        let load = input.loadTrigger
            .flatMap { [unowned self] _ -> Driver<Void> in
                if (self.sheetId != nil) {
                    return self.useCase.loadTasks(with: self.sheetId!, and: self.appConst.SHEET_TYPE_SUBTASK)
                        .trackArray(state.contentArray)
                        .trackError(state.error)
                        .trackActivity(state.isLoading)
                        .mapToVoid()
                        .asDriverOnErrorJustComplete()
                } else {
                    return Observable.create { observer in return Disposables.create() }.asDriverOnErrorJustComplete()
                }
        }
        let sheet = input.loadTrigger
            .flatMap { [unowned self] _ -> Driver<SubtaskSheet> in
                if (self.sheetId != nil) {
                    return self.useCase.getSubtaskSheetById(with: self.sheetId!).asDriverOnErrorJustComplete()
                } else {
                    return Observable.create { observer in return Disposables.create() }.asDriverOnErrorJustComplete()
                }
        }
        return SubtaskSheetDetailViewModel.Output(load: load,
                                     tasks: state.contentArray.asDriver(),
                                     sheet: sheet,
                                     isLoading: state.isLoading.asDriver(),
                                     error: state.error.asDriver())
    }
}
