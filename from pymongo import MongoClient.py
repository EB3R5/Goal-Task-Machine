from pymongo import MongoClient

# Replace with your connection string
client = MongoClient("mongodb+srv://christianebers:Lincoln6840!@cluster57572.9mdt0m1.mongodb.net/goaltaskmachine?retryWrites=true&w=majority")
db = client['goaltaskmachine']
collection = db['Actions Ontology']

# Find documents with the 'description' field and update them
for doc in collection.find({ 'description': { '$exists': True } }):
    collection.update_one(
        { '_id': doc['_id'] },
        { '$set': { 'desc': doc['description'] }, '$unset': { 'description': "" } }
    )

print("Field names updated successfully.")
