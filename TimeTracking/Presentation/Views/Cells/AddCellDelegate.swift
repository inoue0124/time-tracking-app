import Foundation

protocol AddCellDelegate {
    func addColumn() -> Void
    func addRow() -> Void
    func setHeaderName(_ column: Column) -> Void
}
