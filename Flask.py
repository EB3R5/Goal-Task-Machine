from flask import Flask, render_template
import json
import os

app = Flask(__name__)

@app.route('/')
def checklist():
    # Load your tasks from the JSON file
    script_dir = os.path.dirname(os.path.realpath(__file__))
    json_file_path = os.path.join(script_dir, 'submitted_tasks.json')
    
    with open(json_file_path, 'r') as file:
        tasks = json.load(file)
    
    # Pass the tasks to a template
    return render_template('checklist.html', tasks=tasks)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
