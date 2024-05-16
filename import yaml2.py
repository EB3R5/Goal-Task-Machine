import yaml
from pymongo import MongoClient
import certifi

def load_config():
    with open('database.yml', 'r') as file:
        return yaml.safe_load(file)

def connect_db():
    config = load_config()
    print("Loaded config:", config)  # Debugging output
    db_uri = config['database']['uri']
    client = MongoClient(
        db_uri,
        tls=True,
        tlsCAFile=certifi.where()
    )
    db_name = 'goaltaskmachine'  # Specify your database name here
    db = client[db_name]
    return db

def main():
    db = connect_db()
    # Example operation: Print the list of collections
    print(db.list_collection_names())

if __name__ == '__main__':
    main()
