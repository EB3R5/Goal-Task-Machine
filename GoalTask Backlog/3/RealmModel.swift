import Foundation
import RealmSwift

// Define your ActionOntology class
class ActionOntology: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var hierarchy: Int
    @Persisted var action: String
    @Persisted var location: String
    @Persisted var items: String
    @Persisted var cadence: String
    @Persisted var time: String
    @Persisted var condition: String
    @Persisted var equipment: List<String>
    @Persisted var instructions: String
    @Persisted var desc: String

    override static func primaryKey() -> String? {
        return "_id"
    }

    // Define the Realm object name (collection name)
    override static func className() -> String {
        return "ActionOntology"
    }
}

// Define the Item class
class Item: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var isComplete: Bool
    @Persisted var owner_id: String
    @Persisted var summary: String

    override static func primaryKey() -> String? {
        return "_id"
    }

    // Define the Realm object name (collection name)
    override static func className() -> String {
        return "Item"
    }
}

// Function to get the Realm instance
func getRealmInstance() -> Realm {
    let config = Realm.Configuration(
        schemaVersion: 2,  // Increment the schema version
        migrationBlock: { migration, oldSchemaVersion in
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
        },
        objectTypes: [ActionOntology.self, Item.self]  // Specify the object types explicitly
    )

    // Set this configuration as the default
    Realm.Configuration.defaultConfiguration = config

    return try! Realm()
}
