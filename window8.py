import tkinter as tk
from tkinter import ttk, messagebox
import os
from datetime import datetime
import gspread
from oauth2client.service_account import ServiceAccountCredentials

def init_google_sheets():
    scope = ['https://www.googleapis.com/auth/spreadsheets', 'https://www.googleapis.com/auth/drive']
    creds = ServiceAccountCredentials.from_json_keyfile_name('C:\\Users\\chris\\Github\\Think-Altar\\Load\\actioeventus.json', scope)  # Update this path
    client = gspread.authorize(creds)
    sheet = client.open("Commentary Sheet").worksheet("Events")  # Ensure this matches your Google Sheet and worksheet name
    return sheet

def send_to_google_sheets(filepath):
    sheet = init_google_sheets()
    with open(filepath, 'r', encoding='utf-8') as file:
        tasks = file.readlines()

    data = []
    for task in tasks:
        task_details = task.strip()
        if task_details:  # Ensure the task is not empty
            timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')  # Format timestamp without 'T'
            data.append(["To-Do", timestamp, task_details])

    if data:
        try:
            sheet.append_rows(data)
            messagebox.showinfo("Success", "Tasks successfully uploaded to Google Sheets.")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to upload tasks to Google Sheets: {e}")

root = tk.Tk()
root.title("Upload Tasks to Google Sheets")

def on_upload():
    filepath = 'C:\\Users\\chris\\Github\\Goal-Task-Machine\\tasks_list.txt' # Path to your tasks_list.txt file
    send_to_google_sheets(filepath)

upload_button = tk.Button(root, text="Upload Tasks", command=on_upload)
upload_button.pack(pady=20)

root.mainloop()
