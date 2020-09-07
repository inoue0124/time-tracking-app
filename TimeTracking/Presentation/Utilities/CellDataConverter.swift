
import Foundation

public struct CellDataConverter {
    func makeDataCell(cell: DataCell, data: Any, type: String) -> DataCell {
        switch (type) {
        case "text":
            cell.label.text = data as? String ?? ""
            cell.addLabel()
            break
        case "time":
            cell.label.text = getString(from: data as? Date ?? Date())
            cell.addLabel()
            break
        case "note":
            cell.addNote()
            break
        case "check":
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
