import requests
import os
from sys import argv
import requests
import os
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
SUBJECT = inputs.get('subject')
INPUT_PATH = inputs.get('input_path')
MODEL = inputs.get('model', 'gpt-4o')
OUTPUT_DIR = inputs.get('output_dir', './outputs')

OUTPUT_TXT_FILE = f'{OUTPUT_DIR}/{SUBJECT}_summary_{datetime.now().strftime("%m-%d-%Y,%H:%M:%S")}.txt'

if not API_KEY or not SUBJECT or not INPUT_PATH:
    print("Please provide api_key, subject, and input_path as command line arguments.")
    sys.exit(1)


f = open(INPUT_PATH, "r")
transcript = f.read()
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
            # "text": f"""
            # The following text is from a zoom lecture on {SUBJECT}. 
            # Clean up this transcript and rewrite it into DETAILED NOTES I CAN READ INSTEAD OF GOING TO LECTURE. 
            # Clarity should be increased, but EVERYTHING from the lecture should be in the notes; additional related content and concepts can also be added. 
            # At the end, make a list of concepts covered in the lecture; indicate things that couldn't be adequately noted that require independant research to learn (e.g. things rely on visuals that didn't make it into the transcript). 
            # It is possible there are transcription errors; correct these. 
            # \nTranscript: \n{transcript}
            # """
            "text": f"""
            The following text is from a lecture on {SUBJECT}. 
            Clean up this transcript and rewrite it in the TONE of a technical blog post; include ALL the concepts and examples mentioned, and include more related ones that are relevant if needed or particularly interesting. 
            Use bold for important terms, italics for emphasis, and keep paragraphs short, around 4-5 sentences or shoter. 
            At the end, make a list of concepts covered in the lecture; indicate things that couldn't be adequately noted that require independant research to learn (e.g. things rely on visuals that didn't make it into the transcript). 
            It is possible there are transcription errors; correct these. 
            \nTranscript: \n{transcript}
            """
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