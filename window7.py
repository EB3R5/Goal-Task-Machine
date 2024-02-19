import tkinter as tk
from tkinter import ttk, messagebox
import json
import os
from datetime import datetime
import gspread
from oauth2client.service_account import ServiceAccountCredentials

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
            location_items[location].append(item) if item not in location_items[location] else None
        else:
            location_items[location] = [item]
    return location_items, tasks

def init_google_sheets():
    scope = ['https://www.googleapis.com/auth/spreadsheets', 'https://www.googleapis.com/auth/drive']
    creds = ServiceAccountCredentials.from_json_keyfile_name('C:\\Users\\chris\\Github\\Think-Altar\\Load\\actioeventus.json', scope)  # Update this path
    client = gspread.authorize(creds)
    sheet = client.open("Commentary Sheet").worksheet("Events")  # Ensure this matches your Google Sheet and worksheet name
    return sheet

def send_to_google_sheets():
    script_dir = os.path.dirname(os.path.realpath(__file__))
    tasks_file_path = os.path.join(script_dir, 'submitted_tasks.json')
    
    try:
        with open(tasks_file_path, 'r', encoding='utf-8') as file:
            tasks = json.load(file)
    except FileNotFoundError:
        messagebox.showerror("Error", "Submitted tasks file not found.")
        return
    
    sheet = init_google_sheets()
    data = [["To-do", task['submission_timestamp'], task['location'] + " - " + task['items']] for task in tasks]
    
    try:
        sheet.append_rows(data)
        messagebox.showinfo("Success", "Tasks successfully uploaded to Google Sheets.")
    except Exception as e:
        messagebox.showerror("Error", f"Failed to upload tasks to Google Sheets: {e}")

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
    
    filtered_tasks = [task for task in original_tasks if task['location'] == selected_location and task['items'] in selected_items]
    timestamp = datetime.now().isoformat()
    for task in filtered_tasks:
        task['submission_timestamp'] = timestamp
    
    new_json_file_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'submitted_tasks.json')
    
    try:
        with open(new_json_file_path, 'r+', encoding='utf-8') as file:
            existing_entries = json.load(file)
            existing_entries.extend(filtered_tasks)
            file.seek(0)
            json.dump(existing_entries, file, indent=4, ensure_ascii=False)
            file.truncate()
    except FileNotFoundError:
        with open(new_json_file_path, 'w', encoding='utf-8') as file:
            json.dump(filtered_tasks, file, indent=4, ensure_ascii=False)
    
    messagebox.showinfo("Success", "Tasks saved locally.")

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

# Button to upload tasks to Google Sheets
upload_button = tk.Button(root, text="Upload to Google Sheets", command=send_to_google_sheets)
upload_button.pack()

root.mainloop()
