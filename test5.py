import os
import yaml
from pymongo import MongoClient
import certifi
import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk

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

def fetch_data_by_location(location):
    db = connect_db()
    collection = db['Actions Ontology']
    data = list(collection.find({"location": location}))
    return data

def update_tree(tree, data):
    for item in tree.get_children():
        tree.delete(item)
    for item in data:
        values = [item.get(field, "") for field in tree["columns"]]
        tree.insert("", "end", values=values)

def on_location_click(location, tree):
    data = fetch_data_by_location(location)
    update_tree(tree, data)

def load_icons(locations):
    icons = {}
    for location in locations:
        try:
            image = Image.open(f'icons/{location}.png')
            icon = ImageTk.PhotoImage(image)
            icons[location] = icon
        except FileNotFoundError:
            print(f"Icon for {location} not found.")
    return icons

def display_data(locations):
    root = tk.Tk()
    root.title("Actions Ontology Data by Location")

    frame = ttk.Frame(root)
    frame.pack(fill=tk.BOTH, expand=True)

    # Load icons for each location
    icons = load_icons(locations)

    # Create buttons with icons
    button_frame = ttk.Frame(frame)
    button_frame.pack(side=tk.TOP, padx=5, pady=5)
    for location in locations:
        if location in icons:
            btn = tk.Button(button_frame, image=icons[location], command=lambda loc=location: on_location_click(loc, tree))
            btn.pack(side=tk.LEFT, padx=5, pady=5)
        else:
            btn = tk.Button(button_frame, text=location, command=lambda loc=location: on_location_click(loc, tree))
            btn.pack(side=tk.LEFT, padx=5, pady=5)

    # Treeview for Data
    tree = ttk.Treeview(frame)
    # Define the columns based on your document fields
    columns = ["_id", "location", "action", "details", "timestamp"]  # Adjust the field names as needed
    tree["columns"] = columns
    tree["show"] = "headings"

    for col in columns:
        tree.heading(col, text=col)
        tree.column(col, width=100)  # Adjust column width as needed

    tree.pack(expand=True, fill='both')

    root.mainloop()

def main():
    locations = fetch_unique_locations()
    display_data(locations)

if __name__ == '__main__':
    main()
