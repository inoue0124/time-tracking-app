import Foundation
import RxSwift
import RxCocoa

class AddSheetViewModel: ViewModelType {

    struct Input {
        let loadTemplateTrigger: Driver<String>
        let createTrigger: Driver<Void>
        let sheet: Driver<Sheet>
    }

    struct Output {
        let loadTemplate: Driver<Void>
        let create: Driver<Void>
        let templates: Driver<[Sheet]>
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
                if (sheetType == self.appConst.SHEET_TYPE_POSITION) {
                    return self.addSheetUseCase.loadPositionSheets()
                        .trackArray(state.templateArray)
                        .trackError(state.errorLoadingTemplate)
                        .trackActivity(state.isLoadingTemplate)
                        .mapToVoid()
                        .asDriverOnErrorJustComplete()
                } else if (sheetType == self.appConst.SHEET_TYPE_SUBTASK) {
                    return self.addSheetUseCase.loadSubtaskSheets()
                        .trackArray(state.templateArray)
                        .trackError(state.errorLoadingTemplate)
                        .trackActivity(state.isLoadingTemplate)
                        .mapToVoid()
                        .asDriverOnErrorJustComplete()
                } else {
                    return Driver.just(())
                }
        }
        let create = input.createTrigger
            .withLatestFrom(input.sheet) { [unowned self] (_, sheet: Sheet) in
                if (sheet.type == self.appConst.SHEET_TYPE_TOP) {
                    self.navigator.toCreateTopSheet()
                } else {
                    self.navigator.toCreateSheet(with: sheet)
                }
        }
        return AddSheetViewModel.Output(
            loadTemplate: loadTemplate,
            create: create,
            templates: state.templateArray.asDriver(),
            isLoadingTemplate: state.isLoadingTemplate.asDriver(),
            errorLoadingTemplate: state.errorLoadingTemplate.asDriver()
        )
    }
}
