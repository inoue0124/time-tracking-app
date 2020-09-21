import Foundation
import RxSwift
import RxCocoa

class SheetViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
    }
    
    struct Output {
        let load: Driver<Void>
        let tasks: Driver<[Task]>
        let positionSheet: Driver<Sheet>
        let isLoading: Driver<Bool>
        let error: Driver<Error>
    }
    
    struct State {
        let contentArray = ArrayTracker<Task>()
        let isLoading = ActivityIndicator()
        let error = ErrorTracker()
    }
    
    private let sheetUseCase: SheetUseCase
    private let navigator: SheetNavigator
    private let positionSheet: Sheet?
    
    init(with sheetUseCase: SheetUseCase, and navigator: SheetNavigator, and positionSheet: Sheet? = nil) {
        self.sheetUseCase = sheetUseCase
        self.navigator = navigator
        self.positionSheet = positionSheet
    }
    
    func transform(input: SheetViewModel.Input) -> SheetViewModel.Output {
        let state = State()
        let load = input.trigger
            .flatMap { [unowned self] _ in
                return self.sheetUseCase.loadTasks(with: self.positionSheet!.id, and: self.positionSheet!.type)
                    .trackArray(state.contentArray)
                    .trackError(state.error)
                    .trackActivity(state.isLoading)
                    .mapToVoid()
                    .asDriverOnErrorJustComplete()
        }
        return SheetViewModel.Output(load: load,
                                    tasks: state.contentArray.asDriver(),
                                    positionSheet: Observable.create { [unowned self] observer in
                                        if (self.positionSheet == nil) {
                                            observer.onError(Exception.unknown)
                                            return Disposables.create()
                                        } else {
                                            observer.onNext(self.positionSheet!)
                                            return Disposables.create()
                                        }
                                    }.asDriverOnErrorJustComplete(),
                                    isLoading: state.isLoading.asDriver(),
                                    error: state.error.asDriver())
    }
}
