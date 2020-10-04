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
        let sheet: Driver<Sheet>
        let isLoading: Driver<Bool>
        let error: Driver<Error>
    }
    
    struct State {
        let contentArray = ArrayTracker<Task>()
        let isLoading = ActivityIndicator()
        let error = ErrorTracker()
    }
    
    private let useCase: TopSheetDetailUseCase
    private let navigator: TopSheetDetailNavigator
    private let sheet: Sheet?
    
    init(with useCase: TopSheetDetailUseCase, and navigator: TopSheetDetailNavigator, and sheet: Sheet? = nil) {
        self.useCase = useCase
        self.navigator = navigator
        self.sheet = sheet
    }
    
    func transform(input: TopSheetDetailViewModel.Input) -> TopSheetDetailViewModel.Output {
        let state = State()
        let load = input.loadTrigger
            .flatMap { [unowned self] _ in
                return self.useCase.loadTasks(with: ["HXcCkW6ev3KP9Y9OC6Uh", "IqOzYKralPP0C40X6Ewn"])
                    .trackArray(state.contentArray)
                    .trackError(state.error)
                    .trackActivity(state.isLoading)
                    .mapToVoid()
                    .asDriverOnErrorJustComplete()
        }
        return TopSheetDetailViewModel.Output(load: load,
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
