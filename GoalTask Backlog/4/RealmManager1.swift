import Foundation
import RealmSwift

class RealmManager: ObservableObject {
    @Published var localRealm: Realm?
    private var app: App?
    private var user: User?
    
    init() {
        configureApp(appId: "application-0-qedim")
        openLocalRealm()
    }
    
    func openLocalRealm() {
        do {
            let config = Realm.Configuration(schemaVersion: 2, migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    // Perform necessary migrations here
                    migration.enumerateObjects(ofType: ActionOntology.className()) { oldObject, newObject in
                        newObject!["_id"] = oldObject!["_id"]
                        newObject!["hierarchy"] = oldObject!["hierarchy"] as? Int ?? 0
                        newObject!["action"] = oldObject!["action"] as? String ?? ""
                        newObject!["location"] = oldObject!["location"] as? String ?? ""
                        newObject!["items"] = oldObject!["items"] as? String ?? ""
                        newObject!["cadence"] = oldObject!["cadence"] as? String ?? ""
                        newObject!["time"] = oldObject!["time"] as? String ?? ""
                        newObject!["condition"] = oldObject!["condition"] as? String ?? ""
                        newObject!["equipment"] = oldObject!["equipment"] as? List<String> ?? List<String>()
                        newObject!["instructions"] = oldObject!["instructions"] as? String ?? ""
                        newObject!["desc"] = oldObject!["desc"] as? String ?? ""
                    }
                }
            })
            Realm.Configuration.defaultConfiguration = config
            localRealm = try Realm()
            print("Local realm opened successfully.")
        } catch {
            print("Error opening local Realm: \(error)")
        }
    }
    
    func configureApp(appId: String) {
        app = App(id: appId)
        print("App configured with id: \(appId)")
    }
    
    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let app = app else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "App not configured"])))
            return
        }
        
        print("Attempting to log in with username: \(username)")
        app.login(credentials: Credentials.emailPassword(email: username, password: password)) { result in
            switch result {
            case .success(let user):
                self.user = user
                print("Login successful. User: \(user.id)")
                self.openFlexibleSyncedRealm { realmResult in
                    switch realmResult {
                    case .success:
                        print("Flexible synced realm opened successfully.")
                        completion(.success(()))
                    case .failure(let error):
                        print("Failed to open flexible synced realm: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print("Login failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    private func openFlexibleSyncedRealm(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = user else {
            print("No user found for opening synced realm.")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found"])))
            return
        }
        
        let config = user.flexibleSyncConfiguration(initialSubscriptions: { subs in
            subs.append(QuerySubscription<ActionOntology>(name: "all-action-ontologies"))
            subs.append(QuerySubscription<Item>(name: "all-items"))
        })
        
        print("Opening flexible synced realm")
        Realm.asyncOpen(configuration: config) { result in
            switch result {
            case .success(let realm):
                self.localRealm = realm
                print("Flexible synced realm opened.")
                completion(.success(()))
            case .failure(let error):
                print("Failed to open flexible synced realm: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - CRUD Operations for ActionOntology
    
    func addAction(actionOntology: ActionOntology) {
        do {
            try localRealm?.write {
                localRealm?.add(actionOntology)
            }
            print("Action added successfully.")
        } catch {
            print("Failed to add action: \(error)")
        }
    }
    
    func fetchActions() -> Results<ActionOntology>? {
        print("Fetching actions from realm.")
        return localRealm?.objects(ActionOntology.self)
    }
    
    func fetchLocations() -> [String]? {
        guard let realm = localRealm else { return nil }
        let locations = realm.objects(ActionOntology.self).distinct(by: ["location"]).compactMap { $0.location }
        return Array(Set(locations))
    }

    func fetchActions(for location: String) -> Results<ActionOntology>? {
        guard let realm = localRealm else { return nil }
        return realm.objects(ActionOntology.self).filter("location == %@", location)
    }
    
    func updateAction(actionOntology: ActionOntology, with updates: [String: Any]) {
        do {
            try localRealm?.write {
                for (key, value) in updates {
                    actionOntology.setValue(value, forKey: key)
                }
            }
            print("Action updated successfully.")
        } catch {
            print("Failed to update action: \(error)")
        }
    }
    
    func deleteAction(actionOntology: ActionOntology) {
        do {
            try localRealm?.write {
                localRealm?.delete(actionOntology)
            }
            print("Action deleted successfully.")
        } catch {
            print("Failed to delete action: \(error)")
        }
    }
    
    // MARK: - CRUD Operations for Item
    
    func addItem(item: Item) {
        do {
            try localRealm?.write {
                localRealm?.add(item)
            }
            print("Item added successfully.")
        } catch {
            print("Failed to add item: \(error)")
        }
    }
}
