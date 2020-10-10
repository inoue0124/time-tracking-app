import Foundation
import RxSwift

class AddSheetUseCase {

    private let templateRepository: TemplateRepository

    init(with templateRepository: TemplateRepository) {
        self.templateRepository = templateRepository
    }

    func loadTemplates(with type: String) -> Observable<[Sheet]> {
        return templateRepository.read(with: type)
    }

}
