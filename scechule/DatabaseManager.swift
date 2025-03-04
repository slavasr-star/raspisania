import Firebase
import FirebaseFirestore

struct User {
    let id: String
    let name: String
    let email: String
    let password: String
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

    // MARK: - Работа с пользователями
    
    func addUser(name: String, email: String, password: String, role: String = "user", completion: @escaping (Bool) -> Void) {
        let userRef = db.collection("users").document()
        userRef.setData([
            "id": userRef.documentID,
            "name": name,
            "email": email,
            "password": password,
            "role": role
        ]) { error in
            if let error = error {
                print("❌ Ошибка добавления пользователя: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Пользователь добавлен")
                completion(true)
            }
        }
    }

    func getUserByEmail(email: String, completion: @escaping (User?) -> Void) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                print("❌ Ошибка получения пользователя: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let document = snapshot?.documents.first else {
                completion(nil)
                return
            }
            let data = document.data()
            let user = User(
                id: data["id"] as? String ?? "",
                name: data["name"] as? String ?? "",
                email: data["email"] as? String ?? "",
                password: data["password"] as? String ?? "",
                role: data["role"] as? String ?? "user"
            )
            completion(user)
        }
    }

    func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        getUserByEmail(email: email) { user in
            if let user = user, user.password == password {
                UserDefaults.standard.set(user.role, forKey: "userRole")
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func isAdmin() -> Bool {
        let role = UserDefaults.standard.string(forKey: "userRole") ?? "user"
        return role == "admin"
    }

    // MARK: - Работа с занятиями

    func addClass(name: String, instructor: String, time: String, maxCapacity: Int, description: String, completion: @escaping (Bool) -> Void) {
        let classRef = db.collection("classes").document()
        classRef.setData([
            "id": classRef.documentID,
            "name": name,
            "instructor": instructor,
            "time": time,
            "maxCapacity": maxCapacity,
            "description": description
        ]) { error in
            if let error = error {
                print("❌ Ошибка добавления занятия: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Занятие добавлено")
                completion(true)
            }
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
                    id: data["id"] as? String ?? "",
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

    func deleteClass(id: String, completion: @escaping (Bool) -> Void) {
        db.collection("classes").document(id).delete { error in
            if let error = error {
                print("❌ Ошибка удаления занятия: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Занятие удалено")
                completion(true)
            }
        }
    }

    func updateClass(_ danceClass: DanceClass, completion: @escaping (Bool) -> Void) {
        db.collection("classes").document(danceClass.id).updateData([
            "name": danceClass.name,
            "instructor": danceClass.instructor,
            "time": danceClass.time,
            "maxCapacity": danceClass.maxCapacity,
            "description": danceClass.description
        ]) { error in
            if let error = error {
                print("❌ Ошибка обновления занятия: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Занятие обновлено")
                completion(true)
            }
        }
    }

    // MARK: - Записи на занятия

    func enrollUser(userId: String, classId: String, completion: @escaping (Bool) -> Void) {
        let enrollmentRef = db.collection("enrollments").document()
        enrollmentRef.setData([
            "id": enrollmentRef.documentID,
            "userId": userId,
            "classId": classId
        ]) { error in
            if let error = error {
                print("❌ Ошибка записи на занятие: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Пользователь записан на занятие")
                completion(true)
            }
        }
    }

    func getUserBookings(userId: String, completion: @escaping ([(id: String, className: String, instructor: String, time: String)]) -> Void) {
        db.collection("enrollments").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("❌ Ошибка получения бронирований: \(error.localizedDescription)")
                completion([])
                return
            }

            let enrollments = snapshot?.documents.compactMap { document -> Enrollment? in
                let data = document.data()
                return Enrollment(
                    id: data["id"] as? String ?? "",
                    userId: data["userId"] as? String ?? "",
                    classId: data["classId"] as? String ?? ""
                )
            } ?? []

            var bookings: [(String, String, String, String)] = []

            let group = DispatchGroup()
            for enrollment in enrollments {
                group.enter()
                self.db.collection("classes").document(enrollment.classId).getDocument { classSnapshot, _ in
                    if let classData = classSnapshot?.data() {
                        bookings.append((
                            enrollment.id,
                            classData["name"] as? String ?? "",
                            classData["instructor"] as? String ?? "",
                            classData["time"] as? String ?? ""
                        ))
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(bookings)
            }
        }
    }
}
