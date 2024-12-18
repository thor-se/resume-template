#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p "./output"

# Loop through .md files in input directory and convert each to .odt
for md_file in ./input/*.md; do
  pandoc "$md_file" \
    --reference-doc="./resources/template.odt" \
    --lua-filter="./resources/filters/include-files.lua" \
    -o "./output/$(basename "$md_file" .md).odt"
done

# Convert .odt to .pdf using LibreOffice
for odt_file in output/*.odt; do
  pdf_file="output/$(basename "$odt_file" .odt).pdf"
  soffice --headless --convert-to pdf "$odt_file" --outdir "$(dirname "$pdf_file")"
done