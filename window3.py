import tkinter as tk
from tkinter import ttk
import json
import os

# Function to load locations and their items from the JSON file
def load_locations_and_items():
    # Determine the path of the JSON file relative to this script
    script_dir = os.path.dirname(os.path.realpath(__file__))
    json_file_path = os.path.join(script_dir, 'cleaning_tasks.json')
    
    # Load the data from the JSON file
    with open(json_file_path, 'r', encoding='utf-8') as file:
        tasks = json.load(file)
    
    # Extract locations and their associated items
    location_items = {}
    for task in tasks:
        location = task['location']
        item = task['items']
        if location in location_items:
            if item not in location_items[location]:
                location_items[location].append(item)
        else:
            location_items[location] = [item]
    return location_items

# Load locations and items from the JSON file
location_items = load_locations_and_items()

# Conditions (simplified to unique values for the dropdown)
conditions = ["Somewhat Dirty", "Somewhat Clean", "Super Dirty"]

def update_items_dropdown(*args):
    location = location_var.get()
    items_dropdown['values'] = location_items.get(location, [])
    items_var.set('')  # Clear the previous selection

def on_submit():
    selected_location = location_var.get()
    selected_item = items_var.get()
    selected_condition = condition_var.get()
    print(f"Location: {selected_location}, Item: {selected_item}, Condition: {selected_condition}")
    # Add logic here as needed

# Set up the main window
root = tk.Tk()
root.title("Task Conditions Entry")

# Variables to hold the dropdown selections
location_var = tk.StringVar()
items_var = tk.StringVar()
condition_var = tk.StringVar()

# Setup the callback for location selection changes
location_var.trace('w', update_items_dropdown)

# Location dropdown
location_label = tk.Label(root, text="Select Location:")
location_label.pack()
location_dropdown = ttk.Combobox(root, textvariable=location_var, values=list(location_items.keys()))
location_dropdown.pack()

# Items dropdown (updates based on location)
items_label = tk.Label(root, text="Select Item:")
items_label.pack()
items_dropdown = ttk.Combobox(root, textvariable=items_var)
items_dropdown.pack()

# Condition dropdown
condition_label = tk.Label(root, text="Select Condition:")
condition_label.pack()
condition_dropdown = ttk.Combobox(root, textvariable=condition_var, values=conditions)
condition_dropdown.pack()

# Submit button
submit_button = tk.Button(root, text="Submit", command=on_submit)
submit_button.pack()

# Start the Tkinter event loop
root.mainloop()
