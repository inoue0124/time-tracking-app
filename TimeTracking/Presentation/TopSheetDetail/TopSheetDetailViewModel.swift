import Foundation
import RxSwift
import RxCocoa

class TopSheetDetailViewModel: ViewModelType {
    
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
        let sheetArray = ArrayTracker<TopSheet>()
        let contentArray = ArrayTracker<Task>()
        let isLoading = ActivityIndicator()
        let error = ErrorTracker()
    }
    
    private let useCase: TopSheetDetailUseCase
    private let navigator: TopSheetDetailNavigator
    private let sheetId: String?
    private var topSheet: TopSheet?
    let disposeBag = DisposeBag()
    
    init(with useCase: TopSheetDetailUseCase, and navigator: TopSheetDetailNavigator, and sheetId: String? = nil) {
        self.useCase = useCase
        self.navigator = navigator
        self.sheetId = sheetId
    }
    
    func transform(input: TopSheetDetailViewModel.Input) -> TopSheetDetailViewModel.Output {
        let state = State()
        let load = input.loadTrigger
            .flatMap { [unowned self] _ -> Driver<Void> in
                return self.useCase.getTopSheetById(with: self.sheetId!).map({ (topSheet) in
                    self.useCase.loadTasks(with: topSheet.positionSheetIds).do()
                    .trackArray(state.contentArray)
                    .trackError(state.error)
                    .trackActivity(state.isLoading)
                    .mapToVoid()
                    .asDriverOnErrorJustComplete().drive().disposed(by: self.disposeBag)
                }).mapToVoid().asDriverOnErrorJustComplete()
        }

        return TopSheetDetailViewModel.Output(load: load,
                                              tasks: state.contentArray.asDriver(),
                                              isLoading: state.isLoading.asDriver(),
                                              error: state.error.asDriver())
    }
}
