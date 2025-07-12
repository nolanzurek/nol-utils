import base64
import requests
from pdf2image import convert_from_path
import glob
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
INPUT_PDF_PATH = inputs.get('pdf_path')
MODEL = inputs.get('model', 'gpt-4o')
OUTPUT_DIR = inputs.get('output_dir', './outputs')

OUTPUT_TXT_FILE = f'{OUTPUT_DIR}/{SUBJECT}_cheatsheet_{datetime.now().strftime("%m-%d-%Y,%H:%M:%S")}.txt'

if not API_KEY or not SUBJECT or not INPUT_PDF_PATH:
    print("Please provide api_key, subject, and pdf_path as command line arguments.")
    sys.exit(1)

# Convert pdf to images
images = convert_from_path(INPUT_PDF_PATH, dpi=300)
print("PDF converted to images")

# Create a temporary directory to store images
if not os.path.exists(f'temp/{SUBJECT}'):
    os.makedirs(f'temp/{SUBJECT}')
    print(f"Temporary directory created: temp/{SUBJECT}")

# Save images to a temporary directory
for i, image in enumerate(images):
    image.save(f'./temp/{SUBJECT}/image_{i}.jpg', 'JPEG')
print("Images saved to directory")

# Encode images into base64
def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

# iterate over all the images
for image_path in sorted(glob.iglob(f'temp/{SUBJECT}/*.jpg'), key=os.path.getctime):

    # Getting the base64 string
    base64_image = encode_image(image_path)

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
                "text": f"""
                I am making a cheet sheet for {SUBJECT}. 
                Transcribe all equations EXACTLY, text can be summarized to get ALL the technical details but terse text, but do whitespace so that everything can fit on one line (unless there's a list). Use TeX for the math transcribing. 
                Don't make the callouts or tables or whatever in markdown; don't even use a newline to separate a term and its definition. 
                Don't ever do math on a new line either. IF its just an equation and a label be terse
                """
            },
            {
                "type": "image_url",
                "image_url": {
                "url": f"data:image/jpg;base64,{base64_image}"
                }
            }
            ]
        }
        ],
        "max_tokens": 2000
    }

    response = requests.post("https://api.openai.com/v1/chat/completions", headers=headers, json=payload)

    # print specifics of response
    if response.status_code != 200:
        print(f"Error: {response.status_code} - {response.text}")
        continue
    else:
        print(f"Success: {response.status_code}")

    # write to a file
    with open(OUTPUT_TXT_FILE, 'a') as f:
        f.write(response.json()["choices"][0]["message"]["content"] + '\n\n\n')
    
    # status monitoring
    print(response.json()["choices"][0]["message"]["content"])


# Clean up temporary files
for image_path in glob.glob(f'temp/{SUBJECT}/*.jpg'):
    os.remove(image_path)
os.rmdir(f'temp/{SUBJECT}')
os.rmdir('temp')

print(f"Output written to {OUTPUT_TXT_FILE}")