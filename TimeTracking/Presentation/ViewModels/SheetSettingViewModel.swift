import Foundation
import RxSwift
import RxCocoa

class SheetSettingViewModel: ViewModelType {

    struct Input {
        let loadTrigger: Driver<Void>
        let selectPositionSheetTrigger: Driver<Int>
        let selectSubtaskSheetTrigger: Driver<Int>
    }

    struct Output {
        let loadPositionSheets: Driver<Void>
        let positionSheets: Driver<[Sheet]>
        let selectPositionSheet: Driver<Void>
        let isLoadingPositionSheets: Driver<Bool>
        let errorLoadingPositionSheets: Driver<Error>

        let loadSubtaskSheets: Driver<Void>
        let subtaskSheets: Driver<[Sheet]>
        let selectSubtaskSheet: Driver<Void>
        let isLoadingSubtaskSheets: Driver<Bool>
        let errorLoadingSubtaskSheets: Driver<Error>
    }

    struct State {
        let positionSheetsArray = ArrayTracker<Sheet>()
        let isLoadingPositionSheets = ActivityIndicator()
        let errorLoadingPositionSheets = ErrorTracker()

        let subtaskSheetsArray = ArrayTracker<Sheet>()
        let isLoadingSubtaskSheets = ActivityIndicator()
        let errorLoadingSubtaskSheets = ErrorTracker()
    }

    private let homeUseCase: HomeUseCase
    private let navigator: SheetSettingNavigator

    init(with homeUseCase: HomeUseCase, and navigator: SheetSettingNavigator) {
        self.homeUseCase = homeUseCase
        self.navigator = navigator
    }

    func transform(input: SheetSettingViewModel.Input) -> SheetSettingViewModel.Output {
        let loadPositionSheetsState = State()
        let loadPositionSheets = input.loadTrigger
            .flatMap { [unowned self] _ in
            return self.homeUseCase.loadPositionSheets()
                .trackArray(loadPositionSheetsState.positionSheetsArray)
                .trackError(loadPositionSheetsState.errorLoadingPositionSheets)
                .trackActivity(loadPositionSheetsState.isLoadingPositionSheets)
                .mapToVoid()
                .asDriverOnErrorJustComplete()
        }
        let selectPositionSheet = input.selectPositionSheetTrigger
            .withLatestFrom(loadPositionSheetsState.positionSheetsArray) { [unowned self] (index: Int, positionSheets: [Sheet]) in
//                self.navigator.toTaskList(with: positionSheets[index])
        }

        let loadSubtaskSheetsState = State()
        let loadSubtaskSheets = input.loadTrigger
            .flatMap { [unowned self] _ in
            return self.homeUseCase.loadSubtaskSheets()
                .trackArray(loadSubtaskSheetsState.subtaskSheetsArray)
                .trackError(loadSubtaskSheetsState.errorLoadingSubtaskSheets)
                .trackActivity(loadSubtaskSheetsState.isLoadingSubtaskSheets)
                .mapToVoid()
                .asDriverOnErrorJustComplete()
        }
        let selectSubtaskSheet = input.selectSubtaskSheetTrigger
            .withLatestFrom(loadSubtaskSheetsState.subtaskSheetsArray) { [unowned self] (index: Int, subtaskSheets: [Sheet]) in
//                self.navigator.toTaskList(with: subtaskSheets[index])
        }
        return SheetSettingViewModel.Output(
            loadPositionSheets: loadPositionSheets,
            positionSheets: loadPositionSheetsState.positionSheetsArray.asDriver(),
            selectPositionSheet: selectPositionSheet,
            isLoadingPositionSheets: loadPositionSheetsState.isLoadingPositionSheets.asDriver(),
            errorLoadingPositionSheets: loadPositionSheetsState.errorLoadingPositionSheets.asDriver(),

            loadSubtaskSheets: loadSubtaskSheets,
            subtaskSheets: loadSubtaskSheetsState.subtaskSheetsArray.asDriver(),
            selectSubtaskSheet: selectSubtaskSheet,
            isLoadingSubtaskSheets: loadSubtaskSheetsState.isLoadingSubtaskSheets.asDriver(),
            errorLoadingSubtaskSheets: loadSubtaskSheetsState.errorLoadingPositionSheets.asDriver()
        )
    }
}
