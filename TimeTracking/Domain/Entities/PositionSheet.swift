import Foundation

class PositionSheet {

    var id: String
    var name: String
    var isPublic: Bool
    var columnTitles: [String]
    var columnTypes: [String]
    var columnWidths: [Int]
    var createUser: String
    var createdAt: Date
    var updateUser: String
    var updatedAt: Date

    init() {
        let appConst = AppConst()
        self.id = ""
        self.name = ""
        self.isPublic = false
        self.columnTitles = ["時間", "タイトル", "Q&A", "チェック"]
        self.columnTypes = [
            appConst.CELL_TYPE_TIME,
            appConst.CELL_TYPE_TEXT,
            appConst.CELL_TYPE_NOTE,
            appConst.CELL_TYPE_CHECK
        ]
        self.columnWidths = [
            appConst.CELL_WIDTH_MEDIUM,
            appConst.CELL_WIDTH_LARGE,
            appConst.CELL_WIDTH_SMALL,
            appConst.CELL_WIDTH_SMALL
        ]
        self.createUser = ""
        self.createdAt = Date()
        self.updateUser = ""
        self.updatedAt = Date()
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
        let appConst = AppConst()
        self.id = id
        self.name = name
        self.isPublic = isPublic
        self.columnTitles = ["時間", "タイトル", "Q&A", "チェック"]
        self.columnTypes = [
            appConst.CELL_TYPE_TIME,
            appConst.CELL_TYPE_TEXT,
            appConst.CELL_TYPE_NOTE,
            appConst.CELL_TYPE_CHECK
        ]
        self.columnWidths = [
            appConst.CELL_WIDTH_MEDIUM,
            appConst.CELL_WIDTH_LARGE,
            appConst.CELL_WIDTH_SMALL,
            appConst.CELL_WIDTH_SMALL
        ]
        self.createUser = createUser
        self.createdAt = createdAt
        self.updateUser = updateUser
        self.updatedAt = updatedAt
    }
}
