import RealmSwift

class RealmManager1: ObservableObject {
    private var realm: Realm

    init() {
        self.realm = getRealmInstance()
    }

    // Login function
    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let app = App(id: "application-0-qedim")  // Replace with your MongoDB Realm App ID
        app.login(credentials: .emailPassword(email: username, password: password)) { result in
            switch result {
            case .success(let user):
                print("Login successful. User: \(user.id)")
                completion(.success(()))
            case .failure(let error):
                print("Login failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    // Fetch all ActionOntology objects
    func fetchActions() -> Results<ActionOntology>? {
        return realm.objects(ActionOntology.self)
    }

    // Add a new ActionOntology object
    func addActionOntology(actionOntology: ActionOntology) {
        try! realm.write {
            realm.add(actionOntology)
        }
    }

    // MARK: - CRUD Operations for Item
    
    func addItem(item: Item) {
        do {
            try realm.write {
                realm.add(item)
            }
            print("Item added successfully.")
        } catch {
            print("Failed to add item: \(error)")
        }
    }
    
    func fetchItems() -> Results<Item>? {
        print("Fetching items from realm.")
        return realm.objects(Item.self)
    }
    
    func updateItem(item: Item, with updates: [String: Any]) {
        do {
            try realm.write {
                for (key, value) in updates {
                    item.setValue(value, forKey: key)
                }
            }
            print("Item updated successfully.")
        } catch {
            print("Failed to update item: \(error)")
        }
    }
    
    func deleteItem(item: Item) {
        do {
            try realm.write {
                realm.delete(item)
            }
            print("Item deleted successfully.")
        } catch {
            print("Failed to delete item: \(error)")
        }
    }
}
