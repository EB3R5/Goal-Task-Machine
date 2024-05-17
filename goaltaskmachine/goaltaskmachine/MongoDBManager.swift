import MongoSwiftSync
import Foundation

class MongoDBManager {
    static let shared = MongoDBManager()
    private var client: MongoClient?

    private init() {
        do {
            client = try MongoClient(Config.mongoDBURI)
        } catch {
            print("Failed to create MongoClient: \(error)")
        }
    }

    func connectDB() -> MongoDatabase? {
        guard let client = client else {
            return nil
        }
        return client.db("goaltaskmachine")
    }

    func fetchUniqueLocations(completion: @escaping ([String]) -> Void) {
        guard let db = connectDB() else {
            completion([])
            return
        }

        let collection = db.collection("Actions Ontology")
        let pipeline: [BSONDocument] = [
            ["$group": ["_id": "$location"]],
            ["$sort": ["_id": 1]]
        ]

        do {
            var locations: [String] = []
            let cursor = try collection.aggregate(pipeline)
            for document in cursor {
                if let location = document["_id"]?.stringValue {
                    locations.append(location)
                }
            }
            completion(locations)
        } catch {
            print("Failed to fetch locations: \(error)")
            completion([])
        }
    }

    func fetchDataByLocation(location: String, completion: @escaping ([BSONDocument]) -> Void) {
        guard let db = connectDB() else {
            completion([])
            return
        }

        let collection = db.collection("Actions Ontology")
        do {
            var documents: [BSONDocument] = []
            let cursor = try collection.find(["location": BSON(location)])
            for document in cursor {
                documents.append(document)
            }
            completion(documents)
        } catch {
            print("Failed to fetch data for location \(location): \(error)")
            completion([])
        }
    }

    func addDocumentToMongo(data: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let db = connectDB() else {
            completion(false)
            return
        }

        let collection = db.collection("done")
        do {
            let bsonData = BSONDocument(data.mapValues { BSON($0 as! Int) })
            try collection.insertOne(bsonData)
            completion(true)
        } catch {
            print("Failed to add document: \(error)")
            completion(false)
        }
    }
}
