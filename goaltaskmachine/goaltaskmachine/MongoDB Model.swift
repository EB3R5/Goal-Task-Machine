import Foundation
import RealmSwift

class ActionOntology: Object {
    @Persisted(primaryKey: true) var _id: ObjectId

    @Persisted var action: String?

    @Persisted var cadence: String?

    @Persisted var condition: String?

    @Persisted var desc: String?

    @Persisted var hierarchy: String?

    @Persisted var items: String?

    @Persisted var location: String?

    @Persisted var time: String?
}
