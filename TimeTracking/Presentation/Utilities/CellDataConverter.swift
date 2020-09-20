import Foundation
import SpreadsheetView

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
            do {
                let note = try JSONDecoder().decode(Note.self, from: (data as! String).data(using: .utf8)!)
                cell.note = note
            } catch {
                cell.noteButton.tintColor = .lightGray
                cell.noteButton.isEnabled = false
                print("error")
            }
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

    func makeEditableDataCell(cell: DataCell, indexPath: IndexPath, data: Any, type: String) -> DataCell {
        cell.indexPath = indexPath
        cell.gridlines.right = .default
        cell.gridlines.bottom = .default
        cell.gridlines.left = .default
        switch (type) {
        case appConst.CELL_TYPE_TIME:
            cell.dateField.text = getString(from: data as? Date ?? Date())
            cell.addDateField()
            return cell
        case appConst.CELL_TYPE_TEXT:
            cell.textField.text = data as? String ?? ""
            cell.addTextField()
            break
        case appConst.CELL_TYPE_NOTE:
            do {
                let note = try JSONDecoder().decode(Note.self, from: (data as! String).data(using: .utf8)!)
                cell.note = note
            } catch {
                cell.noteButton.tintColor = .lightGray
                print("error")
            }
            cell.addNote()
            break
        case appConst.CELL_TYPE_CHECK:
            cell.addCheck(isChecked: false)
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
