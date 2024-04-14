import json
from pymongo import MongoClient

# Replace the URI below with your actual MongoDB Atlas connection URI
uri = "mongodb+srv://christianebers:Lincoln6840!@cluster57572.9mdt0m1.mongodb.net/myDatabase?retryWrites=true&w=majority"

client = MongoClient(uri)
db = client['goaltaskmachine']  # Make sure 'goaltaskmachine' is the correct database name
collection = db['Actions Ontology']  # This should be the name of your collection

# Load JSON data
with open('/Users/christian/Documents/GitHub/Goal-Task-Machine/cleaning_tasks.json') as file:
    data = json.load(file)

# Insert data into the collection
collection.insert_many(data)
