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
        let sheet: Driver<Sheet>
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
    private let sheet: Sheet?
    
    init(with useCase: PositionSheetDetailUseCase, and navigator: PositionSheetDetailNavigator, and sheet: Sheet? = nil) {
        self.useCase = useCase
        self.navigator = navigator
        self.sheet = sheet
    }
    
    func transform(input: PositionSheetDetailViewModel.Input) -> PositionSheetDetailViewModel.Output {
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
        return PositionSheetDetailViewModel.Output(load: load,
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
