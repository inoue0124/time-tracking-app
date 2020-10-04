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
    private let sheet: SubtaskSheet?
    
    init(with useCase: SubtaskSheetDetailUseCase, and navigator: SubtaskSheetDetailNavigator, and sheet: SubtaskSheet? = nil) {
        self.useCase = useCase
        self.navigator = navigator
        self.sheet = sheet
    }
    
    func transform(input: SubtaskSheetDetailViewModel.Input) -> SubtaskSheetDetailViewModel.Output {
        let state = State()
        let load = input.loadTrigger
            .flatMap { [unowned self] _ in
                return self.useCase.loadTasks(with: self.sheet!.id, and: self.sheet!.type)
                    .trackArray(state.contentArray)
                    .trackError(state.error)
                    .trackActivity(state.isLoading)
                    .mapToVoid()
                    .asDriverOnErrorJustComplete()
        }
        return SubtaskSheetDetailViewModel.Output(load: load,
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
                                     isLoading: state.isLoading.asDriver(),
                                     error: state.error.asDriver())
    }
}
