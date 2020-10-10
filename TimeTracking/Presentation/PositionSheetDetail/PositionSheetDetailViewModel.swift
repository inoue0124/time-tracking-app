import Foundation
import RxSwift
import RxCocoa

class PositionSheetDetailViewModel: ViewModelType {
    
    struct Input {
        let loadTrigger: Driver<Void>
    }
    
    struct Output {
        let load: Driver<Void>
        let tasks: Driver<[Task]>
        let isLoading: Driver<Bool>
        let error: Driver<Error>
    }
    
    struct State {
        let contentArray = ArrayTracker<Task>()
        let isLoading = ActivityIndicator()
        let error = ErrorTracker()
    }
    
    private let useCase: PositionSheetDetailUseCase
    private let navigator: PositionSheetDetailNavigator
    private let sheetId: String?
    let appConst = AppConst()
    
    init(with useCase: PositionSheetDetailUseCase, and navigator: PositionSheetDetailNavigator, and sheetId: String? = nil) {
        self.useCase = useCase
        self.navigator = navigator
        self.sheetId = sheetId
    }
    
    func transform(input: PositionSheetDetailViewModel.Input) -> PositionSheetDetailViewModel.Output {
        let state = State()
        let load = input.loadTrigger
            .flatMap { [unowned self] _ -> Driver<Void> in
                if (self.sheetId != nil) {
                    return self.useCase.loadTasks(with: self.sheetId!, and: self.appConst.SHEET_TYPE_POSITION)
                        .trackArray(state.contentArray)
                        .trackError(state.error)
                        .trackActivity(state.isLoading)
                        .mapToVoid()
                        .asDriverOnErrorJustComplete()
                } else {
                    return Observable.create { observer in return Disposables.create() }.asDriverOnErrorJustComplete()
                }
        }
        return PositionSheetDetailViewModel.Output(load: load,
                                     tasks: state.contentArray.asDriver(),
                                     isLoading: state.isLoading.asDriver(),
                                     error: state.error.asDriver())
    }
}
