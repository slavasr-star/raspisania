import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - AuthManager
class AuthManager {
    static let shared = AuthManager()
    private var cachedIsAdmin: Bool?
    private var authListenerHandle: AuthStateDidChangeListenerHandle?


    private init() {
        authListenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
            print("Auth state changed: \(user?.email ?? "No user")")
        }
    }

    func isAdmin(completion: @escaping (Bool) -> Void) {
        if let cached = cachedIsAdmin {
            completion(cached)
            return
        }

        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)

        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching admin status: \(error.localizedDescription)")
                completion(false)
                return
            }

            if let document = document, document.exists, let isAdmin = document.data()?["isAdmin"] as? Bool {
                self.cachedIsAdmin = isAdmin
                completion(isAdmin)
            } else {
                completion(false)
            }
        }
    }

    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                // После успешного входа обновляем статус администратора
                self.cachedIsAdmin = nil
                self.isAdmin { _ in }
                NotificationCenter.default.post(name: .AuthStateDidChange, object: nil)
                completion(true, nil)
            }
        }
    }

    func logout(completion: @escaping (Bool, String?) -> Void) {
        do {
            try Auth.auth().signOut()
            cachedIsAdmin = nil
            NotificationCenter.default.post(name: .AuthStateDidChange, object: nil)
            completion(true, nil)
        } catch {
            completion(false, error.localizedDescription)
        }
    }

    private func handleAuthState(user: FirebaseAuth.User?) {
        if user == nil {
            print("User logged out")
            cachedIsAdmin = nil
            return
        }

        guard let user = user else { return }
        let email = user.email ?? "No email"
        let uid = user.uid

        print("User logged in: \(email)")

        let userMap: [String: Any] = [
            "email": email,
            "uid": uid,
            "name": "",
            "bio": "",
            "isAdmin": false 
        ]

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { document, error in
            if let document = document, document.exists {
                print("User already exists in Firestore")
            } else {
                userRef.setData(userMap, merge: true) { error in
                    if let error = error {
                        print("Error saving user: \(error.localizedDescription)")
                    } else {
                        print("User saved successfully")
                    }
                }
            }
        }
    }
}

// MARK: - Notification Name Extension
extension Notification.Name {
    static let AuthStateDidChange = Notification.Name("AuthStateDidChange")
}


