import Foundation

protocol HeaderSettingDelegate {
    func createColumn(_ column: Column) -> Void
    func updateColumn(_ column: Column, index: Int) -> Void
    func deleteColumn(index: Int) -> Void
}
