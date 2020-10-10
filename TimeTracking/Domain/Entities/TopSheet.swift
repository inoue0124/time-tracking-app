import Foundation

class TopSheet: Sheet {

    var positionSheetIds: [String]

    override init() {
        self.positionSheetIds = []
        super.init()
    }

    init(id: String,
         name: String,
         isPublic: Bool,
         positionSheetIds: [String],
         createUser: String,
         createdAt: Date,
         updateUser: String,
         updatedAt: Date)
     {
        self.positionSheetIds = positionSheetIds
        super.init(id: id, name: name, isPublic: isPublic, createUser: createUser, createdAt: createdAt,
                    updateUser: updateUser, updatedAt: updatedAt)
     }
}
