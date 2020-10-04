import Foundation

struct SubtaskSheet {
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

    init() {
        self.id = ""
        self.name = ""
        self.type = ""
        self.isPublic = false
        self.columnTitles = []
        self.columnTypes = []
        self.columnWidths = []
        self.createUser = ""
        self.createdAt = Date()
        self.updateUser = ""
        self.updatedAt = Date()
    }

    init(id: String,
         name: String,
         type: String,
         isPublic: Bool,
         columnTitles: [String],
         columnTypes: [String],
         columnWidths: [Int],
         createUser: String,
         createdAt: Date,
         updateUser: String,
         updatedAt: Date)
    {
        self.id = id
        self.name = name
        self.type = type
        self.isPublic = isPublic
        self.columnTitles = columnTitles
        self.columnTypes = columnTypes
        self.columnWidths = columnWidths
        self.createUser = createUser
        self.createdAt = createdAt
        self.updateUser = updateUser
        self.updatedAt = updatedAt
    }
}
