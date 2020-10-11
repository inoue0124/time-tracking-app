import RxSwift

class UDDateRepository: DateRepository {

    let userDefaults = UserDefaults.standard

    func set(_ date: Date) -> Observable<Void> {
        return Observable.create { [unowned self]observer in
            self.userDefaults.set(date, forKey: "date")
            return Disposables.create()
        }
    }
    
    func read() -> Observable<Date> {
        return Observable.create { observer in
            let value = self.userDefaults.object(forKey: "date")
            guard let date = value as? Date else {
                return Disposables.create()
            }
            observer.onNext(date)
            return Disposables.create()
        }
    }
}
