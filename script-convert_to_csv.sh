#!/bin/bash
if [[ $# -ne 2 ]]; then
	echo "Usage: $0 input_file output_csv"
	exit 1
fi

input_file="$1"
output_file="$2"

# Empty or create CSV file
> "$output_file"

while IFS= read -r line || [[ -n "$line" ]]; do
	# Extract hash (first word), size (last word), and path (middle)
	hash=${line%% *}
	size=${line##* }
	path=${line#* }
	path=${path% $size}

	# Trim path if needed
	path=$(echo "$path" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

	# Output quoted CSV
	echo "\"$hash\",\"$path\",\"$size\"" >> "$output_file"
done < "$input_file"
