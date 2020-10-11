import Foundation
import RxSwift
import RxCocoa

class HomeViewModel: ViewModelType {

    struct Input {
        let loadTrigger: Driver<Void>
        let dateTrigger: Driver<Date>
        let selectTopSheetTrigger: Driver<Int>
        let selectSubtaskSheetTrigger: Driver<Int>
    }

    struct Output {
        let changeDate: Driver<Date>

        let loadTopSheets: Driver<Void>
        let topSheets: Driver<[PositionSheet]>
        let selectTopSheet: Driver<Void>
        let isLoadingTopSheets: Driver<Bool>
        let errorLoadingTopSheets: Driver<Error>

        let loadSubtaskSheets: Driver<Void>
        let subtaskSheets: Driver<[SubtaskSheet]>
        let selectSubtaskSheet: Driver<Void>
        let isLoadingSubtaskSheets: Driver<Bool>
        let errorLoadingSubtaskSheets: Driver<Error>
    }

    struct State {
        let positionSheetsArray = ArrayTracker<PositionSheet>()
        let isLoadingTopSheets = ActivityIndicator()
        let errorLoadingTopSheets = ErrorTracker()

        let subtaskSheetsArray = ArrayTracker<SubtaskSheet>()
        let isLoadingSubtaskSheets = ActivityIndicator()
        let errorLoadingSubtaskSheets = ErrorTracker()
    }

    private let homeUseCase: HomeUseCase
    public let navigator: HomeNavigator
    let appConst = AppConst()
    let disposeBag = DisposeBag()

    init(with homeUseCase: HomeUseCase, and navigator: HomeNavigator) {
        self.homeUseCase = homeUseCase
        self.navigator = navigator
    }

    func transform(input: HomeViewModel.Input) -> HomeViewModel.Output {
        let loadTopSheetsState = State()
        let changeDate = input.dateTrigger.flatMapLatest { [unowned self] (date: Date) -> Driver<Date> in
            self.homeUseCase.changeDate(date: date).asDriverOnErrorJustComplete().drive().disposed(by: self.disposeBag)
            return self.homeUseCase.readDate().asDriverOnErrorJustComplete()
        }
        let loadTopSheets = input.loadTrigger
            .flatMap { [unowned self] _ in
            return self.homeUseCase.loadTopSheets(with: "eQ1PLbHjCxGXdlvQxsKw")
                .trackArray(loadTopSheetsState.positionSheetsArray)
                .trackError(loadTopSheetsState.errorLoadingTopSheets)
                .trackActivity(loadTopSheetsState.isLoadingTopSheets)
                .mapToVoid()
                .asDriverOnErrorJustComplete()
        }
        let selectTopSheet = input.selectTopSheetTrigger
            .withLatestFrom(loadTopSheetsState.positionSheetsArray) { [unowned self] (index: Int, positionSheets: [PositionSheet]) in
                if (index==0) {
                    self.navigator.toSheetDetail(with: self.appConst.SHEET_TYPE_TOP, and: positionSheets[index].id)
                } else {
                    self.navigator.toSheetDetail(with: self.appConst.SHEET_TYPE_POSITION, and: positionSheets[index].id)
                }
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
            .withLatestFrom(loadSubtaskSheetsState.subtaskSheetsArray) { [unowned self] (index: Int, subtaskSheets: [SubtaskSheet]) in
                self.navigator.toSheetDetail(with: self.appConst.SHEET_TYPE_SUBTASK, and: subtaskSheets[index].id)
        }

        return HomeViewModel.Output(
            changeDate: changeDate,

            loadTopSheets: loadTopSheets,
            topSheets: loadTopSheetsState.positionSheetsArray.asDriver(),
            selectTopSheet: selectTopSheet,
            isLoadingTopSheets: loadTopSheetsState.isLoadingTopSheets.asDriver(),
            errorLoadingTopSheets: loadTopSheetsState.errorLoadingTopSheets.asDriver(),

            loadSubtaskSheets: loadSubtaskSheets,
            subtaskSheets: loadSubtaskSheetsState.subtaskSheetsArray.asDriver(),
            selectSubtaskSheet: selectSubtaskSheet,
            isLoadingSubtaskSheets: loadSubtaskSheetsState.isLoadingSubtaskSheets.asDriver(),
            errorLoadingSubtaskSheets: loadSubtaskSheetsState.errorLoadingSubtaskSheets.asDriver()
        )
    }

}
