import Foundation

struct Sheet {
    var id: String
    var name: String
    var type: String
    var isPublic: Bool
    var columnTitles: [String]
    var columnTypes: [String]
    var columnWidths: [Int]
    var createUser: String
    var createdAt: Date
    var updateUser: String
    var updatedAt: Date
}
