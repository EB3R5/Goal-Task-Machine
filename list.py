import json
import os

def json_to_txt(json_file_path, txt_file_path):
    # Load tasks from the JSON file
    with open(json_file_path, 'r', encoding='utf-8') as json_file:
        tasks = json.load(json_file)
    
    # Sort tasks by hierarchy just in case
    tasks_sorted = sorted(tasks, key=lambda x: x['hierarchy'])
    
    # Prepare the content for the text file
    lines = []
    for task in tasks_sorted:
        line = f"Hierarchy: {task['hierarchy']}, Action: {task['action']}, Location: {task['location']}, Items: {task['items']}"
        if 'equipment' in task and task['equipment']:
            line += f", Equipment: {', '.join(task['equipment'])}"
        if 'instructions' in task and task['instructions']:
            line += f", Instructions: {task['instructions']}"
        lines.append(line)
    
    # Write the content to the text file
    with open(txt_file_path, 'w', encoding='utf-8') as txt_file:
        for line in lines:
            txt_file.write(line + "\n")
    
    print(f"Tasks have been saved to {txt_file_path}")

# Define the paths
script_dir = os.path.dirname(os.path.realpath(__file__))
json_file_path = os.path.join(script_dir, 'submitted_tasks.json')
txt_file_path = os.path.join(script_dir, 'tasks_list.txt')

# Convert JSON to TXT
json_to_txt(json_file_path, txt_file_path)
