import Foundation

class AuthManager {
    static let shared = AuthManager()

    private init() {}

    func register(email: String, password: String) -> Bool {
        let users = UserDefaults.standard.dictionary(forKey: "users") as? [String: String] ?? [:]
        
        if users[email] == nil {
            var updatedUsers = users
            updatedUsers[email] = password
            UserDefaults.standard.set(updatedUsers, forKey: "users")
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }

    func login(email: String, password: String) -> Bool {
        let users = UserDefaults.standard.dictionary(forKey: "users") as? [String: String] ?? [:]
        
        if let savedPassword = users[email], savedPassword == password {
            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            UserDefaults.standard.set(email == "admin@example.com", forKey: "isAdmin")
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }

    func isAdmin() -> Bool {
        return UserDefaults.standard.bool(forKey: "isAdmin")
    }

    func logout() {
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.set(false, forKey: "isAdmin")
        UserDefaults.standard.synchronize()
    }
}
