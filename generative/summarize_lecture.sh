#!/bin/bash

# import env
source "$(dirname "$0")/../.env"

# Default values
MODEL="gpt-4o"
SUBJECT="my class"
API_KEY="$OPENAI_API_KEY"

# Usage function
usage() {
    echo "Usage: $0 -s|--subject <subject> -i|--input-path <transcript_file> [-m|--model <model>]"
    echo "Options:"
    echo "  -s, --subject      Subject of the lecture"
    echo "  -i, --input-path   Path to the transcript file"
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
        -i|--input-path)
            INPUT_PATH="$2"
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

if [[ -z "$INPUT_PATH" ]]; then
    echo "Error: Input path is required. Use --input-path."
    exit 1
fi

if [[ -z "$SUBJECT" ]]; then
    echo "Error: Subject is required. Use --subject."
    exit 1
fi

# Check if input file exists
if [[ ! -f "$INPUT_PATH" ]]; then
    echo "Error: Input file not found: $INPUT_PATH"
    exit 1
fi

# Create arguments string for Python script
PYTHON_ARGS="{\"api_key\": \"$API_KEY\", \"subject\": \"$SUBJECT\", \"input_path\": \"$INPUT_PATH\", \"model\": \"$MODEL\", \"output_dir\": \"$OUTPUT_DIR\"}"

# Call the Python script
echo "Generating summary for $SUBJECT..."
echo "Input: $INPUT_PATH"
echo "Model: $MODEL"
echo ""

python3 "$NOL_UTILS_DIR/generative/python_scripts/summarize_lecture.py" "$PYTHON_ARGS"