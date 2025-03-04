import Foundation

struct Class {
    let id: String
    let name: String
    let instructor: String
    let time: String
    let maxCapacity: Int
    let description: String

    init(id: String = UUID().uuidString, name: String, instructor: String, time: String, maxCapacity: Int, description: String) {
        self.id = id
        self.name = name
        self.instructor = instructor
        self.time = time
        self.maxCapacity = maxCapacity
        self.description = description
    }
}

