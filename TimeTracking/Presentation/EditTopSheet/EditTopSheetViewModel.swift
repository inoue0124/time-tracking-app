import Foundation
import RxSwift
import RxCocoa

class EditTopSheetViewModel: ViewModelType {

    struct Input {
        let loadTrigger: Driver<Void>
        let saveTrigger: Driver<Void>
        let topSheet: Driver<TopSheet>
    }

    struct Output {
        let load: Driver<Void>
        let positionSheets: Driver<[PositionSheet]>
        let save: Driver<Void>
        let isLoading: Driver<Bool>
        let error: Driver<Error>
    }

    struct State {
        let contentArray = ArrayTracker<PositionSheet>()
        let isLoading = ActivityIndicator()
        let error = ErrorTracker()
    }

    private let editTopSheetUseCase: EditTopSheetUseCase
    private let navigator: EditTopSheetNavigator
    private let sheetId: String?
    private let sheetName: String?
    let disposeBag = DisposeBag()

    init(with editTopSheetUseCase: EditTopSheetUseCase, and navigator: EditTopSheetNavigator,
         and sheetId: String? = nil, and sheetName: String? = nil) {
        self.editTopSheetUseCase = editTopSheetUseCase
        self.navigator = navigator
        self.sheetId = sheetId
        self.sheetName = sheetName
    }

    func transform(input: EditTopSheetViewModel.Input) -> EditTopSheetViewModel.Output {
        let state = State()
        let load = input.loadTrigger
            .flatMap { [unowned self] _ -> Driver<Void> in
                if (self.sheetId != nil) {
                    self.editTopSheetUseCase.getTopSheetById(with: self.sheetId!).subscribe(onNext: { topSheet in
                        return self.editTopSheetUseCase.loadPositionSheetsByIds(with: topSheet.positionSheetIds)
                            .trackArray(state.contentArray)
                            .trackError(state.error)
                            .trackActivity(state.isLoading)
                    }).disposed(by: self.disposeBag)
                    return Observable.create { observer in return Disposables.create()}.asDriverOnErrorJustComplete()
                } else {
                    return self.editTopSheetUseCase.loadPositionSheets()
                        .trackArray(state.contentArray)
                        .trackError(state.error)
                        .trackActivity(state.isLoading)
                        .mapToVoid()
                        .asDriverOnErrorJustComplete()
                }
        }
        let save = input.saveTrigger
            .withLatestFrom(input.topSheet)
            .flatMapLatest { [unowned self] (topSheet: TopSheet) -> Driver<Void> in
                if (self.sheetId != nil) {
                    return self.editTopSheetUseCase.updateSheet(with: topSheet)
                        .mapToVoid()
                        .asDriver(onErrorJustReturn: ())
                } else {
                    return self.editTopSheetUseCase.saveSheet(with: topSheet)
                        .mapToVoid()
                        .do(onNext: { [unowned self] in
                            self.navigator.toSheetSetting()
                        })
                        .asDriverOnErrorJustComplete()
                }
        }
        return EditTopSheetViewModel.Output(load: load,
                                            positionSheets: state.contentArray.asDriver(),
                                            save: save,
                                            isLoading: state.isLoading.asDriver(),
                                            error: state.error.asDriver())
    }
}
