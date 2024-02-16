import tkinter as tk
from tkinter import ttk
import json
import os

def load_unique_locations(json_file_path):
    with open(json_file_path, 'r', encoding='utf-8') as file:
        tasks = json.load(file)
    # Extract unique locations
    unique_locations = set(task["location"] for task in tasks)
    return list(unique_locations)

def on_submit():
    selected_location = location_var.get()
    selected_condition = condition_var.get()
    print(f"Location: {selected_location}, Condition: {selected_condition}")
    # Here you could add logic to handle the submission, such as filtering tasks based on the selection

# Get the directory where the script is located
script_dir = os.path.dirname(os.path.realpath(__file__))

# Specify the JSON file name
json_file_name = 'cleaning_tasks.json'

# Full path for the JSON file
json_file_path = os.path.join(script_dir, json_file_name)

# Load unique locations from the JSON file
locations = load_unique_locations(json_file_path)

# Conditions (simplified for the example)
conditions = [
    "Somewhat Dirty",
    "Somewhat Clean",
    "Super Dirty"
]

# Set up the main window
root = tk.Tk()
root.title("Task Conditions Entry")

# Variables to hold the dropdown selections
location_var = tk.StringVar()
condition_var = tk.StringVar()

# Create and populate the location dropdown
location_label = tk.Label(root, text="Select Location:")
location_label.pack()
location_dropdown = ttk.Combobox(root, textvariable=location_var, values=locations)
location_dropdown.pack()

# Create and populate the condition dropdown
condition_label = tk.Label(root, text="Select Condition:")
condition_label.pack()
condition_dropdown = ttk.Combobox(root, textvariable=condition_var, values=conditions)
condition_dropdown.pack()

# Submit button
submit_button = tk.Button(root, text="Submit", command=on_submit)
submit_button.pack()

# Start the Tkinter event loop
root.mainloop()
