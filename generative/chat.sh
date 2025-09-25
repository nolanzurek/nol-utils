#!/bin/bash

# import env
source "$(dirname "$0")/../.env"

# Default values
MODEL="gpt-4o"
API_KEY="$OPENAI_API_KEY"

# Usage function
usage() {
    echo "Usage: $0 <input_path> [-m|--model <model>] [-s|--subject <subject>] [-o|--output-dir <dir>]"
    echo "Options:"
    echo "  <input_path>       Path to the transcript file (required, first argument)"
    echo "  -m, --model        OpenAI model to use (default: gpt-4o)"
    echo "  -s, --subject      Subject for the chat (optional)"
    echo "  -o, --output-dir   Output directory (optional)"
    echo "  -h, --help         Show this help message"
    exit 1
}

# Parse command line arguments
if [[ $# -lt 1 ]]; then
    usage
fi

INPUT_PATH="$1"
shift

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--subject)
            SUBJECT="$2"
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

# INPUT_PATH is already validated by positional argument check above

# Check if input file exists
if [[ ! -f "$INPUT_PATH" ]]; then
    echo "Error: Input file not found: $INPUT_PATH"
    exit 1
fi

# Create arguments string for Python script
PYTHON_ARGS="{\"api_key\": \"$API_KEY\", \"input_path\": \"$INPUT_PATH\", \"model\": \"$MODEL\", \"output_dir\": \"$OUTPUT_DIR\"}"

# Call the Python script
echo "Generating response..."
echo "Input: $INPUT_PATH"
echo "Model: $MODEL"

python3 "$NOL_UTILS_DIR/generative/python_scripts/chat.py" "$PYTHON_ARGS"