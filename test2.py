import os
import yaml
from pymongo import MongoClient
import certifi
import tkinter as tk
from tkinter import ttk

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

def fetch_aggregated_data():
    db = connect_db()
    collection = db['Actions Ontology']
    pipeline = [
        {
            "$group": {
                "_id": "$location",
                "count": {"$sum": 1},
                "data": {"$push": "$$ROOT"}
            }
        },
        {
            "$sort": {"_id": 1}
        }
    ]
    data = list(collection.aggregate(pipeline))
    return data

def display_data(data):
    root = tk.Tk()
    root.title("Aggregated Actions Ontology Data by Location")

    tree = ttk.Treeview(root)
    tree["columns"] = ("Location", "Count", "Data")
    tree["show"] = "headings"

    tree.heading("Location", text="Location")
    tree.heading("Count", text="Count")
    tree.heading("Data", text="Data")

    tree.column("Location", width=100)
    tree.column("Count", width=50)
    tree.column("Data", width=500)

    for item in data:
        location = item["_id"]
        count = item["count"]
        details = item["data"]
        details_str = ", ".join([str(detail) for detail in details])
        tree.insert("", "end", values=(location, count, details_str))

    tree.pack(expand=True, fill='both')
    root.mainloop()

def main():
    data = fetch_aggregated_data()
    display_data(data)

if __name__ == '__main__':
    main()
