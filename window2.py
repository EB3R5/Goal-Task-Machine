import tkinter as tk
from tkinter import ttk

# Pre-defined locations and their associated items (simulated for this example)
location_items = {
    'Closet': ['Clothes', 'Sheets', 'Towels'],
    'Living Room': ['Surfaces'],
    'Kitchen': ['Dishwasher', 'Cabinets', 'Fridge'],
    'Bathroom': ['Surfaces', 'Drawers'],
    'Bedroom': ['Surfaces'],
    'Den': ['Surfaces', 'Computer'],
    'Car': ['Surfaces']
}

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
    # Add logic here as needed, such as filtering tasks based on selection

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
