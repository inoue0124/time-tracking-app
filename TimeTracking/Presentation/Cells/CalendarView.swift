import UIKit
import Firebase
import FirebaseStorageUI
import FSCalendar

class CalendarView: UIView {

    @IBOutlet weak var calendar: FSCalendar!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initiateUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initiateUI()
    }

    private func initiateUI() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: R.nib.calendarView.name, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                      options:NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                      metrics:nil,
                                                      views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                      options:NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                      metrics:nil,
                                                      views: bindings))
        calendar.appearance.headerTitleColor = UIColor(named: R.color.theme.name)
        calendar.appearance.headerDateFormat = "YYYY年MM月"
        calendar.calendarWeekdayView.weekdayLabels[0].text = "月"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "火"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "水"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "木"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "金"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "土"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "日"
        calendar.calendarWeekdayView.weekdayLabels[0].textColor = UIColor.black
        calendar.calendarWeekdayView.weekdayLabels[1].textColor = UIColor.black
        calendar.calendarWeekdayView.weekdayLabels[2].textColor = UIColor.black
        calendar.calendarWeekdayView.weekdayLabels[3].textColor = UIColor.black
        calendar.calendarWeekdayView.weekdayLabels[4].textColor = UIColor.black
        calendar.calendarWeekdayView.weekdayLabels[5].textColor = UIColor(named: R.color.theme.name)
        calendar.calendarWeekdayView.weekdayLabels[6].textColor = UIColor.red
    }
}

