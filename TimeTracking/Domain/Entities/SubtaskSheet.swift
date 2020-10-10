import Foundation

class SubtaskSheet: Sheet {

    var columnTitles: [String]
    var columnTypes: [String]
    var columnWidths: [Int]

    override init() {
        self.columnTitles = []
        self.columnTypes = []
        self.columnWidths = []
        super.init()
    }

    init(id: String,
         name: String,
         isPublic: Bool,
         columnTitles: [String],
         columnTypes: [String],
         columnWidths: [Int],
         createUser: String,
         createdAt: Date,
         updateUser: String,
         updatedAt: Date)
    {
        self.columnTitles = columnTitles
        self.columnTypes = columnTypes
        self.columnWidths = columnWidths
        super.init(id: id, name: name, isPublic: isPublic, createUser: createUser, createdAt: createdAt,
                   updateUser: updateUser, updatedAt: updatedAt)
    }
   
}
