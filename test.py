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

def fetch_data():
    db = connect_db()
    collection = db['Actions Ontology']
    data = list(collection.find())
    return data

def display_data(data):
    root = tk.Tk()
    root.title("Actions Ontology Data")

    tree = ttk.Treeview(root)
    tree["columns"] = list(data[0].keys())
    tree["show"] = "headings"

    for col in tree["columns"]:
        tree.heading(col, text=col)
        tree.column(col, width=100)

    for item in data:
        tree.insert("", "end", values=list(item.values()))

    tree.pack(expand=True, fill='both')
    root.mainloop()

def main():
    data = fetch_data()
    display_data(data)

if __name__ == '__main__':
    main()
