import requests
import sys
import requests
import sys
import ast
from datetime import datetime

# Get inputs from command line arguments
if len(sys.argv) > 1:
    try:
        inputs = ast.literal_eval(sys.argv[1])  # Convert string to dictionary
    except Exception as e:
        print(f"Error parsing input arguments: {e}")
        sys.exit(1)
else:
    inputs = {}

# Get constants
API_KEY = inputs.get('api_key')
INPUT_PATH = inputs.get('input_path')
MODEL = inputs.get('model', 'gpt-4o')
OUTPUT_DIR = inputs.get('output_dir', './outputs')

OUTPUT_TXT_FILE = f'{OUTPUT_DIR}/chat_{datetime.now().strftime("%m-%d-%Y,%H:%M:%S")}.txt'

if not API_KEY or not INPUT_PATH:
    print("Please provide api_key, and input_path as command line arguments.")
    sys.exit(1)


f = open(INPUT_PATH, "r")
filetext = f.read()
f.close()

headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {API_KEY}"
}

payload = {
    "model": MODEL,
    "messages": [
    {
        "role": "user",
        "content": [
        {
            "type": "text",
            "text": filetext
        },
        ]
    }
    ],
    "max_tokens": 4000
}

response = requests.post("https://api.openai.com/v1/chat/completions", headers=headers, json=payload)

# write output
if response.status_code == 200:
    with open(OUTPUT_TXT_FILE, 'w') as f:
        f.write(response.json()['choices'][0]['message']['content'])
    print(f"Output written to {OUTPUT_TXT_FILE}")
else:
    print(f"Error: {response.status_code} - {response.text}")
    sys.exit(1)