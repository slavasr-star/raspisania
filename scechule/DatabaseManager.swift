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
                print("Ошибка регистрации: \(error.localizedDescription)")
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
                    print("Ошибка сохранения пользователя: \(error.localizedDescription)")
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
                print("Ошибка входа: \(error.localizedDescription)")
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
                print("Ошибка удаления занятия: \(error.localizedDescription)")
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
            print("Ошибка добавления занятия: \(error.localizedDescription)")
            return false
        }
    }
    
    func getAllClasses(completion: @escaping ([DanceClass]) -> Void) {
        db.collection("classes").getDocuments { snapshot, error in
            if let error = error {
                print("Ошибка получения занятий: \(error.localizedDescription)")
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
    
    func getUserBookings(userId: String, completion: @escaping ([(id: String, className: String, instructor: String, time: String, maxCapacity: Int, description: String)]) -> Void) {
        print("Запрос записей для userId: \(userId)")
        
        db.collection("enrollments").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("Ошибка получения записей: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("Нет записей у пользователя")
                completion([])
                return
            }
            
            print("Найдено \(documents.count) записей в enrollments")
            
            let enrollments = documents.compactMap { document -> Enrollment? in
                let data = document.data()
                guard let classId = data["classId"] as? String else { return nil }
                return Enrollment(id: document.documentID, userId: userId, classId: classId)
            }
            
            let classIds = enrollments.map { $0.classId }
            print("Найдены classIds: \(classIds)")
            
            guard !classIds.isEmpty else {
                print("classIds пуст, пропускаем запрос к classes")
                completion([])
                return
            }
            
            self.db.collection("classes").whereField(FieldPath.documentID(), in: classIds).getDocuments { classSnapshot, error in
                if let error = error {
                    print("Ошибка получения данных о занятиях: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let classMap = classSnapshot?.documents.reduce(into: [String: DanceClass]()) { result, document in
                    let data = document.data()
                    result[document.documentID] = DanceClass(
                        id: document.documentID,
                        name: data["name"] as? String ?? "Без названия",
                        instructor: data["instructor"] as? String ?? "Неизвестно",
                        time: data["time"] as? String ?? "Не указано",
                        maxCapacity: data["maxCapacity"] as? Int ?? 10,
                        description: data["description"] as? String ?? "Нет описания"
                    )
                } ?? [:]
                
                print("Загруженные занятия: \(classMap)")
                
                let bookings = enrollments.compactMap { enrollment -> (String, String, String, String, Int, String)? in
                    guard let danceClass = classMap[enrollment.classId] else {
                        print("Не найдено занятие для classId: \(enrollment.classId)")
                        return nil
                    }
                    return (enrollment.id, danceClass.name, danceClass.instructor, danceClass.time, danceClass.maxCapacity, danceClass.description)
                }
                
                print("Итоговые записи пользователя: \(bookings)")
                completion(bookings)
            }
        }
    }
    
    func getPastBookings(userId: String, completion: @escaping ([(id: String, className: String, instructor: String, time: String, maxCapacity: Int, description: String)]) -> Void) {
        let now = Timestamp(date: Date())

        db.collection("pastBookings")
            .whereField("userId", isEqualTo: userId)
            .whereField("timestamp", isLessThan: now)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Ошибка получения прошедших записей: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let pastBookings = snapshot?.documents.compactMap { document -> (String, String, String, String, Int, String)? in
                    let data = document.data()
                    guard data["timestamp"] is Timestamp else {
                        print("Пропущена запись без timestamp: \(document.documentID)")
                        return nil
                    }
                    return (
                        document.documentID,
                        data["className"] as? String ?? "Без названия",
                        data["instructor"] as? String ?? "Неизвестно",
                        data["time"] as? String ?? "Не указано",
                        data["maxCapacity"] as? Int ?? 10,
                        data["description"] as? String ?? "Нет описания"
                    )
                } ?? []

                completion(pastBookings)
            }
    }

    func movePastBookings(userId: String, completion: @escaping (Bool) -> Void) {
        db.collection("enrollments")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Ошибка получения записей для переноса: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("Нет записей для переноса")
                    completion(false)
                    return
                }

                let batch = self.db.batch()
                var movedCount = 0

                for document in documents {
                    let data = document.data()
                    guard let classTime = data["timestamp"] as? Timestamp else {
                        print("Пропущена запись без timestamp: \(document.documentID)")
                        continue
                    }

                    if classTime.dateValue() < Date() {
                        let pastBookingRef = self.db.collection("pastBookings").document(document.documentID)
                        batch.setData(data, forDocument: pastBookingRef)
                        batch.deleteDocument(document.reference)
                        movedCount += 1
                    }
                }

                if movedCount > 0 {
                    batch.commit { error in
                        if let error = error {
                            print("Ошибка при перемещении записей: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Перемещено \(movedCount) записей в pastBookings")
                            completion(true)
                        }
                    }
                } else {
                    print("Нет записей для переноса")
                    completion(false)
                }
            }
    }
    func autoCompleteTrainings(completion: @escaping (Bool) -> Void) {
        _ = Timestamp(date: Date())

        db.collection("enrollments").getDocuments { snapshot, error in
            if let error = error {
                print("Ошибка получения записей: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("Нет записей для обработки")
                completion(false)
                return
            }

            let batch = self.db.batch()
            var movedCount = 0

            for document in documents {
                let data = document.data()
                guard let classId = data["classId"] as? String else { continue }

                // Получаем время тренировки
                self.db.collection("classes").document(classId).getDocument { classDoc, error in
                    if let error = error {
                        print("Ошибка получения занятия: \(error.localizedDescription)")
                        return
                    }

                    guard let classData = classDoc?.data(),
                          let classTimeString = classData["time"] as? String,
                          let classTime = self.convertToDate(classTimeString) else { return }

                    if classTime < Date() {
                        // Переносим в pastBookings
                        let pastBookingRef = self.db.collection("pastBookings").document(document.documentID)
                        batch.setData(data, forDocument: pastBookingRef)
                        batch.deleteDocument(document.reference)
                        movedCount += 1
                    }

                    if movedCount > 0 {
                        batch.commit { error in
                            if let error = error {
                                print("Ошибка при перемещении записей: \(error.localizedDescription)")
                                completion(false)
                            } else {
                                print("Перемещено \(movedCount) записей в pastBookings")
                                completion(true)
                            }
                        }
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }

    // Функция для конвертации строки времени в Date
    private func convertToDate(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: timeString)
    }

}
