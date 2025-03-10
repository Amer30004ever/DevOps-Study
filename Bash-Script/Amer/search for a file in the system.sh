#!/bin/bash

# Prompt for the file name
read -p "Please enter the file name: " file

echo "Searching for the file..."

# Search for the file system-wide using 'find'
found_file=$(find / -type f -name "$file" 2>/dev/null)

# Check if the file is found
if [ -z "$found_file" ]; then
    echo "File doesn't exist"
else
    echo "File found at: $found_file"
fi
