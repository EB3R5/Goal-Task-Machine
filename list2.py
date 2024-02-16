import json
import os

def json_to_txt():
    # Define the paths for the input JSON and the output TXT files
    script_dir = os.path.dirname(os.path.realpath(__file__))
    json_file_path = os.path.join(script_dir, 'submitted_tasks.json')
    txt_file_path = os.path.join(script_dir, 'tasks_list.txt')
    
    # Load tasks from the JSON file
    with open(json_file_path, 'r', encoding='utf-8') as json_file:
        tasks = json.load(json_file)
    
    # Sort tasks by hierarchy
    sorted_tasks = sorted(tasks, key=lambda x: x['hierarchy'])
    
    # Write the sorted tasks to a TXT file
    with open(txt_file_path, 'w', encoding='utf-8') as txt_file:
        for task in sorted_tasks:
            # Construct the task string with action before location
            task_str = f"{task['action']} - {task['location']} - {task['items']} - {', '.join(task['equipment'])} - {task['instructions']}\n"
            txt_file.write(task_str)
    
    print(f"Tasks have been written to {txt_file_path}")

json_to_txt()
