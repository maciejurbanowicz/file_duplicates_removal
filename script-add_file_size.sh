#!/bin/bash

if [[ $# -ne 3 ]]; then
	echo "Usage: $0 input_file output_file max_jobs"
	exit 1
	fi

input_file="$1"
output_file="$2"
max_jobs="$3"

# Empty or create output file
> "$output_file"
# Function to process one line
process_line() {
	local line="$1"
	local hash=${line%% *}
	local path=${line#* }

	path=$(echo -e "${path}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

	local size=0
	if size=$(stat -c%s -- "$path" 2>/dev/null); then
        	:
    	fi
    	# Use flock or atomic append to avoid race condition
    	echo "$hash $path $size" >> "$output_file"
}

# Job control: limit concurrent jobs

job_count=0
while IFS= read -r line || [[ -n "$line" ]]; do
	process_line "$line" &
	((job_count++))
	if (( job_count >= max_jobs )); then
        	wait -n # Wait for any job to finish
		((job_count--))
	fi
	done < "$input_file"
wait # Wait for all remaining jobs
