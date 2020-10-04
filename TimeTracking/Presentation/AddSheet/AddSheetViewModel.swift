import Foundation
import RxSwift
import RxCocoa

class AddSheetViewModel: ViewModelType {

    struct Input {
        let loadTemplateTrigger: Driver<String>
        let createTrigger: Driver<Void>
        let positionSheet: Driver<PositionSheet>
        let subtaskSheet: Driver<SubtaskSheet>
    }

    struct Output {
        let loadTemplate: Driver<Void>
        let create: Driver<Void>
        let positionSheetTemplates: Driver<[PositionSheet]>
        let subtaskSheetTemplates: Driver<[SubtaskSheet]>
        let isLoadingTemplate: Driver<Bool>
        let errorLoadingTemplate: Driver<Error>
    }

    struct State {
        let positionSheetTemplateArray = ArrayTracker<PositionSheet>()
        let subtaskSheetTemplateArray = ArrayTracker<SubtaskSheet>()
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
                        .trackArray(state.positionSheetTemplateArray)
                        .trackError(state.errorLoadingTemplate)
                        .trackActivity(state.isLoadingTemplate)
                        .mapToVoid()
                        .asDriverOnErrorJustComplete()
                } else if (sheetType == self.appConst.SHEET_TYPE_SUBTASK) {
                    return self.addSheetUseCase.loadSubtaskSheets()
                        .trackArray(state.subtaskSheetTemplateArray)
                        .trackError(state.errorLoadingTemplate)
                        .trackActivity(state.isLoadingTemplate)
                        .mapToVoid()
                        .asDriverOnErrorJustComplete()
                } else {
                    return Driver.just(())
                }
        }
        let create = input.createTrigger
            .withLatestFrom(input.subtaskSheet) { [unowned self] (_, subtaskSheet: SubtaskSheet) in
                if (subtaskSheet.type == self.appConst.SHEET_TYPE_TOP) {
                    self.navigator.toCreateTopSheet()
                } else {
                    self.navigator.toCreateSubtaskSheet(with: subtaskSheet)
                }
        }
        return AddSheetViewModel.Output(
            loadTemplate: loadTemplate,
            create: create,
            positionSheetTemplates: state.positionSheetTemplateArray.asDriver(),
            subtaskSheetTemplates: state.subtaskSheetTemplateArray.asDriver(),
            isLoadingTemplate: state.isLoadingTemplate.asDriver(),
            errorLoadingTemplate: state.errorLoadingTemplate.asDriver()
        )
    }
}
