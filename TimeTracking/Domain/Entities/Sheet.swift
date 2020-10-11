import Foundation

class Sheet {
    var id: String
    var name: String
    var isPublic: Bool
    var createUser: String
    var createdAt: Date
    var updateUser: String
    var updatedAt: Date

    init() {
        self.id = ""
        self.name = ""
        self.isPublic = false
        self.createUser = ""
        self.createdAt = Date()
        self.updateUser = ""
        self.updatedAt = Date()
    }

    init(id: String,
         name: String,
         isPublic: Bool,
         createUser: String,
         createdAt: Date,
         updateUser: String,
         updatedAt: Date)
    {
        self.id = id
        self.name = name
        self.isPublic = isPublic
        self.createUser = createUser
        self.createdAt = createdAt
        self.updateUser = updateUser
        self.updatedAt = updatedAt
    }
}
