import Foundation

struct EnrollmentModel {
    let id: String
    let userId: String
    let classId: String

    init(id: String = UUID().uuidString, userId: String, classId: String) {
        self.id = id
        self.userId = userId
        self.classId = classId
    }
}
