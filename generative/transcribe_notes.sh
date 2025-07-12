#!/bin/bash

# import env
source "$(dirname "$0")/../.env"

# Default values
MODEL="gpt-4o"
SUBJECT="my class"
API_KEY="$OPENAI_API_KEY"

# Usage function
usage() {
    echo "Usage: $0 -s|--subject <subject> -p|--pdf-path <pdf_path> [-m|--model <model>]"
    echo "Options:"
    echo "  -s, --subject      Subject of the lecture"
    echo "  -p, --pdf-path     Path to the PDF file"
    echo "  -m, --model        OpenAI model to use (default: gpt-4o)"
    echo "  -h, --help         Show this help message"
    exit 1
}

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
        -o|--output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
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
PYTHON_ARGS="{\"api_key\": \"$API_KEY\", \"subject\": \"$SUBJECT\", \"pdf_path\": \"$PDF_PATH\", \"model\": \"$MODEL\", \"output_dir\": \"$OUTPUT_DIR\"}"

# Call the Python script
echo "Transcribing notes for $SUBJECT..."
echo "PDF: $PDF_PATH"
echo "Model: $MODEL"
echo ""

python3 "$NOL_UTILS_DIR/generative/python_scripts/transcribe_notes.py" "$PYTHON_ARGS"