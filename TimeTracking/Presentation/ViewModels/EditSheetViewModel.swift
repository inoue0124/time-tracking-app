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
        let uploadImageTrigger: Driver<UIImage>
        let imageName: Driver<String>
        let sheetName: String?
    }

    struct Output {
        let save: Driver<Void>
        let uploadImage: Driver<Void>
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
                return self.editSheetUseCase.saveSheet(with: input.sheetName ?? "名称未設定",
                                                  and: columnTitles,
                                                  and: columnTypes,
                                                  and: columnWidths)
                    .flatMap { [unowned self] (sheetId: String) in
                        self.editSheetUseCase.saveTasks(with: data, and: sheetId)
                            .do(onNext: { [unowned self] in
                                self.navigator.toAddSheet()
                            })
                    }
                    .trackError(state.error)
                    .asDriver(onErrorJustReturn: ())
        }
        let uploadImage = input.uploadImageTrigger
            .withLatestFrom(Driver.combineLatest(input.uploadImageTrigger, input.imageName))
            .flatMapLatest { [unowned self] (image: UIImage, imageName: String) -> Driver<Void> in
                return self.editSheetUseCase.uploadImage(image, name: imageName).asDriver(onErrorJustReturn: ())
        }
        return EditSheetViewModel.Output(save: save,
                                         uploadImage: uploadImage,
                                         error: state.error.asDriver())
    }
}
