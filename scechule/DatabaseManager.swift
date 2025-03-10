import Firebase
import FirebaseAuth
import FirebaseFirestore

struct User {
    let id: String
    let name: String
    let email: String
    let role: String
}

struct DanceClass {
    let id: String
    let name: String
    let instructor: String
    let time: String
    let maxCapacity: Int
    let description: String
}

struct Enrollment {
    let id: String
    let userId: String
    let classId: String
}

class DatabaseManager {
    static let shared = DatabaseManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Регистрация пользователя
    func registerUser(name: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("❌ Ошибка регистрации: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let user = authResult?.user else {
                completion(false)
                return
            }
            
            let userRef = self.db.collection("users").document(user.uid)
            userRef.setData([
                "id": user.uid,
                "name": name,
                "email": email,
                "role": "user"
            ]) { error in
                if let error = error {
                    print("❌ Ошибка сохранения пользователя: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    // Вход пользователя
    func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("❌ Ошибка входа: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let user = authResult?.user else {
                completion(false)
                return
            }
            
            self.getUserById(userId: user.uid) { user in
                if let user = user {
                    UserDefaults.standard.set(user.role, forKey: "userRole")
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    func updateClass(id: String, name: String, instructor: String, time: String, maxCapacity: Int, description: String, completion: @escaping (Bool) -> Void) {
        let classRef = db.collection("classes").document(id)
        
        classRef.updateData([
            "name": name,
            "instructor": instructor,
            "time": time,
            "maxCapacity": maxCapacity,
            "description": description
        ]) { error in
            if let error = error {
                print("❌ Ошибка обновления занятия: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    func getUserById(userId: String, completion: @escaping (User?) -> Void) {
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("❌ Ошибка получения пользователя: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = document?.data() else {
                completion(nil)
                return
            }
            
            let user = User(
                id: userId,
                name: data["name"] as? String ?? "",
                email: data["email"] as? String ?? "",
                role: data["role"] as? String ?? "user"
            )
            completion(user)
        }
    }
    func deleteClass(id: String, completion: @escaping (Bool) -> Void) {
        db.collection("classes").document(id).delete { error in
            if let error = error {
                print("❌ Ошибка удаления занятия: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    func addClass(_ newClass: DanceClass) async -> Bool {
        do {
            try await db.collection("classes").document(newClass.id).setData([
                "name": newClass.name,
                "instructor": newClass.instructor,
                "time": newClass.time,
                "maxCapacity": newClass.maxCapacity,
                "description": newClass.description
            ])
            return true
        } catch {
            print("❌ Ошибка добавления занятия: \(error.localizedDescription)")
            return false
        }
    }

    func getAllClasses(completion: @escaping ([DanceClass]) -> Void) {
        db.collection("classes").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Ошибка получения занятий: \(error.localizedDescription)")
                completion([])
                return
            }
            
            let classes = snapshot?.documents.compactMap { document -> DanceClass? in
                let data = document.data()
                return DanceClass(
                    id: document.documentID,
                    name: data["name"] as? String ?? "",
                    instructor: data["instructor"] as? String ?? "",
                    time: data["time"] as? String ?? "",
                    maxCapacity: data["maxCapacity"] as? Int ?? 0,
                    description: data["description"] as? String ?? ""
                )
            } ?? []
            
            completion(classes)
        }
    }
    func enrollUser(userId: String, classId: String, completion: @escaping (Bool) -> Void) {
        let enrollmentRef = db.collection("enrollments").document("\(userId)_\(classId)")
        
        let data: [String: Any] = [
            "userId": userId,
            "classId": classId,
            "timestamp": Timestamp(date: Date())
        ]
        
        enrollmentRef.setData(data) { error in
            if let error = error {
                print("Ошибка при записи в Firestore: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    func getUserBookings(userId: String, completion: @escaping ([(id: String, className: String, instructor: String, time: String)]) -> Void) {
        db.collection("enrollments").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("❌ Ошибка получения записей: \(error.localizedDescription)")
                completion([])
                return
            }

            let enrollments = snapshot?.documents.compactMap { document -> Enrollment? in
                let data = document.data()
                return Enrollment(
                    id: document.documentID,
                    userId: data["userId"] as? String ?? "",
                    classId: data["classId"] as? String ?? ""
                )
            } ?? []

            let classIds = enrollments.map { $0.classId }
            
        
            guard !classIds.isEmpty else {
                completion([])
                return
            }

            self.db.collection("classes").whereField(FieldPath.documentID(), in: classIds).getDocuments { classSnapshot, error in
                if let error = error {
                    print("❌ Ошибка получения данных о занятиях: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let classMap = classSnapshot?.documents.reduce(into: [String: DanceClass]()) { result, document in
                    let data = document.data()
                    let danceClass = DanceClass(
                        id: document.documentID,
                        name: data["name"] as? String ?? "",
                        instructor: data["instructor"] as? String ?? "",
                        time: data["time"] as? String ?? "",
                        maxCapacity: data["maxCapacity"] as? Int ?? 0,
                        description: data["description"] as? String ?? ""
                    )
                    result[danceClass.id] = danceClass
                } ?? [:]

                let bookings = enrollments.compactMap { enrollment -> (String, String, String, String)? in
                    guard let danceClass = classMap[enrollment.classId] else { return nil }
                    return (enrollment.id, danceClass.name, danceClass.instructor, danceClass.time)
                }

                completion(bookings)
            }
        }
    }
}
