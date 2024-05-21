#!/bin/bash

# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 input_file"
    exit 1
fi

input_file=$1

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "File $input_file does not exist."
    exit 1
fi

# Create output file name with ".new" extension
output_file="${input_file}.new"

# Replace all occurrences of "SEARCH" with "REPLACE" and save to output file
sed 's/SEARCH/REPLACE/g' "$input_file" > "$output_file"

echo "All occurrences of 'SEARCH' have been replaced with 'REPLACE' in $output_file"


#Save the script to a file, for example replace.sh
#Give execute permission to the script: chmod +x replace.sh
#Run the script with the input file as an argument: ./replace.sh input.txt
