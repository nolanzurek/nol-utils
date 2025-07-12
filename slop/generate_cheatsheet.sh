#!/bin/bash

# import env
source "$(dirname "$0")/../.env"

# Default values
MODEL="gpt-4o"
SUBJECT="my class"
API_KEY="$OPENAI_API_KEY"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--subject)
            SUBJECT="$2"
            shift 2
            ;;
        -p|--pdf-path)
            PDF_PATH="$2"
            shift 2
            ;;
        -m|--model)
            MODEL="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate required parameters
if [[ -z "$API_KEY" ]]; then
    echo "Error: API key is required. Define OPENAI_API_KEY in .env"
    exit 1
fi

if [[ -z "$PDF_PATH" ]]; then
    echo "Error: PDF path is required. Use --pdf-path."
    exit 1
fi

# Check if PDF file exists
if [[ ! -f "$PDF_PATH" ]]; then
    echo "Error: PDF file not found: $PDF_PATH"
    exit 1
fi

# Create arguments string for Python script
PYTHON_ARGS="{\"api_key\": \"$API_KEY\", \"subject\": \"$SUBJECT\", \"pdf_path\": \"$PDF_PATH\", \"model\": \"$MODEL\"}"

# Call the Python script
echo "Generating cheatsheet for $SUBJECT..."
echo "PDF: $PDF_PATH"
echo "Model: $MODEL"
echo ""

python3 "$NOL_UTILS_DIR/slop/python_scripts/generate_cheatsheet.py" "$PYTHON_ARGS"