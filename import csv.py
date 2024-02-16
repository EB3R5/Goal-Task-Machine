import csv
import json
import os

# Get the directory where the script is located
script_dir = os.path.dirname(os.path.realpath(__file__))

# Specify the CSV and JSON file names
csv_file_name = 'pop.csv'
json_file_name = 'cleaning_tasks.json'

# Full paths for the files
csv_file_path = os.path.join(script_dir, csv_file_name)
json_file_path = os.path.join(script_dir, json_file_name)

# Read the CSV and add data to a dictionary
tasks = []
with open(csv_file_path, mode='r', encoding='utf-8') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        # Check if "Hierarchy" is empty and set a default value if necessary
        hierarchy_value = row["Hierarchy"].strip()
        hierarchy = int(hierarchy_value) if hierarchy_value else 0

        task = {
            "hierarchy": hierarchy,
            "action": row["Action"],
            "location": row["Location"],
            "items": row["Items"],
            "cadence": row["Cadence"],
            "description": row["Description"],
            "time": row["Time"],
            "condition": row["Condition"],
            "equipment": [item.strip() for item in row["Equipment"].split(',')] if row["Equipment"] else [],
            "instructions": row["Instructions"]
        }
        tasks.append(task)

# Write the dictionary to a JSON file
with open(json_file_path, 'w', encoding='utf-8') as jsonfile:
    json.dump(tasks, jsonfile, indent=4, ensure_ascii=False)

print(f"CSV data has been converted to JSON and saved to {json_file_path}")
