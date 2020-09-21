import Foundation
import RxSwift
import RxCocoa

class SheetViewModel: ViewModelType {
    
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
    
    private let sheetUseCase: SheetUseCase
    private let navigator: SheetNavigator
    private let sheet: Sheet?
    
    init(with sheetUseCase: SheetUseCase, and navigator: SheetNavigator, and sheet: Sheet? = nil) {
        self.sheetUseCase = sheetUseCase
        self.navigator = navigator
        self.sheet = sheet
    }
    
    func transform(input: SheetViewModel.Input) -> SheetViewModel.Output {
        let state = State()
        let load = input.loadTrigger
            .flatMap { [unowned self] _ in
                return self.sheetUseCase.loadTasks(with: self.sheet!.id, and: self.sheet!.type)
                    .trackArray(state.contentArray)
                    .trackError(state.error)
                    .trackActivity(state.isLoading)
                    .mapToVoid()
                    .asDriverOnErrorJustComplete()
        }
        return SheetViewModel.Output(load: load,
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
