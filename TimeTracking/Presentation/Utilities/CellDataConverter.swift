
import Foundation

public struct CellDataConverter {

    let appConst = AppConst()

    func makeDataCell(cell: DataCell, data: Any, type: String) -> DataCell {
        switch (type) {
        case appConst.CELL_TYPE_TEXT:
            cell.label.text = data as? String ?? ""
            cell.addLabel()
            break
        case appConst.CELL_TYPE_TIME:
            cell.label.text = getString(from: data as? Date ?? Date())
            cell.addLabel()
            break
        case appConst.CELL_TYPE_NOTE:
            cell.addNote()
            break
        case appConst.CELL_TYPE_CHECK:
            cell.addCheck(isChecked: data as? Bool ?? false)
            break
        default:
            break
        }
        return cell
    }

    private func getString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
