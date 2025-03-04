import Foundation

struct AppUser {
    let id: String
    let name: String
    let email: String
    let password: String
    let role: String

    init(id: String = UUID().uuidString, name: String, email: String, password: String, role: String = "user") {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.role = role
    }
}

