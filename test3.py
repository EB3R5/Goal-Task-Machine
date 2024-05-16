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

def fetch_unique_locations():
    db = connect_db()
    collection = db['Actions Ontology']
    pipeline = [
        {
            "$group": {
                "_id": "$location"
            }
        },
        {
            "$sort": {"_id": 1}
        }
    ]
    locations = list(collection.aggregate(pipeline))
    return [location['_id'] for location in locations]

def fetch_aggregated_data(location=None):
    db = connect_db()
    collection = db['Actions Ontology']
    pipeline = []
    if location:
        pipeline.append({
            "$match": {"location": location}
        })
    pipeline.extend([
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
    ])
    data = list(collection.aggregate(pipeline))
    return data

def update_tree(tree, data):
    for item in tree.get_children():
        tree.delete(item)
    for item in data:
        location = item["_id"]
        count = item["count"]
        details = item["data"]
        details_str = ", ".join([str(detail) for detail in details])
        tree.insert("", "end", values=(location, count, details_str))

def on_location_select(event, tree):
    selected_location = event.widget.get()
    data = fetch_aggregated_data(selected_location)
    update_tree(tree, data)

def display_data(data, locations):
    root = tk.Tk()
    root.title("Aggregated Actions Ontology Data by Location")

    frame = ttk.Frame(root)
    frame.pack(fill=tk.BOTH, expand=True)

    # Location Dropdown
    location_label = ttk.Label(frame, text="Select Location:")
    location_label.pack(side=tk.LEFT, padx=5, pady=5)

    location_combo = ttk.Combobox(frame, values=locations)
    location_combo.pack(side=tk.LEFT, padx=5, pady=5)
    location_combo.bind("<<ComboboxSelected>>", lambda event: on_location_select(event, tree))

    # Treeview for Data
    tree = ttk.Treeview(frame)
    tree["columns"] = ("Location", "Count", "Data")
    tree["show"] = "headings"

    tree.heading("Location", text="Location")
    tree.heading("Count", text="Count")
    tree.heading("Data", text="Data")

    tree.column("Location", width=100)
    tree.column("Count", width=50)
    tree.column("Data", width=500)

    tree.pack(expand=True, fill='both')

    update_tree(tree, data)

    root.mainloop()

def main():
    locations = fetch_unique_locations()
    data = fetch_aggregated_data()
    display_data(data, locations)

if __name__ == '__main__':
    main()
