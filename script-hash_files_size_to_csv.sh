#!/bin/bash

OUTFILE="$1"

if [ -z "$OUTFILE" ]; then
	echo "Usage: $0 output_file.csv"
	exit 1
fi

echo '"sha256","filepath","filesize"' > "$OUTFILE"

find . -type f -print0 | xargs -0 -n 1 -P "$(grep -c 'core id' /proc/cpuinfo)" -I{} bash -c '
	filepath="{}"
	hash=$(sha256sum "$filepath" | awk "{print \$1}")
	size=$(stat -c%s "$filepath")
	esc_path=$(printf "%s" "$filepath" | sed "s/\"/\"\"/g")
	printf "\"%s\",\"%s\",\"%s\"\n" "$hash" "$esc_path" "$size"
' >> "$OUTFILE"
