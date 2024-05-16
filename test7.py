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

def add_document_to_mongo(data):
    db = connect_db()
    collection = db['done']
    collection.insert_one(data)
    print("Document added to MongoDB:", data)

def show_add_document_window():
    def submit_data():
        data = {
            "location": location_entry.get(),
            "action": action_entry.get(),
            "details": details_entry.get(),
            "timestamp": timestamp_entry.get()
        }
        add_document_to_mongo(data)
        add_window.destroy()

    add_window = tk.Toplevel()
    add_window.title("Add New Document")

    tk.Label(add_window, text="Location").pack(pady=5)
    location_entry = tk.Entry(add_window)
    location_entry.pack(pady=5)

    tk.Label(add_window, text="Action").pack(pady=5)
    action_entry = tk.Entry(add_window)
    action_entry.pack(pady=5)

    tk.Label(add_window, text="Details").pack(pady=5)
    details_entry = tk.Entry(add_window)
    details_entry.pack(pady=5)

    tk.Label(add_window, text="Timestamp").pack(pady=5)
    timestamp_entry = tk.Entry(add_window)
    timestamp_entry.pack(pady=5)

    tk.Button(add_window, text="Submit", command=submit_data).pack(pady=20)

def display_data(locations):
    root = tk.Tk()
    root.title("Actions Ontology Data by Location")

    frame = ttk.Frame(root)
    frame.pack(fill=tk.BOTH, expand=True)

    # Create a canvas with a scrollbar
    canvas = tk.Canvas(frame)
    scrollbar = ttk.Scrollbar(frame, orient="vertical", command=canvas.yview)
    scrollable_frame = ttk.Frame(canvas)

    scrollable_frame.bind(
        "<Configure>",
        lambda e: canvas.configure(
            scrollregion=canvas.bbox("all")
        )
    )

    canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
    canvas.configure(yscrollcommand=scrollbar.set)

    scrollbar.pack(side="right", fill="y")
    canvas.pack(side="left", fill="both", expand=True)

    # Load icons for each location
    icons = load_icons(locations)

    # Create frames with icons and titles in the scrollable frame
    for location in locations:
        location_frame = ttk.Frame(scrollable_frame)
        location_frame.pack(side=tk.TOP, fill=tk.X, padx=5, pady=5)

        if location in icons:
            icon_label = tk.Label(location_frame, image=icons[location])
            icon_label.pack(side=tk.LEFT, padx=5, pady=5)
        else:
            icon_label = tk.Label(location_frame, text="[No Icon]")
            icon_label.pack(side=tk.LEFT, padx=5, pady=5)

        title_button = tk.Button(location_frame, text=location, command=lambda loc=location: on_location_click(loc, tree))
        title_button.pack(side=tk.LEFT, padx=5, pady=5)

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

    # Add button to open the add document window
    add_button = tk.Button(root, text="Add Document", command=show_add_document_window)
    add_button.pack(pady=10)

    root.mainloop()

def main():
    locations = fetch_unique_locations()
    display_data(locations)

if __name__ == '__main__':
    main()
