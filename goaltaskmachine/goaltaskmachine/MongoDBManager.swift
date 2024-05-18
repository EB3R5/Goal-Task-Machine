import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    private var app: App
    private var realm: Realm?

    private init() {
        let appId = "application-0-qedim" // Replace with your MongoDB Realm App ID
        app = App(id: appId)
    }
    
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let credentials = Credentials.emailPassword(email: email, password: password)
        app.login(credentials: credentials) { result in
            switch result {
            case .success(let user):
                self.setupRealm(for: user)
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func setupRealm(for user: User) {
        let configuration = user.configuration(partitionValue: "your-partition-value") // Replace with your partition value if needed
        do {
            realm = try Realm(configuration: configuration)
        } catch let error as NSError {
            print("Error initializing Realm: \(error.localizedDescription)")
        }
    }

    func fetchUniqueLocations(completion: @escaping ([String]) -> Void) {
        guard let realm = realm else {
            print("Realm not initialized")
            completion([])
            return
        }
        let locations = realm.objects(ActionOntology.self).compactMap { $0.location }.distinct()
        completion(Array(locations))
    }
    
    func fetchDataByLocation(location: String, completion: @escaping ([ActionOntology]) -> Void) {
        guard let realm = realm else {
            print("Realm not initialized")
            completion([])
            return
        }
        let data = realm.objects(ActionOntology.self).filter("location == %@", location)
        completion(Array(data))
    }

    // Create or Update an ActionOntology object
    func addOrUpdateActionOntology(actionOntology: ActionOntology) {
        guard let realm = realm else {
            print("Realm not initialized")
            return
        }
        do {
            try realm.write {
                realm.add(actionOntology, update: .modified)
            }
        } catch let error as NSError {
            print("Error adding or updating ActionOntology: \(error.localizedDescription)")
        }
    }
    
    // Retrieve an ActionOntology object by its primary key (_id)
    func getActionOntologyById(_id: ObjectId) -> ActionOntology? {
        guard let realm = realm else {
            print("Realm not initialized")
            return nil
        }
        return realm.object(ofType: ActionOntology.self, forPrimaryKey: _id)
    }
    
    // Retrieve all ActionOntology objects
    func getAllActionOntologies() -> Results<ActionOntology>? {
        guard let realm = realm else {
            print("Realm not initialized")
            return nil
        }
        return realm.objects(ActionOntology.self)
    }
    
    // Delete an ActionOntology object
    func deleteActionOntology(actionOntology: ActionOntology) {
        guard let realm = realm else {
            print("Realm not initialized")
            return
        }
        do {
            try realm.write {
                realm.delete(actionOntology)
            }
        } catch let error as NSError {
            print("Error deleting ActionOntology: \(error.localizedDescription)")
        }
    }
    
    // Delete an ActionOntology object by its primary key (_id)
    func deleteActionOntologyById(_id: ObjectId) {
        guard let realm = realm else {
            print("Realm not initialized")
            return
        }
        if let actionOntology = getActionOntologyById(_id: _id) {
            deleteActionOntology(actionOntology: actionOntology)
        } else {
            print("ActionOntology with id \(_id) not found")
        }
    }
}
