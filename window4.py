import tkinter as tk
from tkinter import ttk
import json
import os

# Function to load locations and their items from the JSON file
def load_locations_and_items():
    # Assuming the JSON file is in the same directory as this script
    script_dir = os.path.dirname(os.path.realpath(__file__))
    json_file_path = os.path.join(script_dir, 'cleaning_tasks.json')
    
    with open(json_file_path, 'r', encoding='utf-8') as file:
        tasks = json.load(file)
    
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

location_items = load_locations_and_items()

# Initialize the main window
root = tk.Tk()
root.title("Task Conditions Entry")

def update_items_listbox(*args):
    selected_location = location_listbox.get(location_listbox.curselection())
    items_listbox.delete(0, tk.END)  # Clear the items listbox
    for item in location_items[selected_location]:
        items_listbox.insert(tk.END, item)

def on_submit():
    try:
        selected_location = location_listbox.get(location_listbox.curselection())
        selected_items = [items_listbox.get(i) for i in items_listbox.curselection()]
        selected_condition = condition_var.get()
        print(f"Location: {selected_location}, Items: {selected_items}, Condition: {selected_condition}")
    except tk.TclError:
        print("Please select at least one location and item.")

# Location ListBox
location_label = tk.Label(root, text="Select Location:")
location_label.pack()
location_listbox = tk.Listbox(root, exportselection=False)
location_listbox.pack()
for location in location_items.keys():
    location_listbox.insert(tk.END, location)
location_listbox.bind('<<ListboxSelect>>', update_items_listbox)

# Items ListBox
items_label = tk.Label(root, text="Select Items:")
items_label.pack()
items_listbox = tk.Listbox(root, selectmode='multiple', exportselection=False)
items_listbox.pack()

# Condition Dropdown
condition_label = tk.Label(root, text="Select Condition:")
condition_label.pack()
conditions = ["Somewhat Dirty", "Somewhat Clean", "Super Dirty"]
condition_var = tk.StringVar()
condition_dropdown = ttk.Combobox(root, textvariable=condition_var, values=conditions)
condition_dropdown.pack()

# Submit button
submit_button = tk.Button(root, text="Submit", command=on_submit)
submit_button.pack()

# Start the Tkinter event loop
root.mainloop()
