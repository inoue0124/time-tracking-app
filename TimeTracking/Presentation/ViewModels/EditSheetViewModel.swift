import Foundation
import RxSwift
import RxCocoa

class EditSheetViewModel: ViewModelType {

    struct Input {
        let saveTrigger: Driver<Void>
        let columnTitles: Driver<[String]>
        let columnTypes: Driver<[String]>
        let columnWidths: Driver<[Int]>
        let data: Driver<[[Any]]>
        let sheetName: String?
    }

    struct Output {
        let save: Driver<Void>
        let error: Driver<Error>
    }

    struct State {
        let error = ErrorTracker()
    }

    private let editSheetUseCase: EditSheetUseCase
    private let navigator: EditSheetNavigator

    init(with editSheetUseCase: EditSheetUseCase, and navigator: EditSheetNavigator) {
        self.editSheetUseCase = editSheetUseCase
        self.navigator = navigator
    }

    func transform(input: EditSheetViewModel.Input) -> EditSheetViewModel.Output {
        let state = State()
        let requiredInputs = Driver.combineLatest(input.columnTitles, input.columnTypes, input.columnWidths, input.data)
        let save = input.saveTrigger
            .withLatestFrom(requiredInputs)
            .flatMapLatest { [unowned self] (columnTitles: [String], columnTypes: [String], columnWidths: [Int], data: [[Any]]) -> Driver<Void> in
                return self.editSheetUseCase.save(with: input.sheetName ?? "名称未設定",
                                                  and: columnTitles,
                                                  and: columnTypes,
                                                  and: columnWidths,
                                                  and: data)
                    .do(onNext: { [unowned self] _ in
//                        self.navigator.toList()
                    })
                    .trackError(state.error)
                    .asDriver(onErrorJustReturn: ())
        }
        return EditSheetViewModel.Output(save: save,
                                         error: state.error.asDriver())
    }
}
