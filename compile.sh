#!/bin/bash

# Check if Pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo "Pandoc is not installed."
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed."
    exit 1
fi

# Check if toc.json exists
if [ -f "input/toc.json" ]; then
    echo "Reading input files from toc.json..."

    # Create output directory if it doesn't exist
    if [ ! -d "output" ]; then
        echo "Creating output directory..."
        mkdir -p "output"
    fi

    # Read each title and file list from toc.json
    jq -c 'to_entries[]' input/toc.json | while IFS= read -r entry; do
        # Extract title and file list
        title=$(echo "$entry" | jq -r '.key')
        files=$(echo "$entry" | jq -r '.value[]')

        echo "Processing $title..."

        input_files=""

        # Debug: Print each file path
        echo "Files to process:"
        echo "$files"

        # Read each file from the file list
        for file in $files; do
            echo "Checking file: $file"

            if [ -f "input/$file" ]; then
                echo "Adding $file to combined.md"
                input_files+=$(cat "input/$file")
                input_files+=$'\n\n'  # Use $'\n\n' for newlines
            else
                echo "File $file not found in input directory!"
                exit 1
            fi
        done

        # Create a temporary markdown file for Pandoc
        echo -e "$input_files" > "input/combined.md"

        # Convert combined.md to .odt using the .odt reference template
        if [ -f "input/combined.md" ] && [ -f "resources/template.odt" ]; then
            echo "Converting combined.md to $title.odt using the .odt template..."
            pandoc input/combined.md -o "output/$title.odt" --reference-doc=resources/template.odt
        else
            echo "combined.md or template.odt not found!"
            exit 1
        fi

        # Cleanup temporary file
        rm input/combined.md

        echo "$title conversion to .odt complete!"

    done

    # Convert .odt to .pdf using LibreOffice
    echo "Converting .odt files to .pdf..."
    for odt_file in output/*.odt; do
        pdf_file="output/$(basename "$odt_file" .odt).pdf"
        soffice --headless --convert-to pdf "$odt_file" --outdir "$(dirname "$pdf_file")"
    done

    echo "Conversion to .pdf complete!"

else
    echo "toc.json not found!"
    exit 1
fi