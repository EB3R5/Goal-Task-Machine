import tkinter as tk
from tkinter import ttk
import json
import os
from datetime import datetime

def load_locations_and_items():
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
    return location_items, tasks

location_items, original_tasks = load_locations_and_items()

root = tk.Tk()
root.title("Task Conditions Entry")

def update_items_listbox(*args):
    selected_location = location_listbox.get(location_listbox.curselection())
    items_listbox.delete(0, tk.END)
    for item in location_items[selected_location]:
        items_listbox.insert(tk.END, item)

def on_submit():
    selected_location = location_listbox.get(location_listbox.curselection())
    selected_items_indexes = items_listbox.curselection()
    selected_items = [items_listbox.get(i) for i in selected_items_indexes]
    selected_condition = condition_var.get()
    
    # Filter tasks based on selections
    filtered_tasks = [task for task in original_tasks if task['location'] == selected_location and task['items'] in selected_items]
    
    # Add timestamp and sort by hierarchy
    timestamp = datetime.now().isoformat()
    sorted_tasks = sorted(filtered_tasks, key=lambda x: x['hierarchy'])
    for task in sorted_tasks:
        task['submission_timestamp'] = timestamp
    
    # Write to a new JSON file
    new_json_file_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'submitted_tasks.json')
    with open(new_json_file_path, 'w', encoding='utf-8') as file:
        json.dump(sorted_tasks, file, indent=4, ensure_ascii=False)
    
    print(f"Submitted tasks saved to {new_json_file_path}")

location_listbox = tk.Listbox(root, exportselection=False)
for location in location_items.keys():
    location_listbox.insert(tk.END, location)
location_listbox.bind('<<ListboxSelect>>', update_items_listbox)
location_listbox.pack()

items_listbox = tk.Listbox(root, selectmode='multiple', exportselection=False)
items_listbox.pack()

conditions = ["Somewhat Dirty", "Somewhat Clean", "Super Dirty"]
condition_var = tk.StringVar()
condition_dropdown = ttk.Combobox(root, textvariable=condition_var, values=conditions)
condition_dropdown.pack()

submit_button = tk.Button(root, text="Submit", command=on_submit)
submit_button.pack()

root.mainloop()
