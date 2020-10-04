import Foundation
import RxSwift
import RxCocoa

class SheetSettingViewModel: ViewModelType {

    struct Input {
        let loadTrigger: Driver<Void>
        let selectTopSheetTrigger: Driver<Int>
        let deleteTopSheetTrigger: Driver<Int>

        let selectPositionSheetTrigger: Driver<Int>
        let deletePositionSheetTrigger: Driver<Int>

        let selectSubtaskSheetTrigger: Driver<Int>
        let deleteSubtaskSheetTrigger: Driver<Int>
    }

    struct Output {
        let loadTopSheets: Driver<Void>
        let topSheets: Driver<[Sheet]>
        let selectTopSheet: Driver<Void>
        let deleteTopSheet: Driver<Void>
        let isLoadingTopSheets: Driver<Bool>
        let errorLoadingTopSheets: Driver<Error>

        let loadPositionSheets: Driver<Void>
        let positionSheets: Driver<[Sheet]>
        let selectPositionSheet: Driver<Void>
        let deletePositionSheet: Driver<Void>
        let isLoadingPositionSheets: Driver<Bool>
        let errorLoadingPositionSheets: Driver<Error>

        let loadSubtaskSheets: Driver<Void>
        let subtaskSheets: Driver<[Sheet]>
        let selectSubtaskSheet: Driver<Void>
        let deleteSubtaskSheet: Driver<Void>
        let isLoadingSubtaskSheets: Driver<Bool>
        let errorLoadingSubtaskSheets: Driver<Error>
    }

    struct State {
        let topSheetsArray = ArrayTracker<Sheet>()
        let isLoadingTopSheets = ActivityIndicator()
        let errorLoadingTopSheets = ErrorTracker()

        let positionSheetsArray = ArrayTracker<Sheet>()
        let isLoadingPositionSheets = ActivityIndicator()
        let errorLoadingPositionSheets = ErrorTracker()

        let subtaskSheetsArray = ArrayTracker<Sheet>()
        let isLoadingSubtaskSheets = ActivityIndicator()
        let errorLoadingSubtaskSheets = ErrorTracker()
    }

    private let sheetSettingUseCase: SheetSettingUseCase
    private let navigator: SheetSettingNavigator

    init(with sheetSettingUseCase: SheetSettingUseCase, and navigator: SheetSettingNavigator) {
        self.sheetSettingUseCase = sheetSettingUseCase
        self.navigator = navigator
    }

    func transform(input: SheetSettingViewModel.Input) -> SheetSettingViewModel.Output {
        let state = State()

        let loadTopSheets = input.loadTrigger
            .flatMap { [unowned self] _ in
            return self.sheetSettingUseCase.loadTopSheets()
                .trackArray(state.positionSheetsArray)
                .trackError(state.errorLoadingTopSheets)
                .trackActivity(state.isLoadingTopSheets)
                .mapToVoid()
                .asDriverOnErrorJustComplete()
            }
        let selectTopSheet = input.selectTopSheetTrigger
            .withLatestFrom(state.positionSheetsArray) { [unowned self] (index: Int, positionSheets: [Sheet]) in
                self.navigator.toEditSheet(with: positionSheets[index])
            }
        let deleteTopSheet = input.deleteTopSheetTrigger
            .flatMapLatest { [unowned self] index -> Driver<Void> in
                return self.sheetSettingUseCase.deleteTopSheets(with: state.positionSheetsArray.array[index].id)
                    .asDriver(onErrorJustReturn: ())
            }

        let loadPositionSheets = input.loadTrigger
            .flatMap { [unowned self] _ in
            return self.sheetSettingUseCase.loadPositionSheets()
                .trackArray(state.positionSheetsArray)
                .trackError(state.errorLoadingPositionSheets)
                .trackActivity(state.isLoadingPositionSheets)
                .mapToVoid()
                .asDriverOnErrorJustComplete()
            }
        let selectPositionSheet = input.selectPositionSheetTrigger
            .withLatestFrom(state.positionSheetsArray) { [unowned self] (index: Int, positionSheets: [Sheet]) in
                self.navigator.toEditSheet(with: positionSheets[index])
            }
        let deletePositionSheet = input.deletePositionSheetTrigger
            .flatMapLatest { [unowned self] index -> Driver<Void> in
                return self.sheetSettingUseCase.deletePositionSheets(with: state.positionSheetsArray.array[index].id)
                    .asDriver(onErrorJustReturn: ())
            }

        let loadSubtaskSheets = input.loadTrigger
            .flatMap { [unowned self] _ in
            return self.sheetSettingUseCase.loadSubtaskSheets()
                .trackArray(state.subtaskSheetsArray)
                .trackError(state.errorLoadingSubtaskSheets)
                .trackActivity(state.isLoadingSubtaskSheets)
                .mapToVoid()
                .asDriverOnErrorJustComplete()
            }
        let selectSubtaskSheet = input.selectSubtaskSheetTrigger
            .withLatestFrom(state.subtaskSheetsArray) { [unowned self] (index: Int, subtaskSheets: [Sheet]) in
                self.navigator.toEditSheet(with: subtaskSheets[index])
            }
        let deleteSubtaskSheet = input.deleteSubtaskSheetTrigger
            .flatMapLatest { [unowned self] index -> Driver<Void> in
                return self.sheetSettingUseCase.deleteSubtaskSheets(with: state.subtaskSheetsArray.array[index].id)
                    .asDriver(onErrorJustReturn: ())
            }

        return SheetSettingViewModel.Output(
            loadTopSheets: loadTopSheets,
            topSheets: state.topSheetsArray.asDriver(),
            selectTopSheet: selectTopSheet,
            deleteTopSheet: deleteTopSheet,
            isLoadingTopSheets: state.isLoadingTopSheets.asDriver(),
            errorLoadingTopSheets: state.errorLoadingTopSheets.asDriver(),

            loadPositionSheets: loadPositionSheets,
            positionSheets: state.positionSheetsArray.asDriver(),
            selectPositionSheet: selectPositionSheet,
            deletePositionSheet: deletePositionSheet,
            isLoadingPositionSheets: state.isLoadingPositionSheets.asDriver(),
            errorLoadingPositionSheets: state.errorLoadingPositionSheets.asDriver(),

            loadSubtaskSheets: loadSubtaskSheets,
            subtaskSheets: state.subtaskSheetsArray.asDriver(),
            selectSubtaskSheet: selectSubtaskSheet,
            deleteSubtaskSheet: deleteSubtaskSheet,
            isLoadingSubtaskSheets: state.isLoadingSubtaskSheets.asDriver(),
            errorLoadingSubtaskSheets: state.errorLoadingPositionSheets.asDriver()
        )
    }
}
