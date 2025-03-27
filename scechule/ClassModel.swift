import Foundation
import FirebaseFirestore // Добавь этот импорт, если его нет

struct Class {
    let id: String
    let name: String
    let instructor: String
    let time: Timestamp // Было String, теперь Timestamp
    let maxCapacity: Int
    let description: String

    init(id: String = UUID().uuidString, name: String, instructor: String,
         time: Timestamp, maxCapacity: Int, description: String) { // Изменен тип параметра time
        self.id = id
        self.name = name
        self.instructor = instructor
        self.time = time
        self.maxCapacity = maxCapacity
        self.description = description
    }
}
