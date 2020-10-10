import Foundation
import RxSwift
import RxCocoa

class AddSheetViewModel: ViewModelType {

    struct Input {
        let loadTemplateTrigger: Driver<String>
        let sheetType: Driver<String>
        let createTrigger: Driver<Void>
    }

    struct Output {
        let loadTemplate: Driver<Void>
        let templates: Driver<[Sheet]>
        let create: Driver<Void>
        let isLoadingTemplate: Driver<Bool>
        let errorLoadingTemplate: Driver<Error>
    }

    struct State {
        let templateArray = ArrayTracker<Sheet>()
        let isLoadingTemplate = ActivityIndicator()
        let errorLoadingTemplate = ErrorTracker()
    }

    private let addSheetUseCase: AddSheetUseCase
    private let navigator: AddSheetNavigator
    let appConst = AppConst()

    init(with addSheetUseCase: AddSheetUseCase, and navigator: AddSheetNavigator) {
        self.addSheetUseCase = addSheetUseCase
        self.navigator = navigator
    }

    func transform(input: AddSheetViewModel.Input) -> AddSheetViewModel.Output {
        let state = State()
        let loadTemplate = input.loadTemplateTrigger
            .flatMapLatest { [unowned self] (sheetType: String) -> Driver<Void> in
                if (sheetType == "") { return Observable.create { observer in return Disposables.create() }.asDriverOnErrorJustComplete() }
                return self.addSheetUseCase.loadTemplates(with: sheetType)
                    .trackArray(state.templateArray)
                    .trackError(state.errorLoadingTemplate)
                    .trackActivity(state.isLoadingTemplate)
                    .mapToVoid()
                    .asDriverOnErrorJustComplete()
        }
        let create = input.createTrigger
            .withLatestFrom(input.sheetType) { [unowned self] (_, sheetType: String) in
                self.navigator.toCreateSheet(with: sheetType)
        }
        return AddSheetViewModel.Output(
            loadTemplate: loadTemplate,
            templates: state.templateArray.asDriver(),
            create: create,
            isLoadingTemplate: state.isLoadingTemplate.asDriver(),
            errorLoadingTemplate: state.errorLoadingTemplate.asDriver()
        )
    }
}
