import UIKit
import RxSwift
import RxCocoa
import DropDown
import FSCalendar
import CalculateCalendarLogic

class HomeViewController: UIViewController {

    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var topSheetTable: UITableView!
    @IBOutlet weak var subtaskSheetTable: UITableView!

    var homeViewModel: HomeViewModel!

    let disposeBag = DisposeBag()
    let dropDown = DropDown()
    var calendarView = CalendarView()
    let calendarUtil = CalendarUtil()
    var date = Date()
    var dateRelay = BehaviorRelay<Date>(value: Date())

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        initializeViewModel()
        bindViewModel()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.homeViewController.toTopSheetDetail.identifier {
            if let vc = segue.destination as? TopSheetDetailViewController,
                let sheetId = sender as? String {
                    vc.initializeViewModel(with: sheetId)
            }
        }
        if segue.identifier == R.segue.homeViewController.toPositionSheetDetail.identifier {
            if let vc = segue.destination as? PositionSheetDetailViewController,
                let sheetId = sender as? String {
                    vc.initializeViewModel(with: sheetId)
            }
        }
        if segue.identifier == R.segue.homeViewController.toSubtaskSheetDetail.identifier {
            if let vc = segue.destination as? SubtaskSheetDetailViewController,
                let sheetId = sender as? String {
                    vc.initializeViewModel(with: sheetId)
            }
        }
    }

    func initializeUI() {
        dateButton.layer.borderColor = UIColor(named: R.color.theme.name)?.cgColor
        dateButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        let f = DateFormatter()
        f.timeStyle = .none
        f.dateStyle = .long
        f.locale = Locale(identifier: "ja_JP")
        dateButton.setTitle(f.string(from: Date()), for: .normal)
        dateButton.rx.tap.subscribe { [unowned self] _ in
            let size: CGSize = UIScreen.main.bounds.size
            self.calendarView = CalendarView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            self.calendarView.alpha = 0
            self.navigationController?.view.addSubview(self.calendarView)
            UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                self.calendarView.alpha = 1
                self.calendarView.calendar.delegate = self
                self.calendarView.calendar.dataSource = self
            }, completion: nil)
        }.disposed(by: disposeBag)

        dropDown.anchorView = menuBarButton
        dropDown.dataSource = ["設定", "ホーム"]
        dropDown.bottomOffset = CGPoint(x: 0, y: 40)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if (item == "設定") {
                self.homeViewModel.navigator.toSetting()
            }
        }

        menuBarButton.rx.tap.subscribe { [unowned self] _ in
            self.dropDown.show()
        }.disposed(by: disposeBag)
    }

    func initializeViewModel() {
        homeViewModel = HomeViewModel.init(with: HomeUseCase(with: FBTopSheetRepository(),
                                                             and: FBPositionSheetRepository(),
                                                             and: FBSubtaskSheetRepository(),
                                                             and: UDDateRepository()),
                                           and: HomeNavigator(with: self))
    }

    func bindViewModel() {
        let input = HomeViewModel.Input(loadTrigger: Driver.just(()),
                                        dateTrigger: dateRelay.asDriver(),
                                        selectTopSheetTrigger: topSheetTable.rx.itemSelected.asDriver().map { $0.row },
                                        selectSubtaskSheetTrigger: subtaskSheetTable.rx.itemSelected.asDriver().map { $0.row })

        let output = homeViewModel.transform(input: input)
        output.changeDate.drive(onNext: { date in
            self.updateDateButton(date)
        }).disposed(by: disposeBag)

        output.loadTopSheets.drive().disposed(by: disposeBag)
        output.topSheets.drive(topSheetTable.rx.items(cellIdentifier: R.reuseIdentifier.topSheetCell.identifier)) {
            (row, element, cell) in
            cell.textLabel?.text = element.name
        }.disposed(by: disposeBag)
        output.selectTopSheet.drive().disposed(by: disposeBag)

        output.loadSubtaskSheets.drive().disposed(by: disposeBag)
        output.subtaskSheets.drive(subtaskSheetTable.rx.items(cellIdentifier: R.reuseIdentifier.subtaskSheetCell.identifier)) {
            (row, element, cell) in
            cell.textLabel?.text = element.name
        }.disposed(by: disposeBag)
        output.selectSubtaskSheet.drive().disposed(by: disposeBag)
    }

    func updateDateButton(_ date: Date) {
        let f = DateFormatter()
        f.timeStyle = .none
        f.dateStyle = .long
        f.locale = Locale(identifier: "ja_JP")
        dateButton.setTitle(f.string(from: date)+"("+calendarUtil.getDayKanji(date)+")", for: .normal)
    }
}

extension HomeViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateRelay.accept(date)
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.calendarView.alpha = 0
        }, completion: { _ in
            self.calendarView.removeFromSuperview()
        })
    }
    // 土日や祝日の日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if (calendarUtil.getDay(Date()) == calendarUtil.getDay(date)){
            return UIColor.white
        }

        if calendarUtil.judgeHoliday(date){
            return UIColor.red
        }

        let weekday = calendarUtil.getWeekIdx(date)
        if weekday == 1 {   //日曜日
            return UIColor.red
        }
        else if weekday == 7 {  //土曜日
            return UIColor(named: R.color.theme.name)
        }

        return nil
    }
}

